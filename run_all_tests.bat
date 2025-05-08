@echo off
setlocal

echo ===================================
echo C++26 Project Template Tests
echo ===================================
echo.

:: Skip the vcpkg check for testing purposes
set "SKIP_VCPKG_CHECK=1"

:: Check if setup has been completed
if not "%SKIP_VCPKG_CHECK%"=="1" (
    if not exist "deps\vcpkg\vcpkg.exe" (
        echo Setup has not been completed yet.
        echo.
        echo Would you like to run setup.bat now? (Y/N)
        set /p CHOICE=
        if /i "%CHOICE%"=="Y" (
            echo Running setup.bat...
            call setup.bat
            if %ERRORLEVEL% NEQ 0 (
                echo.
                echo Setup failed. Please run setup.bat manually and fix any issues.
                exit /b 1
            )
        ) else (
            echo.
            echo Please run setup.bat before running tests.
            exit /b 1
        )
    )
)

:: Check for Visual Studio
set "VS_FOUND=0"
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" set "VS_FOUND=1"

if "%VS_FOUND%"=="0" (
    echo WARNING: Visual Studio with C++ workload not found.
    echo Some tests requiring Visual Studio environment might fail.
    echo.
    echo Press any key to continue anyway or Ctrl+C to cancel...
    pause > nul
)

echo Running all tests to verify setup...
echo.

echo [1/2] Running simple direct compilation test
call scripts\build\test_cpp26_simple.bat
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Direct compilation test failed.
    echo Please check your Clang installation and C++26 support.
    exit /b 1
)

echo.
echo [2/2] Running CMake + Ninja build test
call scripts\build\test_cmake_ninja.bat
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: CMake + Ninja build test failed.
    echo Please check your CMake, Ninja, and Clang installations.
    exit /b 1
)

echo.
echo ===================================
echo All tests passed successfully!
echo ===================================
echo.
echo Your C++26 development environment is correctly set up.
echo You can now start developing C++26 projects with CMake and Ninja.
echo.

exit /b 0 