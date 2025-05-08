@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~1"
set "VCPKG_DIR=%~2"
set "VCPKG_COMMIT=%~3"

echo Setting up vcpkg...

:: Check if vcpkg directory exists
if exist "%VCPKG_DIR%" (
    echo vcpkg directory already exists at: "%VCPKG_DIR%"
    echo Checking if it's a valid vcpkg installation...
    
    if not exist "%VCPKG_DIR%\vcpkg.exe" (
        echo Invalid vcpkg installation. Removing and reinstalling...
        rmdir /s /q "%VCPKG_DIR%"
        goto :install_vcpkg
    )
    
    echo Updating existing vcpkg...
    cd "%VCPKG_DIR%"
    git pull
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to update vcpkg. Reinstalling...
        cd "%ROOT_DIR%"
        rmdir /s /q "%VCPKG_DIR%"
        goto :install_vcpkg
    )
    
    echo Bootstrapping vcpkg...
    call bootstrap-vcpkg.bat -disableMetrics
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to bootstrap vcpkg. Reinstalling...
        cd "%ROOT_DIR%"
        rmdir /s /q "%VCPKG_DIR%"
        goto :install_vcpkg
    )
    
    cd "%ROOT_DIR%"
) else (
    :install_vcpkg
    echo Installing vcpkg...
    
    :: Create vcpkg directory if it doesn't exist
    mkdir "%VCPKG_DIR%" 2>nul
    
    :: Clone vcpkg repository
    echo Cloning vcpkg repository to "%VCPKG_DIR%"...
    git clone https://github.com/microsoft/vcpkg.git "%VCPKG_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to clone vcpkg repository.
        exit /b 1
    )
    
    :: Checkout specific commit if specified
    if not "%VCPKG_COMMIT%"=="" (
        cd "%VCPKG_DIR%"
        echo Checking out vcpkg commit: %VCPKG_COMMIT%...
        git checkout %VCPKG_COMMIT%
        if %ERRORLEVEL% NEQ 0 (
            echo Failed to checkout vcpkg commit: %VCPKG_COMMIT%
            cd "%ROOT_DIR%"
            exit /b 1
        )
        cd "%ROOT_DIR%"
    )
    
    :: Bootstrap vcpkg
    echo Bootstrapping vcpkg...
    cd "%VCPKG_DIR%"
    call bootstrap-vcpkg.bat -disableMetrics
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to bootstrap vcpkg.
        cd "%ROOT_DIR%"
        exit /b 1
    )
    cd "%ROOT_DIR%"
)

:: Configure vcpkg with triplet and cache
echo Configuring vcpkg to use binary caching...
set "VCPKG_CACHE_DIR=%ROOT_DIR%deps\vcpkg_cache"
if not exist "%VCPKG_CACHE_DIR%" (
    mkdir "%VCPKG_CACHE_DIR%" 2>nul
)

:: Set vcpkg environment variables
setx VCPKG_DEFAULT_BINARY_CACHE "%VCPKG_CACHE_DIR%" /M >nul 2>&1
setx VCPKG_FEATURE_FLAGS "binarycaching,manifests" /M >nul 2>&1

:: Create a response file for vcpkg to use precompiled binaries
echo Creating vcpkg configuration...
set "VCPKG_CONFIG_DIR=%VCPKG_DIR%\config"
if not exist "%VCPKG_CONFIG_DIR%" (
    mkdir "%VCPKG_CONFIG_DIR%" 2>nul
)

(
echo {
echo   "default-registry": {
echo     "kind": "git",
echo     "repository": "https://github.com/microsoft/vcpkg",
echo     "baseline": "%VCPKG_COMMIT%"
echo   },
echo   "registries": [],
echo   "features": {
echo     "binarycaching": true
echo   }
echo }
) > "%VCPKG_CONFIG_DIR%\vcpkg-configuration.json"

echo Successfully set up vcpkg at: "%VCPKG_DIR%"
exit /b 0