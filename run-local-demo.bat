@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 goto node_missing
where npm >nul 2>nul
if errorlevel 1 goto npm_missing

echo CredentialLoop local demo
echo This runs only on Hardhat's local simulated network.
echo.

if not exist "node_modules\hardhat\package.json" (
  echo Installing project dependencies...
  call npm ci
  if errorlevel 1 goto failed
)

call npm run build
if errorlevel 1 goto failed
call npm run typecheck
if errorlevel 1 goto failed
call npm test
if errorlevel 1 goto failed
call npm run demo
if errorlevel 1 goto failed

echo.
echo Completed successfully. Press any key to close this window.
pause >nul
exit /b 0

:node_missing
echo Node.js is not installed or not on PATH. Install Node.js 22.13 or later, then reopen this file.
goto failed

:npm_missing
echo npm is not installed or not on PATH. Install Node.js 22.13 or later, then reopen this file.
goto failed

:failed
echo.
echo The run stopped because a step failed. Read the error above and send a screenshot of it.
pause
exit /b 1
