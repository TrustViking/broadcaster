@echo off
chcp 65001 >nul
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "PYTHON=%SCRIPT_DIR%.venv_broadcaster\Scripts\python.exe"
set "SPEC=%SCRIPT_DIR%broadcaster.spec"
set "ICON=%SCRIPT_DIR%ico_code.ico"
set "DIST=%SCRIPT_DIR%dist"
set "TARGET=%DIST%\broadcaster"

echo [INFO] Broadcaster Bot - building EXE (onedir mode)
echo [INFO] Python: %PYTHON%
echo [INFO] Spec:   %SPEC%
echo.

if not exist "%PYTHON%" (
  echo [ERROR] Python venv not found: %PYTHON%
  pause & exit /b 1
)

if not exist "%SPEC%" (
  echo [ERROR] Spec file not found: %SPEC%
  pause & exit /b 1
)

if not exist "%ICON%" (
  echo [ERROR] Icon file not found: %ICON%
  pause & exit /b 1
)

echo [INFO] Cleaning __pycache__ directories...
for /d /r "%SCRIPT_DIR%" %%d in (__pycache__) do @if exist "%%d" rmdir /S /Q "%%d"

"%PYTHON%" -m PyInstaller --clean --noconfirm "%SPEC%"
if %ERRORLEVEL% neq 0 (
  echo [ERROR] PyInstaller failed.
  pause & exit /b 1
)

echo.
echo [INFO] Copying external resources to dist\broadcaster\...

if exist "%SCRIPT_DIR%tools\" (
  robocopy "%SCRIPT_DIR%tools" "%TARGET%\tools" /E /NFL /NDL /NJH /NJS >nul
  echo [OK] tools\ copied.
) else (
  echo [WARN] tools\ not found -- place yt-dlp.exe into dist\broadcaster\tools\ manually.
)

if exist "%SCRIPT_DIR%secrets\" (
  robocopy "%SCRIPT_DIR%secrets" "%TARGET%\secrets" /E /NFL /NDL /NJH /NJS >nul
  echo [OK] secrets\ copied.
) else (
  echo [WARN] secrets\ not found -- copy .env and Google keys manually.
)

rem config\ -- copy configs directly from sources
mkdir "%TARGET%\config" >nul 2>&1
set "CONFIG_OK=1"

if exist "%SCRIPT_DIR%app\config\runtime\app_config.yaml" (
  copy /Y "%SCRIPT_DIR%app\config\runtime\app_config.yaml" "%TARGET%\config\app_config.yaml" >nul
) else (
  echo [WARN] app\config\runtime\app_config.yaml not found -- config\ will be empty.
  set "CONFIG_OK=0"
)

if exist "%SCRIPT_DIR%app\config\runtime\app_config.example.yaml" (
  copy /Y "%SCRIPT_DIR%app\config\runtime\app_config.example.yaml" "%TARGET%\config\app_config.example.yaml" >nul
  echo [OK] config\app_config.example.yaml copied.
) else (
  echo [WARN] app\config\runtime\app_config.example.yaml not found.
)

if exist "%SCRIPT_DIR%app\llm\prompts\templates.yaml" (
  copy /Y "%SCRIPT_DIR%app\llm\prompts\templates.yaml" "%TARGET%\config\templates.yaml" >nul
) else (
  echo [WARN] app\llm\prompts\templates.yaml not found -- templates.yaml will be missing.
  set "CONFIG_OK=0"
)

if exist "%SCRIPT_DIR%app\config\runtime\README.config.txt" (
  copy /Y "%SCRIPT_DIR%app\config\runtime\README.config.txt" "%TARGET%\config\README.txt" >nul
  echo [OK] config\README.txt copied.
) else (
  echo [WARN] app\config\runtime\README.config.txt not found.
)

if "%CONFIG_OK%"=="1" (
  echo [OK] config\ populated: app_config.yaml + templates.yaml
)

if exist "%SCRIPT_DIR%run_debug.bat" (
  copy /Y "%SCRIPT_DIR%run_debug.bat" "%TARGET%\run_debug.bat" >nul
  echo [OK] run_debug.bat copied.
) else (
  echo [WARN] run_debug.bat not found.
)

if not exist "%TARGET%\secrets" mkdir "%TARGET%\secrets" >nul 2>&1
if exist "%SCRIPT_DIR%secrets\.env.example" (
  copy /Y "%SCRIPT_DIR%secrets\.env.example" "%TARGET%\secrets\.env.example" >nul
  echo [OK] secrets\.env.example copied.
) else (
  echo [WARN] secrets\.env.example not found.
)
if exist "%SCRIPT_DIR%secrets\README.txt" (
  copy /Y "%SCRIPT_DIR%secrets\README.txt" "%TARGET%\secrets\README.txt" >nul
  echo [OK] secrets\README.txt copied.
) else (
  echo [WARN] secrets\README.txt not found.
)

copy /Y "%ICON%" "%TARGET%\ico_code.ico" >nul
echo [OK] ico_code.ico copied to portable root.

echo.
echo [OK] Build complete.
echo [OK] Portable root: %TARGET%
echo.
echo Structure:
echo   broadcaster.exe
echo   run_debug.bat
echo   ico_code.ico
echo   tools\
echo     yt-dlp.exe
echo     deno.exe
echo   secrets\
echo     README.txt
echo     .env
echo     .env.example
echo     credentials.json
echo     service_account.json
echo     token.json
echo     cookies.txt
echo   config\
echo     README.txt
echo     app_config.yaml
echo     app_config.example.yaml
echo     templates.yaml
echo   state\        (created on first run)
echo   logs\         (created on first run)
echo   _internal\
echo.
echo Smoke test:
echo   %TARGET%\broadcaster.exe
echo.
echo [INFO] To produce an installer .exe, run build_release.bat or build_local.bat.
if "%NO_PAUSE%"=="" pause
