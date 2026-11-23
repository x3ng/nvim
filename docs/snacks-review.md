# Snacks 与替代方案审查（2026-11-16）

结论：当前配置继续使用 Snacks 合理。它属于覆盖面很广的 UI 工具集，但没有证据能称它为整个 Neovim 生态唯一最优或用户最多的方案。对于这套同时需要 picker、explorer、终端、通知、图片的配置，迁移到另一个 picker 并不会把这些职责和依赖一起解决。

## 对比

| 方案 | 定位和适合场景 | 依赖与迁移成本 |
| --- | --- | --- |
| Snacks | 多模块 UI 工具集，共享窗口、布局、picker 和图片等能力；适合统一多种日常 UI | grep 仍需 rg，Git 需 git，图片需协议/转换工具；不额外要求独立 fzf。模块多，需要显式选择与维护边界 |
| Telescope | 专注 picker 的可扩展框架；适合需要特定 Telescope 扩展的工作流 | 依赖 plenary；grep 仍需 rg，推荐原生 sorter；终端、通知、图片、explorer 要另行保留或组合 |
| fzf-lua | 基于 fzf/skim 的 picker；适合已经依赖 fzf、希望围绕它统一搜索的工作流 | 要求 fzf > 0.36 或 skim；其他外部命令按功能需要。支持复用 Snacks image，因此迁移 picker 未必能删掉 Snacks |
| mini.pick / mini.nvim | mini.pick 是较小的 picker，mini.nvim 是可组合模块库；适合优先减少界面和定制、接受重新组织模块的配置 | mini.pick 把 rg 列为加速文件/内容搜索的可选依赖，可在没有建议依赖时运行；达到现有多种 UI 工作流需要继续选择模块和配置，mini.pick 本身不是整个 Snacks 的替代品 |

这次未跑四者的同负载性能基准，因此不宣称任何一个“最快”。依赖数量也要按达到相同功能所需的整套组合比较，不能只数插件仓库。

## 采用情况与维护证据

读取到的 LazyVim `main` 默认逻辑将 Snacks 放在新安装的 picker 和 explorer 选择首位，同时保留 fzf、Telescope、neo-tree 选择；旧安装另有保持默认值的兼容逻辑。这说明它有实际集成采用，不能据此推导整个 Neovim 社区的市场份额。

GitHub API 查询时四个仓库都未归档。返回的 `pushed_at` 如下（UTC）：

| 仓库 | 最近推送时间 |
| --- | --- |
| folke/snacks.nvim | 2026-05-25 |
| nvim-telescope/telescope.nvim | 2026-11-13 |
| ibhagwan/fzf-lua | 2026-11-15 |
| nvim-mini/mini.pick | 2026-11-13 |

`pushed_at` 不是发布质量、issue 响应速度或长期维护承诺。Snacks 的这个时间差值得持续观察，不能写成“目前维护最活跃”，也不足以直接认定停更。当前配置继续固定 `lazy-lock.json`，不因为调研就升级或迁移。

同日再次联网核实时，默认分支最近提交仍为 `882c996cf281`（2026-05-25），与本地锁定提交一致；但 issue/PR 列表中存在 9—11 月的关闭记录，例如 [#2960](https://github.com/folke/snacks.nvim/issues/2960) 和 [#2967](https://github.com/folke/snacks.nvim/issues/2967)。关闭不等于修复或合并，不能据此承诺响应速度；同样，单凭最近提交日期也不能断言无人维护。

## 对个人维护成本的判断

“相对省心”成立的前提是保留当前这组 UI 功能。Snacks 已经提供它们共享的窗口/布局/选择接口，本地也已接通现有快捷键、主题、消息与会话工作流。换成 Telescope 或 fzf-lua 主要替换 picker，其他模块仍需保留或另行组合；mini.pick 更适合明确接受减少 UI 或重组配置的目标。当前没有发现只能通过迁移解决的必要需求，因此继续维护现有 Snacks 组合的成本预计较低。这是针对当前配置的工程判断，不是跨方案实测的维护工时排名。

它省下的是多插件之间的接线和交互一致性成本，不会省掉外部运行环境。尤其图片渲染仍受终端协议、tmux 和转换器影响。保持依赖统一声明、启动预检、锁定更新、少做自定义覆盖，比继续换 picker 更直接地解决当前痛点。后续如果遇到具体兼容问题长期无修复，或现有布局/性能无法满足需求，再按模块评估替换。

## 对当前配置的决策

保留 Snacks 作为主要 UI 工具集；保留主题实时预览和图片渲染。工具缺失由使用时的插件报错，不再维护统一预检表，也不是通过删除功能掩盖。Oil 的目录编辑、grug-far 的项目替换、gitsigns 的 hunk 操作和原生 LSP 有自己的职责，不能以“统一”之名假定 Snacks 全部覆盖。

只有出现具体问题（需要某个 Telescope 扩展、现有 picker 无法满足的性能/交互需求、Snacks 的兼容性问题长期无人维护），才考虑替换对应模块。若下一轮目标改成明显减少 UI 和配置量，再评估 mini.nvim 组合。当前没有足够证据支持一次整体迁移。

## 来源

- [Snacks README](https://github.com/folke/snacks.nvim#readme)：模块范围、按模块启用与健康检查。
- [Telescope README](https://github.com/nvim-telescope/telescope.nvim#readme)：plenary、rg 和推荐原生 sorter。
- [fzf-lua README](https://github.com/ibhagwan/fzf-lua#readme)：fzf/skim、可选预览工具及 Snacks image 集成。
- [mini.pick README](https://github.com/nvim-mini/mini.pick#readme)：picker 范围和可选依赖。
- [LazyVim 默认选择逻辑](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/init.lua)、[Snacks picker 集成](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/editor/snacks_picker.lua)。
- 仓库元数据：[Snacks](https://api.github.com/repos/folke/snacks.nvim)、[Telescope](https://api.github.com/repos/nvim-telescope/telescope.nvim)、[fzf-lua](https://api.github.com/repos/ibhagwan/fzf-lua)、[mini.pick](https://api.github.com/repos/nvim-mini/mini.pick)。

以上引用是本次读取的上游状态；本地实际行为仍以锁文件对应源码及运行验证为准。
