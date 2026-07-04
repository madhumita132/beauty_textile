@echo off
title Beauty Textile — Dev Mode
color 0B
cls

echo ============================================
echo   Beauty Textile — Development Mode
echo   Backend : http://localhost:8080
echo   Frontend: http://localhost:4200
echo ============================================
echo.

set PROJECT_DIR=C:\BT\beauty-textile

:: Start Spring Boot (dev profile — MySQL local)
echo Starting Spring Boot backend (dev profile)...
start "BT Backend" cmd /k "cd /d %PROJECT_DIR%\backend && mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev"

:: Wait a few seconds then start Angular dev server
timeout /t 5 /nobreak >nul

echo Starting Angular frontend dev server...
start "BT Frontend" cmd /k "cd /d %PROJECT_DIR%\frontend && npx ng serve --proxy-config proxy.conf.json"

echo.
echo Both servers starting in separate windows.
echo Frontend: http://localhost:4200
echo Backend:  http://localhost:8080
echo.
pause
