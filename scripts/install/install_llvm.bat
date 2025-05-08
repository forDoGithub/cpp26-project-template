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
set "LLVM_VERSION=%~2"

call :print_yellow "Checking for LLVM/Clang..."

where clang >nul 2>&1
if errorlevel 1 (
    echo LLVM/Clang not found. Installing...
    
    :: Try with winget first
    echo Trying to install LLVM with winget...
    winget install --id LLVM.LLVM -e --source winget
    
    if errorlevel 1 (
        call :print_yellow "Winget installation failed. Trying direct download..."
        
        :: Download LLVM installer
        set "LLVM_INSTALLER=%DOWNLOAD_DIR%\LLVM-%LLVM_VERSION%-win64.exe"
        echo Downloading LLVM installer...
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/llvm/llvm-project/releases/download/llvmorg-%LLVM_VERSION%/LLVM-%LLVM_VERSION%-win64.exe' -OutFile '%LLVM_INSTALLER%'"
        
        if not exist "%LLVM_INSTALLER%" (
            call :print_red "Error: Failed to download LLVM installer."
            exit /b 1
        )
        
        echo Running LLVM installer...
        "%LLVM_INSTALLER%" /S /D=C:\Program Files\LLVM
        
        if errorlevel 1 (
            call :print_red "Error: LLVM installation failed."
            exit /b 1
        )
    )
    
    :: Update PATH to include LLVM bin directory
    setx PATH "%PATH%;C:\Program Files\LLVM\bin" /M
    set "PATH=%PATH%;C:\Program Files\LLVM\bin"
    
    :: Verify installation
    timeout /t 5 /nobreak >nul
)

clang --version
if errorlevel 1 (
    call :print_red "Error: Clang still not found after installation."
    exit /b 1
)

call :print_green "LLVM/Clang found: OK"
exit /b 0