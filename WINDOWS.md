# REA Windows x64

这是 [morluto/rea](https://github.com/morluto/rea) 的 Windows 发行分支，基于 REA 6.5.0、上游提交 `150e996a86f2bec4982ba87f37bf502a8d5e8214`。保留上游 MIT 许可证及版权声明。上游已经提供实验性的 Windows 支持；本分支增加 Windows 本机原生模块构建、便携启动器和经过实测的发行包。

## 下载使用

在 [Releases](https://github.com/wanwufengkuangk/rea-windows/releases) 下载 `rea-windows-6.5.0-win-x64-portable.zip`。推荐解压到本地 NTFS 磁盘上的短路径，例如 `C:\tools\rea-windows`。系统需要 Windows x64。

便携包包含已编译的 REA、生产依赖、Windows 原生模块、Node.js 24.18.0 / npm 11.16.0、Temurin JDK 21.0.12.1 和 Ghidra 12.1.4。各运行时保留自身许可证。启动器只设置当前调用的环境变量。

在解压后的目录打开 PowerShell：

```powershell
.\rea-windows.cmd --version
.\rea-windows.cmd doctor --provider ghidra --json
.\rea-windows.cmd inspect "C:\samples\example.exe" --json
.\rea-windows.cmd search "C:\samples\example.exe" keyword --kind procedures --json
.\rea-windows.cmd decompile "C:\samples\example.exe" FUNCTION_NAME --json
```

将示例路径和函数名替换为自己的分析目标。DLL 也可作为原生分析目标。首次分析会创建 Ghidra 项目，耗时随文件大小而变化。

PowerShell 入口为 `rea-windows.ps1`，接受相同参数。MCP 标准输入输出服务入口为 `rea-windows.cmd mcp`，可填写到支持 MCP 的客户端配置中。此分支提供命令行和 MCP 服务。

下载后的 SHA-256 可用以下命令与 Release 的 `SHA256SUMS.txt` 比较：

```powershell
Get-FileHash .\rea-windows-6.5.0-win-x64-portable.zip -Algorithm SHA256
```

## 从源码构建

GitHub 的源码 ZIP 包含源码；运行时和原生编译产物由便携包提供。自行构建时准备：

1. Node.js 24.18.0、Temurin JDK 21.0.12.1 和 Ghidra 12.1.4，分别解压到项目下 `.local\windows\tools\node-v24.18.0-win-x64`、`.local\windows\tools\jdk-21.0.12.1+1`、`.local\windows\tools\ghidra_12.1.4_PUBLIC`。
2. [LLVM-MinGW](https://github.com/mstorsjo/llvm-mingw/releases) 的 UCRT Windows x64 工具链；本次验证使用 `20261006` 版本。把其 `bin` 目录加入当前终端的 `PATH`。
3. 运行下列命令。原生模块的完整构建说明见 [native/windows/README.md](native/windows/README.md)。

```powershell
$nodeDirectory = Join-Path $PWD '.local\windows\tools\node-v24.18.0-win-x64'
$env:PATH = "$nodeDirectory;$env:PATH"
npm.cmd ci
npm.cmd run build:cached
npm.cmd run build:windows-native
npm.cmd run verify:windows-native:artifact
.\rea-windows.cmd doctor --provider ghidra --json
```

## 验证与范围

- Windows x64 原生模块的完整验证通过，覆盖只读文件清理、文件身份、取消、子进程退出、Job Object 内存限制和重命名 Node 主程序。
- 上游 Ghidra CLI/MCP 验证通过，实际调用 30 种操作，包括生命周期与明确返回不支持的能力边界。
- CMD、Windows PowerShell 5.1 和 PowerShell 7 启动器已验证参数、输出、退出码和环境恢复。
- 自编译的优化 PE 样本成功恢复三个计算函数；398 个核心输入与恢复模型一致。另有 12 个非法输入正确拒绝；三个非 ASCII 用例在统一输入字节后也一致。
- 对 WPS 12.1.0.28505 的一个 873 字节函数完成静态分析，确认 `/photo2pdf` 功能选择项映射到 `wpscenter.exe` 和 `Run /lookup_module=photo2pdf.dll` 参数模板；该结果仅说明入口分发逻辑。

本次已验证的主要环境是 Windows x64、本地 NTFS 和 Ghidra 原生 PE 分析。其他上游能力各有工具和系统要求，详见上游文档。修改后的 Linux 构建分支未在 Linux 上执行。反编译结果通常是伪代码，原始变量名、注释和工程结构不保证能够恢复。

## 来源与许可证

- REA：[morluto/rea](https://github.com/morluto/rea)，[MIT License](LICENSE)。
- Node.js：[nodejs.org](https://nodejs.org/)，运行时许可证见其 `LICENSE`。
- Eclipse Temurin：[Adoptium](https://adoptium.net/)，许可证及第三方声明见 JDK 的 `legal` 目录。
- Ghidra：[NSA Ghidra](https://github.com/NationalSecurityAgency/ghidra)，许可证及第三方声明见其发行目录。

上游项目的其他依赖声明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) 与 `licenses` 目录。
