@echo off
setlocal
set "REA_NODE_DIR=%~dp0.local\windows\tools\node-v24.18.0-win-x64"
set "JAVA_HOME=%~dp0.local\windows\tools\jdk-21.0.12.1+1"
set "GHIDRA_INSTALL_DIR=%~dp0.local\windows\tools\ghidra_12.1.4_PUBLIC"
set "REA_ANALYSIS_PROVIDER=ghidra"
set "PATH=%REA_NODE_DIR%;%JAVA_HOME%\bin;%PATH%"

for %%F in ("%REA_NODE_DIR%\node.exe" "%JAVA_HOME%\bin\java.exe" "%GHIDRA_INSTALL_DIR%\support\analyzeHeadless.bat" "%~dp0scripts\rea.mjs") do (
    if not exist "%%~F" (
        >&2 echo REA Windows: required file is missing: "%%~F"
        exit /b 1
    )
)

"%REA_NODE_DIR%\node.exe" "%~dp0scripts\rea.mjs" %*
exit /b %errorlevel%
