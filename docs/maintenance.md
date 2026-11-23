# 维护审查（2026-11-16）

本轮按保守收束处理：保留主要编辑、导航、终端、Git 和语言工作流，不增加插件或快捷键，不更新锁文件。Snacks 统一的是部分 UI 和接口，不能替代搜索引擎、Git、语言工具或终端能力。

## 已修复和收束

| 问题 | 本轮处理 |
| --- | --- |
| 主题通过 `vim.schedule` 延迟加载，其他 UI 和启动命令可能先读取旧主题 | 在 `lazy.setup()` 后同步加载，继续支持按需加载主题插件 |
| 每个 `ColorScheme` 事件都保存主题，实时预览也触发事件；取消时再异步恢复 | 保留实时预览，但不保存预览；关闭时同步恢复原主题和 background，确认后单独应用并保存 |
| 透明覆盖与主题配色职责冲突 | 按用户要求移除整个透明功能，包括 `<leader>ut`、状态读写及所有背景覆盖；主题完整管理配色 |
| 首次写入主题状态时，状态目录未必存在 | 写入前创建状态目录 |
| 外部依赖只有用到功能才暴露问题 | 由使用时的插件/命令报错；不再维护依赖表或启动预检；保留图片渲染 |
| zoxide、profiler 调试入口扩张日常配置范围 | 删除 `<leader>fz`、`<leader>ps`；无需为配置安装 zoxide |
| Blink 默认尝试下载 Rust 匹配器 | 使用内置 Lua 匹配器，不自动下载或要求 Rust 构建；匹配性能和容错策略与 Rust 实现不同 |
| Conform 的 Verilog formatter 配置使用了可执行文件名，无法解析 formatter | 配置名改为 `verible`，由 Conform 解析到 `verible-verilog-format`；同步修正 Mason 来源说明 |

原有 `user-theme` 状态继续使用，旧的 `user-transparent` 文件不再读取，无需手动清理。四套主题保留，使用各自的不透明配色；本地 theme 模块只负责选择和持久化，不修改 highlight。

## 外部依赖入口

不再维护统一的依赖表或启动预检。工具缺失由使用时的插件/命令报错；排查用 `:checkhealth vim.lsp` 和 `:ConformInfo`。Snacks 的定位和候选比较见 [`docs/snacks-review.md`](snacks-review.md)。

## 职责审查与暂时保留

| 范围 | 当前分工 | 本轮结论 |
| --- | --- | --- |
| 导航 / 文件操作 | Snacks 查找和浏览；Oil 编辑目录以批量改名/移动 | 保留，两者职责不同；Oil 不接管默认 explorer |
| 搜索 / 替换 | Snacks grep 查找；grug-far 做项目替换 | 保留，共用 rg，不增加第二种搜索引擎 |
| 编辑器消息 / 通知 | Noice 接管命令行、`msg_show` 和 `vim.notify`，统一路由与历史；Snacks 渲染通知与历史 picker | `nh` 查看统一历史，`nd` 收起两边显示；移除 `nm` / `nc`。Noice 的 LSP hover/signature/progress、补全菜单接管继续关闭 |
| 主题 | 主题完整负责配色；本地 theme 模块只负责选择和持久化 | 保留四套主题，移除透明覆盖及其开关 |
| 语义 / Git 标记 | Snacks words 使用 LSP 引用；gitsigns 提供行级 Git 状态和 hunk 操作 | 保留；Snacks Git picker 负责列表导航，未替代 hunk 编辑 |
| 语言工具 | 原生 LSP 负责运行，Conform 手动格式化，Mason 负责显式安装 | 保留现有注册表，不另建依赖管理层 |

本轮没有证据说明主工作流中的插件应直接删除。后续若继续精简，优先评估 Noice 的消息接管是否值得维护，以及四套主题是否都常用。文件查找目前仍按原配置包含 ignored 文件并跟随符号链接，大型仓库可能产生较多结果；这项既有行为保留，调整时应作为单独的导航策略变更。

## 验证

结构重构前的维护和按键基线提交为 `85315ee`。重构将启动编排移回根 `init.lua`，插件声明集中到 `plugins/`，移除手工 import 清单；LSP、主题和健康检查显式初始化。formatter 选择表与安装来源独立于插件 spec，通用自动命令和缩进命令也不再混在 options 文件里。

无插件启动环境下可检查导入边界和安装查询：

```sh
XDG_CACHE_HOME=/tmp/nvim-structure-check/cache XDG_STATE_HOME=/tmp/nvim-structure-check/state \
  nvim --headless -u NONE -i NONE '+luafile tests/structure.lua'
```

该测试验证读取插件声明和运行时模块不会注册事件、创建命令、启用 LSP、探测可执行文件或启动进程；只有显式 setup 才启用服务。还检查新工具出现后安装器的查询会更新。共享/宿主设置模块和 bootstrap 的执行行为由根入口明确调用，不属于纯声明模块。

已安装插件的环境下，从配置目录执行；状态和缓存隔离到 `/tmp`，不会改写个人主题选择：

```sh
XDG_CACHE_HOME=/tmp/nvim-host-check/cache XDG_STATE_HOME=/tmp/nvim-host-check/state \
  nvim --headless -i NONE '+luafile tests/hosts.lua'
XDG_CACHE_HOME=/tmp/nvim-vscode-check/cache XDG_STATE_HOME=/tmp/nvim-vscode-check/state \
  nvim --headless -i NONE --cmd 'let g:vscode = v:true' '+luafile tests/hosts.lua'
XDG_CACHE_HOME=/tmp/nvim-theme-check/cache XDG_STATE_HOME=/tmp/nvim-theme-check/state \
  nvim --headless -i NONE '+luafile tests/theme.lua'
```

主题测试检查四套主题的不透明背景、移除透明入口、旧透明状态不再干预主题、实时预览不持久化、取消/确认、明暗 background 恢复、持久状态重载和失效主题回退。这些是运行时和 highlight 验证，仍需在实际终端里观察字体和视觉效果。

排查依赖先用插件自身报错、`:checkhealth vim.lsp` 和 `:ConformInfo`。不要仅为消除所有可选提示而安装全部扩展工具。

基础 UI 的职责、终端复用与消息路由策略见 [ui-review.md](ui-review.md)。运行时验证：

```sh
XDG_CACHE_HOME=/tmp/nvim-ui-check/cache XDG_STATE_HOME=/tmp/nvim-ui-check/state \
  nvim --headless -i NONE '+luafile tests/ui.lua'
```

该检查实际创建本地 shell，验证布局切换、隐藏/重开、进程复用及退出清理；同时验证通知经 Noice 到达 Snacks、统一历史包含编辑器消息与通知且不重复、收起操作保留历史。
