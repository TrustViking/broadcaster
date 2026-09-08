@echo off
chcp 65001 >nul
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"

echo [INFO] Building RELEASE installer (no secrets bundled).

set "NO_PAUSE=1"
call "%SCRIPT_DIR%build_broadcaster_exe.bat"
if %ERRORLEVEL% neq 0 (
  echo [ERROR] Portable build failed.
  pause & exit /b 1
)

if not "%VERSION%"=="" set "MyAppVersion=%VERSION%"
if "%MyAppVersion%"=="" set "MyAppVersion=0.3.0"

if not exist "%SCRIPT_DIR%dist\installer" mkdir "%SCRIPT_DIR%dist\installer" >nul 2>&1

set "STAGE_SECRETS=%SCRIPT_DIR%dist\broadcaster\secrets"
if exist "%STAGE_SECRETS%" (
  del /F /Q "%STAGE_SECRETS%\*" >nul 2>&1
  for /D %%D in ("%STAGE_SECRETS%\*") do rmdir /S /Q "%%D" 2>nul
) else (
  mkdir "%STAGE_SECRETS%" >nul 2>&1
)
if exist "%SCRIPT_DIR%secrets\.env.example" (
  copy /Y "%SCRIPT_DIR%secrets\.env.example" "%STAGE_SECRETS%\.env.example" >nul
  echo [OK] dist\broadcaster\secrets\ wiped and reseeded with .env.example only.
) else (
  echo [ERROR] secrets\.env.example not found - release secrets staging cannot be reseeded.
  pause & exit /b 1
)
if exist "%SCRIPT_DIR%secrets\README.txt" (
  copy /Y "%SCRIPT_DIR%secrets\README.txt" "%STAGE_SECRETS%\README.txt" >nul
  echo [OK] dist\broadcaster\secrets\README.txt restored after wipe.
)

set "STAGE_CONFIG=%SCRIPT_DIR%dist\broadcaster\config"
set "STAGE_INTERNAL_CONFIG=%SCRIPT_DIR%dist\broadcaster\_internal\app\config\runtime"
if exist "%STAGE_CONFIG%\app_config.example.yaml" (
  copy /Y "%STAGE_CONFIG%\app_config.example.yaml" "%STAGE_CONFIG%\app_config.yaml" >nul
  echo [OK] dist\broadcaster\config\app_config.yaml replaced with example ^(release build^).
  if exist "%STAGE_INTERNAL_CONFIG%\app_config.yaml" (
    copy /Y "%STAGE_CONFIG%\app_config.example.yaml" "%STAGE_INTERNAL_CONFIG%\app_config.yaml" >nul
    echo [OK] dist\broadcaster\_internal\app\config\runtime\app_config.yaml replaced with example.
  )
) else (
  echo [ERROR] config\app_config.example.yaml missing in staging - cannot proceed safely.
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

"%ISCC%" ^
  /DMyAppVersion=%MyAppVersion% ^
  /DIncludeSecrets=0 ^
  /DOutputBaseFilename=broadcaster-setup-%MyAppVersion% ^
  /DSourceDir="%SCRIPT_DIR%dist\broadcaster" ^
  /DOutputDir="%SCRIPT_DIR%dist\installer" ^
  "%SCRIPT_DIR%installer.iss"
if %ERRORLEVEL% neq 0 (
  echo [ERROR] Release installer build failed.
  pause & exit /b 1
)

echo [OK] Release installer built: dist\installer\broadcaster-setup-%MyAppVersion%.exe
echo [INFO] This installer contains NO real secrets and NO personal config.
echo [INFO] Suitable for GitHub Releases.
pause
