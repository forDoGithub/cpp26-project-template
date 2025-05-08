@echo off
setlocal

echo ===================================
echo C++26 Modern Template Build Script
echo ===================================
echo.

:: Set paths
set "ROOT_DIR=%~dp0.."
set "BUILD_DIR=%ROOT_DIR%\build"
set "INSTALL_DIR=%ROOT_DIR%\install"

:: Parse command line arguments
set "BUILD_TYPE=Release"
set "GEN_TYPE=Ninja"
set "BUILD_TESTS=ON"
set "COMPILER="

:parse_args
if "%1"=="" goto :args_done
if /i "%1"=="--debug" set "BUILD_TYPE=Debug" & goto :next_arg
if /i "%1"=="--release" set "BUILD_TYPE=Release" & goto :next_arg
if /i "%1"=="--ninja" set "GEN_TYPE=Ninja" & goto :next_arg
if /i "%1"=="--vs" set "GEN_TYPE=Visual Studio 17 2022" & goto :next_arg
if /i "%1"=="--tests" set "BUILD_TESTS=ON" & goto :next_arg
if /i "%1"=="--no-tests" set "BUILD_TESTS=OFF" & goto :next_arg
if /i "%1"=="--clang" set "COMPILER=clang" & goto :next_arg
if /i "%1"=="--msvc" set "COMPILER=msvc" & goto :next_arg
if /i "%1"=="--help" goto :show_help

echo Unknown argument: %1
goto :show_help

:next_arg
shift
goto :parse_args

:show_help
echo.
echo Usage: build.bat [options]
echo.
echo Options:
echo   --debug             Build in Debug mode
echo   --release           Build in Release mode (default)
echo   --ninja             Use Ninja build system (default)
echo   --vs                Use Visual Studio generator
echo   --tests             Build tests (default)
echo   --no-tests          Don't build tests
echo   --clang             Use clang compiler
echo   --msvc              Use MSVC compiler
echo   --help              Show this help message
echo.
exit /b 1

:args_done
echo Build configuration:
echo   Build Type:         %BUILD_TYPE%
echo   Generator:          %GEN_TYPE%
echo   Build Tests:        %BUILD_TESTS%
echo   Compiler:           %COMPILER%
echo.

:: Check dependencies
echo Checking for required tools...

:: Check for CMake
where cmake >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake not found in PATH
    exit /b 1
) else (
    echo Found CMake:
    cmake --version | findstr version
)

:: Check for the configured generator
if "%GEN_TYPE%"=="Ninja" (
    where ninja >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Ninja not found in PATH
        exit /b 1
    ) else (
        echo Found Ninja:
        ninja --version
    )
)

:: Check compiler
if "%COMPILER%"=="clang" (
    where clang++ >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "CLANG_CXX=clang++"
        set "CLANG_C=clang"
        echo Found clang++:
        clang++ --version | findstr version
    ) else (
        where clang-cl >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            set "CLANG_CXX=clang-cl"
            set "CLANG_C=clang-cl"
            echo Found clang-cl:
            clang-cl --version | findstr version
        ) else (
            echo ERROR: Neither clang++ nor clang-cl found in PATH
            exit /b 1
        )
    )
)

:: Create build directory
if not exist "%BUILD_DIR%" (
    echo Creating build directory...
    mkdir "%BUILD_DIR%"
)

:: Navigate to build directory
cd "%BUILD_DIR%"

:: Configure with CMake
echo Configuring with CMake...

set "CMAKE_ARGS=-DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DBUILD_TESTING=%BUILD_TESTS%"

if "%GEN_TYPE%"=="Ninja" (
    set "CMAKE_ARGS=%CMAKE_ARGS% -G Ninja"
) else (
    set "CMAKE_ARGS=%CMAKE_ARGS% -G "%GEN_TYPE%""
)

if "%COMPILER%"=="clang" (
    set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_C_COMPILER=%CLANG_C% -DCMAKE_CXX_COMPILER=%CLANG_CXX%"
)

cmake %CMAKE_ARGS% ..

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

:: Build the project
echo Building the project...
cmake --build . --config %BUILD_TYPE%

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    exit /b 1
)

:: Run tests if enabled
if "%BUILD_TESTS%"=="ON" (
    echo Running tests...
    ctest -C %BUILD_TYPE% --output-on-failure
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Tests failed
        exit /b 1
    )
)

echo.
echo ===================================
echo Build completed successfully!
echo ===================================
echo.
echo Build directory: %BUILD_DIR%
echo.

:: Return to original directory
cd "%ROOT_DIR%"
exit /b 0 