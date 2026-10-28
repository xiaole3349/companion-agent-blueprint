# release.ps1 —— 给 companion-agent-blueprint 打 release 并上传 kit 包
#
# 用法：
#   pwsh -File scripts\release.ps1                 # 自动 patch 版本 +1（v0.1.0 -> v0.1.1）
#   pwsh -File scripts\release.ps1 -Version v0.2.0 # 指定版本
#   pwsh -File scripts\release.ps1 -NoPush         # 只打包+打 tag，不传 release
#
# 令牌从 $env:GH_TOKEN 读；没有就回退到 ~/.dsh/jingjing/state/gh-token.txt。
# 代理：仓库本地 git 已配 http.proxy；打包与上传走系统代理（PowerShell 用 WinINET）。
param(
  [string]$Version = '',
  [switch]$NoPush
)

$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot   # scripts 的上一级 = 仓库根
$Owner = 'xiaole3349'
$Name  = 'companion-agent-blueprint'

# ── 令牌 ────────────────────────────────────────────────────────────────
$token = $env:GH_TOKEN
if (-not $token) {
  $tf = Join-Path $HOME '.dsh\jingjing\state\gh-token.txt'
  if (Test-Path $tf) { $token = (Get-Content $tf -Raw).Trim() }
}
if (-not $token) { throw '没有 GitHub 令牌：设 $env:GH_TOKEN 或写好 gh-token.txt' }

# ── 版本号 ──────────────────────────────────────────────────────────────
if (-not $Version) {
  # 远端可能有 tag（比如上一次是走 API 发的 release），先拉一次再算
  git -C $Repo fetch --tags --quiet 2>$null | Out-Null
  $existing = git -C $Repo tag --sort=-v:refname 2>$null | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' } | Select-Object -First 1
  if (-not $existing) {
    # 本地没有 tag 就去问远端最新的 release
    try {
      $h = @{ Authorization = "token $token"; 'User-Agent' = 'jingjing'; 'Accept' = 'application/vnd.github+json' }
      $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Name/releases/latest" -Headers $h -TimeoutSec 20
      if ($latest.tag_name -match '^v\d+\.\d+\.\d+$') { $existing = $latest.tag_name }
    } catch {}
  }
  if ($existing) {
    $parts = $existing.TrimStart('v').Split('.')
    $Version = ('v{0}.{1}.{2}' -f $parts[0], $parts[1], ([int]$parts[2] + 1))
  } else {
    $Version = 'v0.1.0'
  }
}
if ($Version -notmatch '^v\d+\.\d+\.\d+$') { throw "版本号格式不对：$Version（要 vX.Y.Z）" }

# ── 打包 ────────────────────────────────────────────────────────────────
$zip = Join-Path $env:TEMP "$Name-kit-$Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
$items = Get-ChildItem $Repo -Force | Where-Object { $_.Name -ne '.git' }
Compress-Archive -Path $items.FullName -DestinationPath $zip -CompressionLevel Optimal
Write-Host "打包：$zip ($((Get-Item $zip).Length) 字节)"

# ── 打 tag（本地 + 推送）───────────────────────────────────────────────
Push-Location $Repo
try {
  git add -A
  $dirty = git status --porcelain
  if ($dirty) {
    git -c user.email=template@example.com -c user.name=template commit -qm "release $Version"
  }
  git tag -f $Version
  if (-not $NoPush) { git push origin $Version }
}
finally { Pop-Location }

if ($NoPush) { Write-Host "已打包+打 tag（未推送）。zip：$zip"; exit 0 }

# ── 建 release ──────────────────────────────────────────────────────────
$h = @{ Authorization = "token $token"; 'User-Agent' = 'jingjing'; 'Accept' = 'application/vnd.github+json' }
$body = @{
  tag_name = $Version
  target_commitish = 'main'
  name = "$Version · 蓝图"
  body = "companion-agent-blueprint 的可下载 kit 包（自动发布）。`n`n包含 docs/、templates/、schemas/、scripts/、README、UPSTREAMS、versions.lock.json；不含插件源码与私人物料。"
} | ConvertTo-Json

$rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Name/releases" -Method Post -Headers $h -ContentType 'application/json' -Body $body -TimeoutSec 30

# ── 上传 zip ────────────────────────────────────────────────────────────
$upload = $rel.upload_url -replace '\{\?[^}]+\}', ''
$uri = "$upload`?name=$Name-kit-$Version.zip"
$resp = Invoke-WebRequest -Uri $uri -Method Post `
  -Headers @{ Authorization = "token $token"; 'User-Agent' = 'jingjing'; 'Content-Type' = 'application/zip' } `
  -InFile $zip -TimeoutSec 120
$asset = $resp.Content | ConvertFrom-Json
Write-Host "发布完成：$($asset.browser_download_url)"
