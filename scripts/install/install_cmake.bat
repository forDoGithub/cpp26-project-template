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

set "CMAKE_VERSION=%~2"

call :print_yellow "Checking for CMake..."

where cmake >nul 2>&1
if errorlevel 1 (
    echo CMake not found. Installing...
    
    :: Try with winget first
    echo Trying to install CMake with winget...
    winget install --id Kitware.CMake -e --source winget
    
    if errorlevel 1 (
        call :print_yellow "Winget installation failed. Trying direct download..."
        
        :: Download CMake installer
        set "CMAKE_INSTALLER=%DOWNLOAD_DIR%\cmake-%CMAKE_VERSION%-windows-x86_64.msi"
        echo Downloading CMake installer...
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.msi' -OutFile '%CMAKE_INSTALLER%'"
        
        if not exist "%CMAKE_INSTALLER%" (
            call :print_red "Error: Failed to download CMake installer."
            exit /b 1
        )
        
        echo Running CMake installer...
        msiexec /i "%CMAKE_INSTALLER%" /quiet /qn /norestart ALLUSERS=1 ADD_CMAKE_TO_PATH=System
        
        if errorlevel 1 (
            call :print_red "Error: CMake installation failed."
            exit /b 1
        )
    )
    
    :: Update PATH to include CMake
    setx PATH "%PATH%;C:\Program Files\CMake\bin" /M
    set "PATH=%PATH%;C:\Program Files\CMake\bin"
    
    :: Verify installation
    timeout /t 5 /nobreak >nul
)

cmake --version
if errorlevel 1 (
    call :print_red "Error: CMake still not found after installation."
    exit /b 1
)

call :print_green "CMake found: OK"
exit /b 0