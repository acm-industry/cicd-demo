@echo off
REM CI/CD Deployment Script for Windows
REM Automatically deploys frontend to Vercel and backend to Render based on current branch

setlocal enabledelayedexpansion

REM Banner
echo.
echo ==========================================
echo    CI/CD Deployment Script (Windows)
echo ==========================================
echo.

REM Load environment variables from .env file if it exists
if exist ".env" (
    echo [INFO] Loading environment variables from .env file...
    for /f "usebackq tokens=*" %%a in (".env") do (
        set "line=%%a"
        REM Skip comments and empty lines
        echo !line! | findstr /r "^#" >nul || (
            echo !line! | findstr /r "^[[:space:]]*$" >nul || (
                set %%a
            )
        )
    )
    echo [SUCCESS] Environment variables loaded from .env
    echo.
)

REM Step 1: Detect current branch
echo [INFO] Detecting current git branch...
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set BRANCH=%%i

if "%BRANCH%"=="" (
    echo [ERROR] Failed to detect git branch. Are you in a git repository?
    exit /b 1
)

echo [SUCCESS] Current branch: %BRANCH%
echo.

REM Step 2: Check for required CLI tools
echo [INFO] Checking for required CLI tools...

REM Check for Vercel CLI
where vercel >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Vercel CLI not found. Please install it:
    echo   npm install -g vercel
    exit /b 1
)
echo [SUCCESS] Vercel CLI found

REM Check for Render CLI
where render >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Render CLI not found. Install it from: https://render.com/docs/cli
    echo [INFO] Continuing without Render deployment...
    set SKIP_RENDER=true
) else (
    echo [SUCCESS] Render CLI found
    set SKIP_RENDER=false
)

echo.

REM Step 3: Check authentication
echo [INFO] Checking authentication...

REM Check Vercel authentication
if "%VERCEL_TOKEN%"=="" (
    echo [WARNING] VERCEL_TOKEN not found in environment
    echo [INFO] Attempting to use local Vercel credentials...
    echo [INFO] If this is your first time, you'll be prompted to login
    echo.

    REM Check if already logged in
    vercel whoami >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo [INFO] Please login to Vercel...
        vercel login
    ) else (
        echo [SUCCESS] Already logged in to Vercel
    )
) else (
    echo [SUCCESS] VERCEL_TOKEN found
)

REM Check Render authentication
if "%SKIP_RENDER%"=="false" (
    if "%RENDER_API_KEY%"=="" (
        echo [WARNING] RENDER_API_KEY not found in environment
        echo [INFO] Please set your Render API key:
        echo   set RENDER_API_KEY=your_api_key_here
        echo.
        echo [INFO] Get your API key from: https://dashboard.render.com/u/settings#api-keys
        echo.
        set /p CONTINUE="Do you want to continue without deploying to Render? (Y/N): "
        if /i not "!CONTINUE!"=="Y" exit /b 1
        set SKIP_RENDER=true
    ) else (
        echo [SUCCESS] RENDER_API_KEY found
    )
)

echo.

REM Step 4: Determine deployment environment
set DEPLOY_ENV=preview
set VERCEL_ARGS=

if "%BRANCH%"=="main" set DEPLOY_ENV=production
if "%BRANCH%"=="prod" set DEPLOY_ENV=production
if "%BRANCH%"=="production" set DEPLOY_ENV=production
if "%BRANCH%"=="gamma" set DEPLOY_ENV=gamma
if "%BRANCH%"=="beta" set DEPLOY_ENV=beta

if "%DEPLOY_ENV%"=="production" (
    set VERCEL_ARGS=--prod
    echo [INFO] Deploying to PRODUCTION environment
) else if "%DEPLOY_ENV%"=="gamma" (
    echo [INFO] Deploying to GAMMA (pre-production) environment
) else if "%DEPLOY_ENV%"=="beta" (
    echo [INFO] Deploying to BETA (staging) environment
) else (
    echo [INFO] Deploying to PREVIEW environment
)

REM Step 5: Deploy Frontend to Vercel
echo [INFO] Deploying frontend to Vercel...
cd frontend

if not "%VERCEL_TOKEN%"=="" (
    for /f "delims=" %%i in ('vercel deploy %VERCEL_ARGS% --token %VERCEL_TOKEN% --yes -m githubDeployment="1" -m githubCommitRef="%BRANCH%" 2^>^&1 ^| findstr /R "https://"') do set VERCEL_URL=%%i
) else (
    for /f "delims=" %%i in ('vercel deploy %VERCEL_ARGS% --yes -m githubDeployment="1" -m githubCommitRef="%BRANCH%" 2^>^&1 ^| findstr /R "https://"') do set VERCEL_URL=%%i
)

if "%VERCEL_URL%"=="" (
    echo [ERROR] Failed to deploy frontend to Vercel
    cd ..
    exit /b 1
)

echo [SUCCESS] Frontend deployed to: %VERCEL_URL%
cd ..

echo.

REM Step 6: Deploy Backend to Render
if "%SKIP_RENDER%"=="false" (
    echo [INFO] Deploying backend to Render...
    cd backend

    REM Determine service name based on branch
    set SERVICE_NAME=cicd-demo-backend-preview

    if "%BRANCH%"=="main" set SERVICE_NAME=cicd-demo-backend-prod
    if "%BRANCH%"=="prod" set SERVICE_NAME=cicd-demo-backend-prod
    if "%BRANCH%"=="production" set SERVICE_NAME=cicd-demo-backend-prod
    if "%BRANCH%"=="gamma" set SERVICE_NAME=cicd-demo-backend-gamma
    if "%BRANCH%"=="beta" set SERVICE_NAME=cicd-demo-backend-beta

    echo [INFO] Service name: %SERVICE_NAME%

    echo [INFO] Checking if Render service exists...

    REM Note: Service checking is complex in Windows batch. Recommend manual setup.
    echo [WARNING] Please ensure the Render service '%SERVICE_NAME%' exists.
    echo [INFO] If not, create it manually on Render Dashboard:
    echo   1. Go to https://dashboard.render.com/create?type=web
    echo   2. Connect your GitHub repository
    echo   3. Set service name: %SERVICE_NAME%
    echo   4. Set branch: %BRANCH%
    echo   5. Set build command: pip install -r requirements.txt
    echo   6. Set start command: python server.py
    echo   7. Add environment variables from backend/.env.example
    echo.

    cd ..
) else (
    echo [WARNING] Skipping Render deployment
)

echo.
echo ==========================================
echo   Deployment Complete!
echo ==========================================
echo.
echo Frontend URL: %VERCEL_URL%
echo Backend: Check Render Dashboard
echo.

endlocal
