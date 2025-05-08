@echo off
setlocal

set "ROOT_DIR=%~1"
set "DEPS_DIR=%~2"
set "INSTALL_DIR=%~3"
set "BUILD_DIR=%~4"
set "DOWNLOAD_DIR=%~5"
set "VCPKG_DIR=%~6"

echo Setting environment variables...

:: Add essential directories to PATH
:: IMPORTANT: Use quotes around paths to handle spaces and special characters
:: Avoid using setx with complex paths to prevent escaping issues
echo Setting system PATH variables...
set "PATH_UPDATE=%DEPS_DIR%\bin;%INSTALL_DIR%\bin;%VCPKG_DIR%"

:: Create a temporary file to store the PATH update
set "TEMP_FILE=%TEMP%\path_update.bat"
echo @echo off > "%TEMP_FILE%"
echo setx PATH "%%PATH%%;%PATH_UPDATE%" /M >> "%TEMP_FILE%"
call "%TEMP_FILE%" >nul 2>&1
del "%TEMP_FILE%"

:: Set VCPKG environment variables
:: Use cache to speed up builds
set "VCPKG_DEFAULT_BINARY_CACHE=%DEPS_DIR%\vcpkg_cache"
if not exist "%VCPKG_DEFAULT_BINARY_CACHE%" (
    mkdir "%VCPKG_DEFAULT_BINARY_CACHE%"
)

:: Set VCPKG environment variables using simpler approach
:: Create and call temporary files to set each environment variable
echo Setting VCPKG variables...
set "TEMP_FILE=%TEMP%\vcpkg_env.bat"
echo @echo off > "%TEMP_FILE%"
echo setx VCPKG_DEFAULT_BINARY_CACHE "%VCPKG_DEFAULT_BINARY_CACHE%" /M >> "%TEMP_FILE%"
call "%TEMP_FILE%" >nul 2>&1
del "%TEMP_FILE%"

set "TEMP_FILE=%TEMP%\vcpkg_flags.bat"
echo @echo off > "%TEMP_FILE%"
echo setx VCPKG_FEATURE_FLAGS "binarycaching,manifests" /M >> "%TEMP_FILE%"
call "%TEMP_FILE%" >nul 2>&1
del "%TEMP_FILE%"

:: Avoid modifying LIB and INCLUDE which are set by Visual Studio

echo Environment variables set successfully.
exit /b 0