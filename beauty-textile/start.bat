@echo off
title Beauty Textile — Shop Server
color 0A
cls

echo ============================================
echo   Beauty Textile — Starting Shop Server
echo ============================================
echo.

:: ── CONFIG ──────────────────────────────────────────────────────
set PROJECT_DIR=C:\BT\beauty-textile
set FRONTEND_DIR=%PROJECT_DIR%\frontend
set BACKEND_DIR=%PROJECT_DIR%\backend
set STATIC_DIR=%BACKEND_DIR%\src\main\resources\static
set JAR_DIR=%BACKEND_DIR%\target
:: Change this if your MySQL password is different from root
set DB_PASSWORD=root
:: Cloudflare tunnel URL (update when your tunnel URL changes)
set TUNNEL_URL=https://beautytextile.trycloudflare.com
:: ────────────────────────────────────────────────────────────────

:: Step 1 — Build Angular for production
echo [1/4] Building Angular frontend...
cd /d %FRONTEND_DIR%
call npx ng build --configuration production
if %errorlevel% neq 0 (
    echo ERROR: Angular build failed. Check errors above.
    pause
    exit /b 1
)
echo Angular build complete.
echo.

:: Step 2 — Copy Angular build into Spring Boot static folder
echo [2/4] Copying Angular build to Spring Boot...
if exist "%STATIC_DIR%" (
    rd /s /q "%STATIC_DIR%"
)
mkdir "%STATIC_DIR%"
xcopy /E /I /Q "%FRONTEND_DIR%\dist\beauty-textile\browser\*" "%STATIC_DIR%\"
echo Angular files copied to backend/src/main/resources/static/
echo.

:: Step 3 — Build Spring Boot JAR
echo [3/4] Building Spring Boot JAR...
cd /d %BACKEND_DIR%
call mvnw.cmd clean package -DskipTests -B -q
if %errorlevel% neq 0 (
    echo ERROR: Maven build failed. Check errors above.
    pause
    exit /b 1
)
echo Spring Boot JAR built.
echo.

:: Step 4 — Start Spring Boot (with local profile)
echo [4/4] Starting Spring Boot server on port 8080...
cd /d %BACKEND_DIR%
start "Beauty Textile Backend" java ^
  -Dspring.profiles.active=local ^
  -DDB_PASSWORD=%DB_PASSWORD% ^
  -DTUNNEL_URL=%TUNNEL_URL% ^
  -Djava.security.egd=file:/dev/./urandom ^
  -jar target\beauty-textile-backend-1.0.0.jar

:: Wait for Spring Boot to start
echo Waiting for server to start...
timeout /t 10 /nobreak >nul

:: Step 5 — Start Cloudflare Tunnel
echo.
echo ============================================
echo   Starting Cloudflare Tunnel...
echo   URL: %TUNNEL_URL%
echo ============================================
echo.
echo NOTE: If tunnel URL changes, update:
echo   1. TUNNEL_URL in this file (start.bat)
echo   2. allowed-origins in application-local.yml
echo.

:: Use cloudflared if installed, otherwise show instructions
where cloudflared >nul 2>&1
if %errorlevel% equ 0 (
    cloudflared tunnel --url http://localhost:8080
) else (
    echo cloudflared not found!
    echo Download from: https://github.com/cloudflare/cloudflared/releases/latest
    echo Install cloudflared.exe and add to PATH, then re-run this script.
    echo.
    echo OR run manually:
    echo   cloudflared tunnel --url http://localhost:8080
    pause
)
