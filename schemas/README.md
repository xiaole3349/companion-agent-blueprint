# schemas · 配置字段约束

这里写清楚每个配置文件的**字段类型、必填项、占位符**，以及「空令牌 / 空端口」这类常见坏值要报错，
不能靠「看着填」。

## bridge-config.json

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `dsh.baseUrl` | string (URL) | 是 | 宿主地址；必须 `http://127.0.0.1:<port>`，空则拒绝启动 |
| `dsh.provider` / `dsh.model` | string | 是 | 非空 |
| `dsh.authToken` | string | 否 | 空 = 依赖宿主本机信任 |
| `snowluma.wsUrl` | string (URL) | 是 | `ws://…` |
| `snowluma.httpUrl` | string (URL) | 是 | `http://…` |
| `snowluma.accessToken` | string | 是 | 空则拒绝（不能拿空令牌上线） |
| `ownerQQ` | string | 是 | 纯数字 |
| `allow.private` / `allow.groups` | string[] | 是 | 空数组 + `allowAllWhenEmpty:false` = 全部拒绝 |
| `agentPreset` | string | 是 | 必须对应已安装预设 |

## memory-config.json

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `database` | string (path) | 是 | 绝对路径 |
| `port` | integer | 是 | 1–65535 |
| `routes.*.scope` | string | 是 | 服务端确定，不能由请求正文覆盖 |
| `routes.*.token` | string | 是 | ≥32 位，各 route 互不相同；为空拒绝启动 |
| `embedding.enabled` | boolean | 是 | false 时降级为纯关键词 |
| `embedding.digest` | string | 条件必填 | enabled 时必填；换模型要重生成 |

## peak-gate.json

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `enabled` | boolean | 是 | |
| `peaks` | [{start,end}] | 是 | HH:MM 区间，end>start |
| `holidays` | string[] | 是 | 完整年度区间，不是示例；过期要打日志 |

## 通用校验规则

1. 配置加载后跑一遍校验，坏值**拒绝启动并打印具体字段**，不要带病运行。
2. 占位符（`<…>`）未替换时视为坏值。
3. 令牌、路径这类字段不接受空白或 `undefined`。

> 正式的 JSON Schema 文件（`*.schema.json`）后续补；先按这张表做启动校验，
> 字段一多就值得引入真正的 schema 校验器。
