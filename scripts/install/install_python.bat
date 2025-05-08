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
:: Main script starts here
call :print_yellow "Checking for Python..."

where python >nul 2>&1
if errorlevel 1 (
    call :print_red "Python not found. Installing..."
    
    :: Try with winget first
    call :print_blue "Trying to install Python with winget..."
    winget install --id Python.Python.3.11 -e --source winget
    
    if errorlevel 1 (
        call :print_yellow "Winget installation failed. Trying direct download..."
        
        :: Download Python installer
        set "PYTHON_VERSION=3.11.4"
        set "PYTHON_INSTALLER=%DOWNLOAD_DIR%\python-%PYTHON_VERSION%-amd64.exe"
        call :print_blue "Downloading Python installer to %PYTHON_INSTALLER%..."
        powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe' -OutFile '%PYTHON_INSTALLER%'"
        
        if not exist "%PYTHON_INSTALLER%" (
            call :print_red "Error: Failed to download Python installer."
            exit /b 1
        )
        
        call :print_blue "Running Python installer..."
        "%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1
        
        if errorlevel 1 (
            call :print_red "Error: Python installation failed."
            exit /b 1
        )
    )
    
    :: Update PATH to include Python
    call :print_blue "Updating system PATH..."
    setx PATH "%PATH%;%USERPROFILE%\AppData\Local\Programs\Python\Python311;%USERPROFILE%\AppData\Local\Programs\Python\Python311\Scripts" /M
    set "PATH=%PATH%;%USERPROFILE%\AppData\Local\Programs\Python\Python311;%USERPROFILE%\AppData\Local\Programs\Python\Python311\Scripts"
    
    :: Verify installation
    call :print_blue "Waiting for installation to complete..."
    timeout /t 3 /nobreak >nul
)

python --version
if errorlevel 1 (
    call :print_red "Error: Python still not found after installation."
    exit /b 1
)

call :print_green "Python found: OK"