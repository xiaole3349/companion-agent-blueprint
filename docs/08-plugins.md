# 08 · 插件清单

这些是「第三方插件 + 本地改造」的组合。完整源码在各自仓库，这里只记**装了哪些、为什么、怎么改的**。

| 插件 | 作用 | 本地改造 |
|---|---|---|
| `dsh-fish-memory` | 会话级长期记忆（JSON，注入式） | 改成每轮按 mtime 懒加载人格无关；本项目里只留注入 |
| `dsh-feiyu-mood` | 心情状态、挂饰、时间线 | 标签换成自己的、提示词里的关系改成本角色的 |
| `dsh-speak-up` | 主动搭话（掷骰 + 唤醒） | 触发文案、频率、安静时段 |
| `dsh-qq-bridge` | 宿主侧 QQ 私聊桥 | 关掉，避免和 reserved2 桥重复 |
| `dsh-tts-bridge` | 网页朗读 | 未用 |
| `dsh-token-flow` | 本项目自带：统计各群 token 消耗 | 自写，见 `scripts/` |

## 改造要单独成包（overlay）

改上游插件的文本时，不要直接改散落各处的字符串，把它们收成一个**外挂包**：

```
overlay/
  README.md        改动清单
  apply.mjs        幂等套用（先备份、已改过就跳过、对不上就报错）
```

上游更新覆盖代码后，跑一次 `apply.mjs` 就恢复，不用重新翻一遍代码找改哪。

示例见本项目原来的 `feiyu-mood-overlay`（12 条改动：五档标签、提示词关系、设置页文案、挂饰标签）。

## 安装

- 自带 Host 部分的 bundle：`plugin_manager install_bundle <目录>`
- 装完 `application: applied` 才算生效；日志和进程列表都不能证明
- Host 插件改了代码，用禁用→启用让它重载（`set_plugin` 两次）
