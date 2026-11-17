# 基础 UI 与 buffer 职责

2026-11-17 审查并整理。Snacks 负责通用界面，Noice 负责消息接管和路由；原生窗口与专用工具继续保留各自职责。

| 内容 | 负责方与处理方式 |
| --- | --- |
| 文件 buffer、窗口、tabpage | Neovim；Snacks 提供 buffer picker 与 bufdelete。buffer 是内容，window 是视口，float 也是 window |
| 文件/符号/诊断查找、`vim.ui.select` | Snacks picker；临时选择适合浮窗 |
| `vim.ui.input` | Snacks input |
| 命令行、编辑器消息、`vim.notify` | Noice 接管、路由与统一历史；Blink 补全命令行 |
| 通知显示 | Noice 的 Snacks backend 直接调用 notifier，避免经 `vim.notify` 回流；Snacks 显示 INFO 及以上通知 |
| 历史列表 | `nh` 使用 Noice 自带的 Snacks 集成，查询 Noice 历史，包含通知和编辑器消息；`nd` 同时收起两边提示，保留历史。移除旧 `nm` / `nc` |
| 常规编辑消息 | Noice mini，2.5 秒后消失 |
| 错误、shell 输出、普通消息达到 4 行 | Noice 底部分屏，不自动抢焦点；显式打开历史分屏才进入窗口 |
| 终端、lazygit | Snacks terminal / lazygit |
| Scratch | Snacks scratch；文件持久化，默认隐藏时自动写入，不能当作退出就丢弃的临时空白 buffer |
| 文件树 / 目录编辑 | Snacks explorer / Oil；浏览与批量文件操作分开。当前 `Oil` 入口是普通窗口 |
| Hover / 诊断浮窗 | 原生 LSP / diagnostic；Noice 不接管 LSP hover、signature、progress、message |
| 补全菜单 / 自动签名提示 | Blink |
| Quickfix / location list | 原生列表用于持续处理结果；Snacks picker 用于临时跳转 |
| 帮助、Lazy、Mason、grug-far | 原生帮助与各工具界面；不做通用浮窗包装 |

## 消息为什么仍然用两个插件

Noice 能接收命令行和编辑器消息事件，提供路由与统一历史；Snacks notifier 主要负责通知显示，不能单独替代 Noice。二者已有官方集成，不需要新写消息管理层。

之前关闭 Noice 的 notify 接管、同时暴露两个历史入口，导致用户必须猜测某条消息该去哪里找。现在普通 `vim.notify` 与编辑器消息进入 Noice；通知通过显式指定的 Snacks backend 显示，历史通过 Snacks picker 查看。历史筛选显式覆盖所有 `msg_show`，避免默认筛选遗漏 `echomsg`、shell 输出等消息。

这统一的是日常消息入口，不是删除 Snacks 内部记录：直接调用 `Snacks.notify` / `Snacks.notifier` 的工具仍可绕过 Noice，Noice 接管前的早期启动通知也不保证出现在其历史中。Snacks 自带历史可以用于底层排障，但不再另设日常快捷键。不包装第三方内部 API，也不拼接两份历史。

通知阈值控制 Snacks 显示；Noice 中仍可保留调试通知用于回查。没有新增 nvim-notify 或其他通知插件。

## 终端复用与生命周期

修复了原 `th` / `tv` 把窗口配置当作命令参数的问题。现在通过 `Snacks.terminal.get(nil, opts)` 创建或取回 shell：

- `<C-/>` 浮窗，`<leader>th` 底部，`<leader>tv` 右侧。
- 同目录、同 count 编号共用一个 shell；窗口方向不参与终端 identity。
- 切换方向时隐藏旧视口，再用原 buffer 和进程重建目标视口；重复同方向入口则隐藏/显示。
- cwd 或 count 不同可拥有不同 shell，沿用 Snacks 原生语义；没有额外终端注册表。
- 进入终端自动输入，双 Esc 回到 Terminal-Normal，Normal 下 `q` 隐藏，成功退出后关闭。隐藏不会结束 shell；删除终端 buffer 会影响进程。

## 应保留的行为边界

- `:close` 关闭视口，`bd` 删除内容并尽量保留布局，终端 hide 保留进程，scratch hide 保存内容。这些操作不应强行统一。
- `bb` 默认列出 listed buffer，不是所有插件内部 buffer；scratch 有独立的 `bS` 入口。
- `winborder=rounded` 是原生浮窗默认值，Snacks、Noice、Blink、Oil 可以显式覆盖。统一边框与配色不要求同一个渲染实现。
- 长期查看的结果适合 split，临时选择适合 float；通知不应抢焦点。
- `sessionoptions` 包含 `terminal`，会话恢复不等于恢复原来的 shell 进程或正在运行的任务。

## 验证

`tests/ui.lua` 在隔离 cache/state 的 headless Neovim 中创建真实本地 shell，检查浮窗/底部/右侧切换、窗口大小、隐藏/重开后的 buffer 和 job 不变、命令响应与退出清理。消息检查使用 Noice 真实 source/router 与 Snacks backend，验证通知转发、统一历史与收起后历史保留；`tests/keymaps.lua` 检查新旧映射边界。

运行命令见 [maintenance.md](maintenance.md)。另通过 PTY 启动正常 Neovim 界面，验证启动后 `vim.notify` 的归属，以及真实 `echomsg` 与通知各自进入历史一次。用户终端里的 `<C-/>` 传递、焦点观感和面板遮挡仍需交互体验验证。未新增插件、依赖或快捷键。
