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
$act = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-File <守护脚本>' -WindowStyle Hidden
$trg = New-ScheduledTaskTrigger -AtLogOn
$pri = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
Register-ScheduledTask -TaskName '桥接守护' -Action $act -Trigger $trg -Principal $pri -Force
```

守护要做的三件事：

1. 发现宿主的端口（每次启动都变）
2. 端口变了或桥没了 → 拉起
3. 拉起成功/失败都发一条消息给主人（别只在日志里写）

## 单实例

守护自己要有锁文件，桥自己也要有锁文件。两层都上，才不会跑出两只。

## 通知要直连

桥挂了的时候，走桥发通知是发不出去的。
通知必须直连 IM 网关（SnowLuma 的 HTTP 接口），不要经过桥。
