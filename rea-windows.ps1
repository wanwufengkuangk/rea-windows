# Portable launcher: restore the caller's environment after REA exits.
$nodeDirectory = Join-Path $PSScriptRoot '.local\windows\tools\node-v24.18.0-win-x64'
$nodePath = Join-Path $nodeDirectory 'node.exe'
$javaHome = Join-Path $PSScriptRoot '.local\windows\tools\jdk-21.0.12.1+1'
$ghidraHome = Join-Path $PSScriptRoot '.local\windows\tools\ghidra_12.1.4_PUBLIC'
$entryPath = Join-Path $PSScriptRoot 'scripts\rea.mjs'

foreach ($requiredPath in @(
    $nodePath,
    (Join-Path $javaHome 'bin\java.exe'),
    (Join-Path $ghidraHome 'support\analyzeHeadless.bat'),
    $entryPath
)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        [Console]::Error.WriteLine("REA Windows: required file is missing: $requiredPath")
        exit 1
    }
}

$nativeArguments = @($entryPath) + $args
if ($PSVersionTable.PSVersion -lt [Version]'7.3') {
    # Legacy PowerShell requires explicit Windows quoting, including empty args.
    $nativeArguments = foreach ($argument in $nativeArguments) {
        '"' + ([string]$argument -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
    }
} else {
    $PSNativeCommandArgumentPassing = 'Standard'
}
$savedEnvironment = @{}
foreach ($name in @('GHIDRA_INSTALL_DIR', 'JAVA_HOME', 'REA_ANALYSIS_PROVIDER', 'PATH')) {
    $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
try {
    $env:GHIDRA_INSTALL_DIR = $ghidraHome
    $env:JAVA_HOME = $javaHome
    $env:REA_ANALYSIS_PROVIDER = 'ghidra'
    $env:PATH = "$nodeDirectory;$javaHome\bin;$env:PATH"
    & $nodePath @nativeArguments
    $result = $LASTEXITCODE
} catch {
    [Console]::Error.WriteLine("REA Windows: $($_.Exception.Message)")
    $result = 1
} finally {
    foreach ($name in $savedEnvironment.Keys) {
        $savedValue = $savedEnvironment[$name]
        if ($null -eq $savedValue) { $savedValue = [NullString]::Value }
        [Environment]::SetEnvironmentVariable($name, $savedValue, 'Process')
    }
}
exit $result
