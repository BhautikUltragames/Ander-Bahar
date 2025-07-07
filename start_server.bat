@echo off
+REM Kill any existing Node.js server to free port 8080
+taskkill /F /IM node.exe /T >nul 2>&1
echo Starting Andar Bahar WebSocket Server...
echo.

cd server

echo Installing dependencies...
call node-v22.17.0-win-x64\npm.cmd install

echo.
echo Starting server on port 8080...
echo Press Ctrl+C to stop the server
echo.

:start
call node-v22.17.0-win-x64\node.exe server.js
echo Server stopped. Restarting in 3 seconds...
timeout /t 3 /nobreak >nul
goto start

pause 