# Leader 按键布局

Leader 是空格。按功能分组，插件名不进入分组。按空格后 which-key 显示分组，按 `<leader>?` 看当前 buffer 的局部映射，搜索按键列表用 `<leader>sk`。默认 Normal 模式，特殊模式和作用范围如下注明。

## 分组与完整入口

表中所有键都带 `<leader>` 前缀；大小写不同，例如 `fe` 与 `fE` 是两个操作。

| 分组 | 按键与功能 |
| --- | --- |
| `f` Files & Projects | `ff` 找文件；`fe` 浏览目录树；`fE` 用 Oil 编辑当前文件所在目录；`fn` 新文件；`fr` 最近文件；`fp` 项目 |
| `s` Search & Pick | `sg` 全文搜索；`ss` 文档符号；`sS` 工作区符号；`sd` 全部诊断；`sD` 当前 buffer 诊断；`sc` 命令；`sh` 帮助；`sk` 按键；`sm` 标记；`sj` 跳转记录；`sl` location list；`sq` quickfix；`s/` 搜索历史；`s:` 命令历史 |
| `s` 搜索与替换 | `sr` 项目替换；`sw` 按光标词预填；`sb` 限定当前文件；`sv` 按选区预填（Visual 模式）；`st` 搜索 TODO |
| `b` Buffers & Scratch | `bb` buffer 列表；`bd` 删除当前 buffer 并保留布局；`bs` 打开/关闭 scratch；`bS` 选择已有 scratch |
| `c` Code | `cf` 手动格式化（Normal / Visual）；`cd` 光标处诊断浮窗；`cr` 重启 LSP；`cp` Markdown 浏览器预览 |
| `g` Git | `gg` 项目 lazygit；`gG` 当前文件目录 lazygit；`gb` 分支；`gl` 提交日志；`gL` 当前行日志；`gs` 状态；`gS` stash；`gd` 暂存与未暂存的 diff；`gc` 最近提交；`gr` 自分叉点；`gm` 对比主分支 tip；`gD` 自选比较范围；`gH` 当前文件历史 |
| `h` Git Hunks | `hs` stage hunk；`hr` reset hunk；`hp` 预览 hunk；`hb` 当前行 blame；`hd` 当前文件 diff |
| `u` UI | `uw` 折行；`ul` 相对行号；`uc` 光标行；`uC` 主题（实时预览）；`uh` inlay hints；`us` sticky context |
| `n` Messages & Notifications | `nh` 统一消息与通知历史（Snacks picker）；`nd` 同时收起消息与通知。Noice 负责路由和历史，Snacks 负责通知与历史列表显示；移除 `nm` / `nc` |
| `t` Terminal | `th` 底部终端；`tv` 右侧终端；与 `<C-/>` 浮窗复用同目录、同编号的 shell，切换方向移动窗口，重复同入口隐藏并保留进程 |
| `q` Quit & Sessions | `qq` 退出全部；`qs` 恢复当前目录会话；`qS` 选择会话；`ql` 上次会话；`qd` 停止本次进程的会话自动保存（不删除已有会话） |
| 高频单键 | `w` 保存；`<leader>` Flash 跳转（即连按两次空格，Normal / Visual / Operator-pending） |

`cd`、`cr`、`uh` 在 LSP attach 后提供；`h` 组在 gitsigns attach 后提供；`cp` 只在 Markdown buffer 提供。`g` 负责 Git 列表/工具，`h` 负责当前文件的行级操作。`s` 汇总搜索/选择及项目替换，`f` 不再容纳所有 picker。

原生 `gd` / `gD`、`gr*`、`K`、`gO`、`[d` / `]d`、`[b` / `]b`、窗口切换和 `<C-/>` 终端入口保持不变。没有把 Vim 原生操作再复制到 leader 下。

独立 Neovim 的 Normal 模式中，`Ctrl-h/j/k/l` 切换窗口。`Alt-h/l` 将当前窗口收窄 / 加宽 5 列，`Alt-j/k` 将当前窗口增高 / 降低 2 行。

VSCode 使用相同分组和同义操作，但只映射宿主实际支持的入口，见 [vscode.md](vscode.md)。例如 `bb` 是编辑器列表、`sd` 是 Problems、`cp` 是宿主 Markdown 预览；不会在 VSCode 内启动 Snacks 或 Neovim LSP。

## 审阅 agent 的改动

### 多文件审阅（CodeDiff）

按 `空格 gD` 会填入 `:CodeDiff `。直接回车打开工作区，或输入版本和路径再回车。路径相对于仓库根目录。

| 命令 | 审阅内容 |
| --- | --- |
| `:CodeDiff master...HEAD` | 从共同祖先到 HEAD 的已提交改动 |
| `:CodeDiff master...` | 从同一共同祖先到工作区，包含未提交修改 |
| `:CodeDiff master HEAD` | 主分支与当前提交两个快照之间的差异 |
| `:CodeDiff v1.2 feature -- src/ tests/` | 指定版本间的差异，只看所列目录 |
| `:CodeDiff --staged` | 已暂存改动 |

默认左右对照，左侧 Changes 占 24 列。聚焦文件面板后，`Alt-l` 加宽，`Alt-h` 收窄，也可以用 `:vertical resize 32` 指定宽度；重建布局时可能恢复配置宽度。在正文按 `空格 uw` 可临时软换行，CodeDiff 4.0.8 在切换文件或重新进入窗口时会重设 `nowrap`。

在 CodeDiff 标签页按 `g?` 弹出当前审阅模式的快捷键，按 Esc 关闭。文件面板用 `i` 切换列表和目录树，回车选择文件。在 diff 窗口用 `]f` / `[f` 切文件，`]c` / `[c` 跳改动，`t` 切换双栏和行内布局，`q` 关闭审阅。工作区视图会跟随磁盘上的修改更新，文件面板也可以按 `R` 手动刷新。

在源码文件中按 `空格 gH` 查看当前文件的提交历史。用 `:CodeDiff history master..HEAD` 可以逐个审阅分支上的提交。

### 快速预览（Snacks）

独立 Neovim 中，按空格后接下列按键。后三个入口列出变更文件，输入路径可筛选，移动选中项即可预览补丁，回车聚焦补丁以便滚动。重命名分别列出旧路径的删除和新路径的新增。

| 按键 | 比较范围 |
| --- | --- |
| `gd` | 查看尚未提交的 hunk，包含已暂存和未暂存的修改。尚未被 Git 跟踪的新文件可在 `gs` 查看。 |
| `gc` | 查看 HEAD 这一次提交引入的改动。合并提交与第一父提交比较，首次提交则列出新增文件。 |
| `gr` | 查看当前分支自共同祖先以来的累计改动，相当于 `git diff master...HEAD`。适合审阅整个功能分支。 |
| `gm` | 直接比较主分支 tip 和 HEAD，相当于 `git diff master HEAD`。主分支在分叉后独有的改动也会体现。 |

`gr` 和 `gm` 依次选取本地 `master`、`main`、已缓存的 `origin/master`、`origin/main`。标题显示选中的引用。三个提交比较入口均使用已提交的快照。

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
