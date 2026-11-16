# Leader 按键布局

Leader 是空格。按功能分组，插件名不进入分组；本轮只整理现有入口，不增加功能或旧键别名。按空格后 which-key 显示分组，搜索按键列表用 `<leader>sk`。默认 Normal 模式，特殊模式和作用范围如下注明。

## 分组与完整入口

表中所有键都带 `<leader>` 前缀；大小写不同，例如 `fe` 与 `fE` 是两个操作。

| 分组 | 按键与功能 |
| --- | --- |
| `f` Files & Projects | `ff` 找文件；`fe` 浏览目录树；`fE` 用 Oil 编辑当前文件所在目录；`fn` 新文件；`fr` 最近文件；`fp` 项目 |
| `s` Search & Pick | `sg` 全文搜索；`ss` 文档符号；`sS` 工作区符号；`sd` 全部诊断；`sD` 当前 buffer 诊断；`sc` 命令；`sh` 帮助；`sk` 按键；`sm` 标记；`sj` 跳转记录；`sl` location list；`sq` quickfix；`s/` 搜索历史；`s:` 命令历史 |
| `s` 搜索与替换 | `sr` 项目替换；`sw` 按光标词预填；`sb` 限定当前文件；`sv` 按选区预填（Visual 模式）；`st` 搜索 TODO |
| `b` Buffers & Scratch | `bb` buffer 列表；`bd` 删除当前 buffer 并保留布局；`bs` 打开/关闭 scratch；`bS` 选择已有 scratch |
| `c` Code | `cf` 手动格式化（Normal / Visual）；`cd` 光标处诊断浮窗；`cr` 重启 LSP；`cp` Markdown 浏览器预览 |
| `g` Git | `gg` 项目 lazygit；`gG` 当前文件目录 lazygit；`gb` 分支；`gl` 提交日志；`gL` 当前行日志；`gs` 状态；`gS` stash；`gd` diff 列表 |
| `h` Git Hunks | `hs` stage hunk；`hr` reset hunk；`hp` 预览 hunk；`hb` 当前行 blame；`hd` 当前文件 diff |
| `u` UI | `uw` 折行；`ul` 相对行号；`uc` 光标行；`uC` 主题（实时预览）；`uh` inlay hints；`us` sticky context |
| `n` Messages & Notifications | `nm` 编辑器消息历史；`nc` 隐藏编辑器消息；`nh` 通知历史；`nd` 隐藏通知。编辑器消息由 Noice 管理，通知由 Snacks 管理 |
| `t` Terminal | `th` 底部终端；`tv` 右侧终端 |
| `q` Quit & Sessions | `qq` 退出全部；`qs` 恢复当前目录会话；`qS` 选择会话；`ql` 上次会话；`qd` 停止本次进程的会话自动保存（不删除已有会话） |
| 高频单键 | `w` 保存；`<leader>` Flash 跳转（即连按两次空格，Normal / Visual / Operator-pending） |

`cd`、`cr`、`uh` 在 LSP attach 后提供；`h` 组在 gitsigns attach 后提供；`cp` 只在 Markdown buffer 提供。`g` 负责 Git 列表/工具，`h` 负责当前文件的行级操作。`s` 汇总搜索/选择及项目替换，`f` 不再容纳所有 picker。

原生 `gd` / `gD`、`gr*`、`K`、`gO`、`[d` / `]d`、`[b` / `]b`、窗口切换和 `<C-/>` 终端入口保持不变。没有把 Vim 原生操作再复制到 leader 下。

VSCode 使用相同分组和同义操作，但只映射宿主实际支持的入口，见 [vscode.md](vscode.md)。例如 `bb` 是编辑器列表、`sd` 是 Problems、`cp` 是宿主 Markdown 预览；不会在 VSCode 内启动 Snacks 或 Neovim LSP。

## 本轮迁移表

旧键不保留别名，避免提示菜单和配置继续膨胀。

| 旧键（带 leader） | 新键（带 leader） | 功能 |
| --- | --- | --- |
| `fb` | `bb` | buffer 列表 |
| `ce` | `fE` | Oil 目录编辑 |
| `fg` | `sg` | 全文搜索 |
| `fs` / `fS` | `ss` / `sS` | 文档 / 工作区符号 |
| `fd` / `fD` | `sd` / `sD` | 全部 / 当前 buffer 诊断 |
| `fc` / `fh` / `fk` | `sc` / `sh` / `sk` | 命令 / 帮助 / 按键 |
| `fm` / `fj` | `sm` / `sj` | 标记 / 跳转记录 |
| `fl` / `fq` | `sl` / `sq` | location list / quickfix |
| `f/` / `f:` | `s/` / `s:` | 搜索 / 命令历史 |
| `df` | `cd` | 光标处诊断 |
| `lr` | `cr` | 重启 LSP |
| `mp` | `cp` | Markdown 预览 |
| `.` / `S` | `bs` / `bS` | scratch 开关 / 列表 |

## 维护约定

各插件继续拥有自己的映射，which-key 只声明组名，不重复定义操作。不引入额外映射框架或全局包装层。后续改键时同步修改插件 spec、宿主桥接、此表和相关测试；buffer-local 映射要在 attach/FileType 后检查。

验证命令（从配置目录运行，使用隔离状态目录）：

```sh
XDG_CACHE_HOME=/tmp/nvim-key-check/cache XDG_STATE_HOME=/tmp/nvim-key-check/state \
  nvim --headless -i NONE '+luafile tests/keymaps.lua'
XDG_CACHE_HOME=/tmp/nvim-key-vscode-check/cache XDG_STATE_HOME=/tmp/nvim-key-vscode-check/state \
  nvim --headless -i NONE --cmd 'let g:vscode = v:true' '+luafile tests/hosts.lua'
```

检查新键可达、旧键清理、条件映射加载、picker 操作分发、Visual 模式保留、动作与前缀冲突，以及 VSCode 命令桥接。
