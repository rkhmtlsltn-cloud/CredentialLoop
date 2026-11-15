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

set "CL_PORT=4173"
:choose_port
powershell.exe -NoProfile -Command "$c=New-Object Net.Sockets.TcpClient; try {$c.Connect('127.0.0.1',[int]$env:CL_PORT); exit 0} catch {exit 1} finally {$c.Dispose()}" >nul 2>nul
if errorlevel 1 goto port_selected
set /a CL_PORT+=1
if %CL_PORT% geq 4190 goto failed
goto choose_port

:port_selected
echo Starting CredentialLoop on port %CL_PORT%...
start "CredentialLoop server" /D "%~dp0" cmd /k "set CREDENTIALLOOP_PORT=%CL_PORT%&& npm.cmd run certificate-demo"
set /a attempts=0
:wait_for_server
powershell.exe -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:%CL_PORT%' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if not errorlevel 1 goto open_page
set /a attempts+=1
if %attempts% geq 60 goto failed
timeout /t 1 /nobreak >nul
goto wait_for_server

:open_page
start "" "http://127.0.0.1:%CL_PORT%"
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