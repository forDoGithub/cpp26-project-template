@echo off
:: Install Python with colored output
:: Parameters:
::   %1 - Download directory

setlocal enabledelayedexpansion

set "DOWNLOAD_DIR=%~1"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%TEMP%"

goto :main

:: Define color functions
:print_red
    powershell -Command "Write-Host '%~1' -ForegroundColor Red"
    goto :eof

:print_green
    powershell -Command "Write-Host '%~1' -ForegroundColor Green"
    goto :eof

:print_yellow
    powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
    goto :eof

:print_blue
    powershell -Command "Write-Host '%~1' -ForegroundColor Blue"
    goto :eof

:main

call :print_yellow "Checking for Git..."

where git >nul 2>&1
if errorlevel 1 (
    echo Git not found. Installing...
    
    :: Try with winget first
    echo Trying to install Git with winget...
    winget install --id Git.Git -e --source winget
    
    if errorlevel 1 (
        call :print_yellow "Winget installation failed. Trying direct download..."
        
        :: Download Git installer
        set "GIT_VERSION=2.42.0.2"
        set "GIT_INSTALLER=%DOWNLOAD_DIR%\Git-%GIT_VERSION%-64-bit.exe"
        echo Downloading Git installer...
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe' -OutFile '%GIT_INSTALLER%'"
        
        if not exist "%GIT_INSTALLER%" (
            call :print_red "Error: Failed to download Git installer."
            exit /b 1
        )
        
        echo Running Git installer...
        "%GIT_INSTALLER%" /VERYSILENT /NORESTART
        
        if errorlevel 1 (
            call :print_red "Error: Git installation failed."
            exit /b 1
        )
    )
    
    :: Update PATH to include Git
    setx PATH "%PATH%;C:\Program Files\Git\bin" /M
    set "PATH=%PATH%;C:\Program Files\Git\bin"
    
    :: Verify installation
    timeout /t 3 /nobreak >nul
)

git --version
if errorlevel 1 (
    call :print_red "Error: Git still not found after installation."
    exit /b 1
)

call :print_green "Git found: OK"
exit /b 0