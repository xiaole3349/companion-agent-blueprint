# 06 · 定时杂活

## 建议的几条

| 任务 | 频率 | 干什么 | 放哪 |
|---|---|---|---|
| 记忆整理 | 每 8 小时 | events → memories，写半个日报 | 宿主计划任务 / cron |
| 每日备份 | 每天凌晨 | 打包人格、记忆、配置 | 同上 |
| token 日报 | 每天傍晚 | 各群消耗汇总推到 QQ | 系统计划任务 |
| 桥接守护 | 常驻 | 桥掉了自动拉起 + 发消息告知 | 系统计划任务（登录触发） |
| 群名对齐 | 每周 | 会话标题改成群名 | 系统计划任务 |

## 守护进程必须脱离宿主进程树

DSH 重启会带走子进程。守护要挂在**登录触发的计划任务**里：

```powershell
$scriptPath = 'C:\Companion\scripts\bridge-supervisor.ps1'
$pwshPath = (Get-Command pwsh.exe -ErrorAction Stop).Source

$act = New-ScheduledTaskAction `
  -Execute $pwshPath `
  -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`"" `
  -WorkingDirectory (Split-Path -Parent $scriptPath)

$trg = New-ScheduledTaskTrigger -AtLogOn
$pri = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
Register-ScheduledTask -TaskName '桥接守护' -Action $act -Trigger $trg -Principal $pri -Force
```

注意：`-WindowStyle Hidden` 不是 `New-ScheduledTaskAction` 的参数，它属于 PowerShell
的启动参数，必须放进 `-Argument`；同时用 `-WorkingDirectory` 指定脚本目录，
避免任务从系统目录启动导致相对路径失效。

守护要做的三件事：

1. 发现宿主的端口（每次启动都变）
2. 端口变了或桥没了 → 拉起
3. 拉起成功/失败都发一条消息给主人（别只在日志里写）

### 守护的可靠性三件套

只做到「掉线就重启」会踩坑，还要加：

- **重启退避**：连续失败后指数退避（例如 5s、10s、30s、60s…封顶），别 1 秒拉一次把机器打满。
- **通知限流**：同一条「桥挂了」最多发一次/告警一次，恢复后重置，避免每轮重启都刷屏。
- **失效锁恢复**：锁文件里要写 PID 和时间戳；进程没了但锁还在（上次异常退出），
  要能判定锁失效并接管，不能永远「锁着」导致谁都不起来。

## 单实例

守护自己要有锁文件，桥自己也要有锁文件。两层都上，才不会跑出两只。

## 通知要直连

桥挂了的时候，走桥发通知是发不出去的。
通知必须直连 IM 网关（SnowLuma 的 HTTP 接口），不要经过桥。
