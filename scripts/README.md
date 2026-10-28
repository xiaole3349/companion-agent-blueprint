# 脚本清单

本目录只放**说明**，不放可直接运行的脚本——脚本里全是本机路径、端口和令牌。
需要时按说明自己写，或者把仓库里对应项目的源码接过来。

| 脚本 | 干什么 | 关键点 |
|---|---|---|
| `bridge-supervisor` | 守护 QQ 桥：发现宿主端口、掉了就拉起、发消息告知 | 挂登录计划任务，脱离宿主进程树；单实例锁 |
| `restart-dsh` | 重启宿主（用于让预设/插件生效） | 用计划任务启动，避免被宿主一起杀掉 |
| `token-stats` | 读桥接的 `token-usage.jsonl`，按群/私聊聚合 | 支持 `--days`、`--json`、CSV 导出 |
| `token-daily` | 每天把 token 汇总推到 QQ | 直连 SnowLuma，不经桥 |
| `post-qzone` | 发一条 QQ 空间说说 | 用 SnowLuma 的 `send_qzone_msg` 扩展接口 |
| `rename-group-sessions` | 把分身会话标题改成群名 | 调宿主 API 的 `sessions.rename` |
| `consolidate-8h` | 记忆整理：events → memories + 半日报 | 别放请求路径；跑完发一条通知 |
| `migrate-*` / `seed-*` | 从旧框架迁移记忆 | 只读源库；搬完跑重复检测 |

## 写这类脚本的三条约定

1. **读写分离**：从别的服务拿数据用 `fetch`，别直连别人的 sqlite（会锁）。
2. **失败要出声**：脚本里每个 catch 都要写日志或发通知，静默失败最难查。
3. **路径可覆盖**：本机路径放在顶部常量或环境变量里，别散落在函数中间。
