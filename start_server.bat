@echo off
REM Kill any existing Node.js server to free port 8080
taskkill /F /IM node.exe /T >nul 2>&1

cd server
echo Installing dependencies...
call node-v22.17.0-win-x64\npm.cmd install

echo Starting server on port 8080...
call node-v22.17.0-win-x64\node.exe server.js

pause 