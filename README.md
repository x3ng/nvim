# nvim

个人 Neovim 0.12+ 配置，同时支持 VSCode Neovim。独立 Neovim 里按空格查看 which-key 分组，`<leader>sk` 搜索映射，`<leader>?` 查看当前 buffer 的局部映射。

## 改配置时去哪找

| 要改什么 | 入口 |
| --- | --- |
| 启动顺序、宿主分支 | `init.lua`、`lua/config/init.lua` |
| 通用选项、快捷键、自动命令 | `lua/config/options.lua`、`keymaps.lua`、`autocmds.lua` |
| 插件加载时机、选项、按键 | `lua/plugins/<插件>.lua`，由 `lua/config/lazy.lua` 自动导入 |
| LSP 命令、项目根目录、语言设置 | `lua/config/lsp/servers.lua` |
| 诊断、inlay hints、LSP 局部按键 | `lua/config/lsp/ui.lua` |
| 各文件类型的 formatter、格式化按键 | `lua/plugins/conform.lua` |
| Mason 工具安装清单 | `lua/plugins/mason.lua` |
| 自动检测缩进、单文件手动覆盖 | `lua/plugins/sleuth.lua`、`lua/config/indent.lua` |
| VSCode 命令映射 | `lua/config/vscode/keymaps.lua` |

## 语言工具

优先从项目的 `nix develop` 启动 Neovim。Mason 将自己的 bin 目录追加到 PATH。首次打开或新建文件时，`lua/plugins/lsp.lua` 注册服务器，只启用能找到可执行文件的条目。

- **LSP**　用 `:checkhealth vim.lsp` 查看当前文件的服务和根目录。用 `:LspInstall <server>` 显式安装 Mason 支持的服务器。切换 Nix 环境后，从新环境重启 Neovim。
- **格式化**　`<leader>cf` 格式化当前文件或选区。Conform 优先使用该文件类型的 formatter，再回退到 LSP。保存时不触发格式化。`:ConformInfo` 可查看当前可用的 formatter。
- **缩进**　vim-sleuth 读取项目的 EditorConfig、文件的 modeline 和现有代码。新文件或样本不足时，它会参考当前目录及父目录的同类型文件。用 `:verbose Sleuth` 查看检测来源，`:SetIndent 2` 或 `:SetIndent tab 4` 可临时覆盖当前 buffer。格式化输出遵循 formatter 的项目配置。
- **工具安装**　`:MasonToolsInstall` 补装清单里缺少的 formatter 和 Tree-sitter CLI。`nixfmt`、`gofmt`、`rustfmt` 由 Nix 或语言工具链提供。`:TSInstallConfigured` 安装配置的解析器。

## VSCode / VSCodium

启用扩展 `asvetliakov.vscode-neovim`，将样例里的路径按本机情况合并到用户设置，重载窗口。运行 `:lua print(vim.g.vscode)` 可确认宿主分支。LSP、补全和格式化由 VSCode 提供，`<leader>cf` 调用宿主的文档或选区格式化。集成终端里直接运行 `nvim` 则使用完整配置。[设置样例](vscode/settings.json)

## 验证

从配置目录执行。结构检查可独立运行，其余检查使用本机已安装的插件。临时目录隔离主题状态和缓存。

```sh
(
  check_dir=$(mktemp -d)
  export XDG_CACHE_HOME="$check_dir/cache" XDG_STATE_HOME="$check_dir/state"
  set -e
  nvim --headless -u NONE -i NONE '+luafile tests/structure.lua'
  for test in hosts keymaps ui theme; do
    nvim --headless -i NONE "+luafile tests/$test.lua"
  done
  nvim --headless -i NONE --cmd 'let g:vscode = v:true' '+luafile tests/hosts.lua'
)
```
