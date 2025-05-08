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
call :print_yellow "Checking for Ninja..."

where ninja >nul 2>&1
if errorlevel 1 (
    echo Ninja not found. Installing...
    
    :: Try with winget first
    echo Trying to install Ninja with winget...
    winget install --id Ninja-build.Ninja -e --source winget
    
    if errorlevel 1 (
        call :print_yellow "Winget installation failed. Trying direct download..."
        
        :: Download Ninja zip
        set "NINJA_VERSION=1.11.1"
        set "NINJA_ZIP=%DOWNLOAD_DIR%\ninja-%NINJA_VERSION%-win.zip"
        set "NINJA_EXTRACT_DIR=%DOWNLOAD_DIR%\ninja"
        set "NINJA_INSTALL_DIR=C:\ninja"
        
        echo Downloading Ninja...
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/ninja-build/ninja/releases/download/v%NINJA_VERSION%/ninja-win.zip' -OutFile '%NINJA_ZIP%'"
        
        if not exist "%NINJA_ZIP%" (
            call :print_red "Error: Failed to download Ninja."
            exit /b 1
        )
        
        echo Extracting Ninja...
        if not exist "%NINJA_EXTRACT_DIR%" mkdir "%NINJA_EXTRACT_DIR%"
        powershell -Command "Expand-Archive -Path '%NINJA_ZIP%' -DestinationPath '%NINJA_EXTRACT_DIR%' -Force"
        
        echo Installing Ninja...
        if not exist "%NINJA_INSTALL_DIR%" mkdir "%NINJA_INSTALL_DIR%"
        copy /Y "%NINJA_EXTRACT_DIR%\ninja.exe" "%NINJA_INSTALL_DIR%"
        
        :: Update PATH to include Ninja
        setx PATH "%PATH%;%NINJA_INSTALL_DIR%" /M
        set "PATH=%PATH%;%NINJA_INSTALL_DIR%"
        
        :: Clean up
        rd /s /q "%NINJA_EXTRACT_DIR%" >nul 2>&1
        del "%NINJA_ZIP%" >nul 2>&1
    )
    
    :: Verify installation
    timeout /t 3 /nobreak >nul
)

ninja --version
if errorlevel 1 (
    call :print_red "Error: Ninja still not found after installation."
    exit /b 1
)

call :print_green "Ninja found: OK"
exit /b 0