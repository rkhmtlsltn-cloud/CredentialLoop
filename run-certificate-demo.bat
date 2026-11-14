@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 goto node_missing
where npm.cmd >nul 2>nul
if errorlevel 1 goto npm_missing

if not exist "node_modules\hardhat\package.json" (
  echo Installing project dependencies...
  call npm.cmd ci
  if errorlevel 1 goto failed
)

echo Starting the local certificate server...
start "CredentialLoop server" /D "%~dp0" cmd /k npm.cmd run certificate-demo
set /a attempts=0
:wait_for_server
powershell.exe -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:4173' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if not errorlevel 1 goto open_page
set /a attempts+=1
if %attempts% geq 60 goto failed
timeout /t 1 /nobreak >nul
goto wait_for_server

:open_page
start "" "http://127.0.0.1:4173"
echo The page is open. Keep the CredentialLoop server window running while you use it.
pause
exit /b 0

:node_missing
echo Node.js is not installed or not on PATH. Install Node.js 22.13 or later, then reopen this file.
goto failed

:npm_missing
echo npm is not installed or not on PATH. Install Node.js 22.13 or later, then reopen this file.
goto failed

:failed
echo.
echo The demo could not start. Read the error above and send a screenshot of it.
pause
exit /b 1
