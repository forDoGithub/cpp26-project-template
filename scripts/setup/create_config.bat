@echo off
:: Create configuration file
:: Parameters:
::   %1 - Config file path
::   %2 - Project name
::   %3 - C++ version
::   %4 - LLVM version
::   %5 - CMake version
::   %6 - vcpkg commit

set "CONFIG_FILE=%~1"
set "PROJECT_NAME=%~2"
set "CPP_VERSION=%~3"
set "LLVM_VERSION=%~4"
set "CMAKE_VERSION=%~5"
set "VCPKG_COMMIT=%~6"

if not exist "%CONFIG_FILE%" (
    echo Creating configuration file...
    echo {> "%CONFIG_FILE%"
    echo   "project_name": "%PROJECT_NAME%",>> "%CONFIG_FILE%"
    echo   "cpp_version": "%CPP_VERSION%",>> "%CONFIG_FILE%"
    echo   "llvm_version": "%LLVM_VERSION%",>> "%CONFIG_FILE%"
    echo   "cmake_version": "%CMAKE_VERSION%",>> "%CONFIG_FILE%"
    echo   "vcpkg_commit": "%VCPKG_COMMIT%",>> "%CONFIG_FILE%"
    echo   "setup_date": "%DATE%",>> "%CONFIG_FILE%"
    echo   "hot_reload_enabled": true,>> "%CONFIG_FILE%"
    echo   "modules_enabled": true>> "%CONFIG_FILE%"
    echo }>> "%CONFIG_FILE%"
    echo Configuration file created: %CONFIG_FILE%
)
exit /b 0