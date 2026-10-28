# 00 · 目录布局

一台跑起来的机器，大概长这样（`<DSH_HOME>` 通常是 `~/.dsh`，`<KIT>` 是你自己放项目的地方）：

```
<DSH_HOME>/
├── profiles/<profile>/          宿主 profile：package.json、cordis.patch.yml、node_modules
├── sessions/                    会话日志（按工作区分目录）
├── storages/
│   ├── workspace.json           工作区与会话归属
│   └── session_projcache/       会话标题、用量等投影缓存
├── <plugin-a>/                  各插件自己的数据目录
│   ├── config.json
│   └── state.json
└── <memory-service>/            (如果单独部署) 记忆服务数据

<KIT>/
├── kit/plugin/                  人格插件：index.mjs、persona.txt（+ 代码里的底色）
├── kit/vendor/                  第三方插件（本地副本，可打外挂补丁）
├── kit/overlays/                外挂包：改动清单 + apply.mjs
├── bridges/qq-bridge/           桥接进程
│   ├── config.json              端口、白名单、令牌
│   ├── state/                   sessions.json、日志、统计
│   └── roles/                   群角色卡
├── scripts/                     守护、备份、统计、迁移
├── data/                        记忆服务配置与 SQLite
├── state/                       调度状态、群名缓存、错误日志
└── archive/                     人格历史、日记、说说草稿
```

## 哪些该进版本库

| 进 | 不进 |
|---|---|
| 人格模板、角色卡模板 | 真实人格存档、聊天记录 |
| 配置**模板**（占位符） | 真实 config.json（含令牌、QQ 号） |
| 脚本与文档 | 记忆库、state、日志 |
| 外挂包的补丁清单 | 插件 vendor 全量副本 |

`.gitignore` 里已经按这个规则写好；发布前再 `git status` 扫一眼。
