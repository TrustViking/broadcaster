@echo off
chcp 65001 >nul
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"

echo [WARN] Building LOCAL installer (bundles real secrets - do NOT publish).

set "NO_PAUSE=1"
call "%SCRIPT_DIR%build_broadcaster_exe.bat"
if %ERRORLEVEL% neq 0 (
  echo [ERROR] Portable build failed.
  pause & exit /b 1
)

if not exist "%SCRIPT_DIR%secrets\.env" (
  echo [ERROR] secrets\.env not found. Local installer needs real secrets.
  pause & exit /b 1
)

where /q ISCC.exe
if %ERRORLEVEL%==0 (
  set "ISCC=ISCC.exe"
  goto :iscc_found
)
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" & goto :iscc_found
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe" & goto :iscc_found
echo [ERROR] ISCC.exe not found. Install Inno Setup 6 and either add it to PATH or use the default install location.
pause & exit /b 1
:iscc_found

if not "%VERSION%"=="" set "MyAppVersion=%VERSION%"
if "%MyAppVersion%"=="" set "MyAppVersion=0.2.0"

if not exist "%SCRIPT_DIR%dist\installer" mkdir "%SCRIPT_DIR%dist\installer" >nul 2>&1

"%ISCC%" ^
  /DMyAppVersion=%MyAppVersion% ^
  /DIncludeSecrets=1 ^
  /DOutputBaseFilename=broadcaster-setup-local-%MyAppVersion% ^
  /DSecretsSource="%SCRIPT_DIR%secrets" ^
  /DSourceDir="%SCRIPT_DIR%dist\broadcaster" ^
  /DOutputDir="%SCRIPT_DIR%dist\installer" ^
  "%SCRIPT_DIR%installer.iss"
if %ERRORLEVEL% neq 0 (
  echo [ERROR] Local installer build failed.
  pause & exit /b 1
)

echo [OK] Local installer built: dist\installer\broadcaster-setup-local-%MyAppVersion%.exe
echo [WARN] This installer contains REAL secrets. DO NOT upload to GitHub.
pause
