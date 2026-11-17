# 外部依赖的统一入口

在**实际使用的终端和项目环境**里运行 `:checkhealth cfg`。它会列出受影响功能、命令的实际路径、缺失项、最低版本和 Nix 补齐方式。启动时会对日常功能缺失的依赖发出一条汇总提醒，不等按下功能键才发现；没有缺失时不通知。没有新增快捷键。

依赖分三层管理：

| 范围 | 唯一声明位置 | 如何管理 |
| --- | --- | --- |
| UI、搜索、图片、安装工具及可选扩展 | [`lua/cfg/dependencies.lua`](../lua/cfg/dependencies.lua) 的 `tools` | 声明受影响功能、命令组合/回退、最低版本和 Nix 包名；启动检查和 health 共用 |
| LSP | `lua/cfg/lsp/servers.lua` | health 读取现有注册表，检查 PATH 或 Mason 路径，不复制服务器名单 |
| Formatter | `lua/cfg/format/formatters.lua` | Conform 与 health 共用这份选择表；health 让 Conform 解析真实命令，包含项目本地工具和配置错误；安装来源由 `format/tools.lua` / Mason 管理 |

新增需要外部命令的功能时，必须同时更新相应声明。`startup = true` 表示缺失会影响已配置的日常功能，启动时提醒；安装阶段工具只在 health 中警告；`optional = true` 的图片扩展和渐进增强只显示说明，不要求全部安装。检查不会下载工具或悄悄关闭功能。

声明与检测由 `cfg.dependencies` 提供；启动提醒、语言工具汇总和 Snacks 图片终端能力由 `cfg.health` 处理，通过根 `init.lua` 显式启动。安装器在加载时重新查询缺失项，不使用启动时缓存的缺失列表；PATH 工具优先，明确需要时再检查可执行的 Mason 路径。

## 补齐环境

优先使用项目已有的 `nix develop`。临时准备常用 UI 工具可用：

```sh
nix shell nixpkgs#ripgrep nixpkgs#fd nixpkgs#git nixpkgs#lazygit nixpkgs#imagemagick -c nvim
```

每个缺失项也会给出单独的 `nix shell ... -c nvim` 命令。长期使用时，将实际需要的包加入自己的 Nix 用户配置或项目 devShell；本仓库不修改主机配置。临时 shell 跟随本机 nixpkgs；需要可复现版本时使用项目锁定的 flake。

Mason 是语言工具的**显式安装后备**，不负责 ripgrep、fd、ImageMagick、lazygit 等 UI 工具。`:MasonToolsInstall` 安装缺失的已配置语言工具；`:TSInstallConfigured` 安装缺失 parser。普通启动不自动安装这些工具。更换项目环境后重新从该环境启动 Neovim，再执行 health。

## 功能与能力边界

- 全文搜索、TODO 项目搜索、grug-far 默认替换引擎都需要 `rg`；文件 picker 按 `fd/fdfind → rg → find` 回退，缺 rg 不代表文件查找也坏了。
- 图片渲染已启用。PNG 可直接显示；其他图片格式通常需要 ImageMagick。显示仍要求 Kitty Graphics Protocol，不能靠安装图片工具让任意终端支持。启动检查在有 UI 时复用 Snacks 的终端探测；headless 会明确显示“无法验证”。tmux、远程连接的细节见 `:checkhealth snacks`。
- PDF、LaTeX、Typst、Mermaid、视频分别有额外转换工具，列在 health 的可选项中。LaTeX 还需要相应 parser 和宏包；Mermaid 可能需要浏览器运行时。找到 CLI 不代表这些完整渲染链已通过测试。
- Markdown 浏览器预览需要 Node 和浏览器；插件安装/更新的 build 运行 `npm install`，需要 npm 和网络。源码编辑不依赖浏览器预览。
- Tree-sitter 当前锁定版本需要 Neovim 0.12+；parser 安装/更新还需要 CLI ≥ 0.26.1、C 编译器、curl、tar 和网络。CLI 最低版本在 health 中验证，启动不会为检查版本启动进程。
- 插件引导/安装/更新需要 Git 和网络，并可能运行 build（包括 `:TSUpdate`）。这与“普通启动不安装语言工具”是不同阶段。
- LSP 和 formatter 可能还需要语言运行时、项目依赖和正确根目录。health 检查命令可发现性及 Conform 配置，不能替代打开实际文件后的 `:checkhealth vim.lsp` / `:ConformInfo`。
- 剪贴板还取决于会话服务；字体和浏览器由桌面环境提供。这些不能只根据 PATH 判定正常。

本轮检查中 `rg` 来自 Codex 附带路径，不能代表普通终端的环境。health 展示真实路径就是为了暴露这种差异；不要以另一个启动器中的成功检查代替日常终端的检查。

## 验证

已安装插件时，从配置目录执行，状态隔离到 `/tmp`：

```sh
XDG_CACHE_HOME=/tmp/nvim-deps-check/cache XDG_STATE_HOME=/tmp/nvim-deps-check/state \
  nvim --headless -i NONE '+luafile tests/dependencies.lua'
```

检查缺 rg 时文件查找仍可回退、剪贴板组合依赖、单次启动汇总、可选项不打扰、CLI 版本不满足，以及 Conform 名称到真实命令的解析。`:checkhealth cfg` 每次重新检查当前环境；VSCode host 明确跳过独立 Neovim 的依赖检查。
