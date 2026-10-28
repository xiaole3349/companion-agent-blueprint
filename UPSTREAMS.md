# 上游依赖与致谢

这套模板是站在别人肩膀上搭的。下面按「必需 / 可选」列清，链接与许可以各自仓库为准。

## 宿主与运行时

| 项目 | 用途 | 链接 |
|---|---|---|
| DeepSeek Harness (DSH) | 宿主：会话、模型路由、插件、工具 | <https://github.com/deepseek-ai/deepseek-harness> |
| Node.js | 宿主与桥接的运行时 | <https://nodejs.org/> |
| Python 3.11+ | 记忆服务的运行时 | <https://www.python.org/> |
| SQLite | 记忆库（Python 自带） | <https://sqlite.org/> |

## IM 通道

| 项目 | 用途 | 链接 |
|---|---|---|
| SnowLuma | OneBot v11 网关（消息收发、群列表、说说） | 见其发布页 |
| NapCatQQ | QQ 协议端，SnowLuma 的上游之一 | <https://github.com/NapNeko/NapCatQQ> |

## 插件（第三方，本模板只写改造点，不附带源码）

| 插件 | 用途 | 仓库 |
|---|---|---|
| dsh-fish-memory | 会话级长期记忆 | <https://github.com/Yuuyuko-uu/dsh-fish-memory> |
| dsh-feiyu-mood | 心情状态与挂饰 | <https://github.com/Yuuyuko-uu/dsh-feiyu-mood> |
| dsh-speak-up | 主动搭话 | <https://github.com/Yuuyuko-uu/dsh-speak-up> |
| dsh-qq-bridge | 宿主侧 QQ 私聊桥 | <https://github.com/Yuuyuko-uu/dsh-qq-bridge> |
| dsh-tts-bridge | 网页朗读 | <https://github.com/Yuuyuko-uu/dsh-tts-bridge> |

> 这些插件都由 **Yuuyuko-uu** 开发。本模板对它们的改动集中在 `docs/08-plugins.md`，
> 并建议用「外挂包」方式打补丁，不修改上游源码或至少保留可回滚的备份。
> 请遵守各仓库的许可（多为 MIT）。

## 本地模型

| 项目 | 用途 | 链接 |
|---|---|---|
| Ollama | 本地推理服务 | <https://ollama.com/> |
| bge-m3 | 记忆检索用的 embedding 模型 | <https://huggingface.co/BAAI/bge-m3> |

## 特别鸣谢

- **千狩（陇夜千狩）与澜宝（澜色小鲸鱼）**：
  本模板关于「记忆如何储存、如何遗忘」的主体性框架，主要来自他们。
  包括：记忆属于本体的哪一层、分身该不该写、遗忘应该按什么节奏发生。
  这套框架是整份文档里最值钱的部分之一，在此郑重致谢。

- **B 站 @（<https://space.bilibili.com/1398310581/dynamic>）**：
  本模板在「记忆如何分层、分身与本体如何划界」上的部分观点，参考了这位作者的论文与动态。
  感谢他把思路公开出来。

> 如果你的实现里也参考了别人的论文、博客或开源项目，请在同位置补上，
> 这既是礼貌，也能让后来的人顺着线索找回去。

## 关于许可

- 本仓库的文档与模板：CC BY 4.0
- 脚本片段：MIT
- 上游项目：以各自仓库为准，本模板不改变、也不再分发它们的代码
