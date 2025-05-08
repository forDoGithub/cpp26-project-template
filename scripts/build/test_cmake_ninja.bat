@echo off
setlocal enabledelayedexpansion

echo ===================================
echo C++26 Project with CMake and Ninja
echo ===================================
echo.

:: Setup paths - adjusted for running from scripts/build directory
set "ROOT_DIR=%~dp0..\..\"
set "PROJECT_DIR=%ROOT_DIR%example"
set "MAIN_CPP=%PROJECT_DIR%\src\main.cpp"
set "CMAKE_FILE=%PROJECT_DIR%\CMakeLists.txt"

:: Verify tools
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

:: Check for Ninja
where ninja >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Ninja not found in PATH
    exit /b 1
) else (
    echo Found Ninja:
    ninja --version
)

:: Check for Clang
set "USING_CLANG_CL=0"
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
        set "USING_CLANG_CL=1"
        echo Found clang-cl:
        clang-cl --version | findstr version
    ) else (
        echo ERROR: Neither clang++ nor clang-cl found in PATH
        exit /b 1
    )
)

:: Clean and create project directory
echo Setting up project directory...
if exist "%PROJECT_DIR%" (
    rmdir /s /q "%PROJECT_DIR%"
)
mkdir "%PROJECT_DIR%"
cd "%PROJECT_DIR%"

:: Source directory structure
mkdir src

:: Create main.cpp file directly
echo // main.cpp - Test of C++26 features > "%MAIN_CPP%"
echo #include ^<iostream^> >> "%MAIN_CPP%"
echo #include ^<string^> >> "%MAIN_CPP%"
echo. >> "%MAIN_CPP%"
echo // Check for C++26 features >> "%MAIN_CPP%"
echo #if __has_include^(^<print^>^) >> "%MAIN_CPP%"
echo #include ^<print^> >> "%MAIN_CPP%"
echo #define HAS_PRINT 1 >> "%MAIN_CPP%"
echo #else >> "%MAIN_CPP%"
echo #define HAS_PRINT 0 >> "%MAIN_CPP%"
echo #endif >> "%MAIN_CPP%"
echo. >> "%MAIN_CPP%"
echo int main() { >> "%MAIN_CPP%"
echo     std::cout ^<^< "C++26 Feature Test with CMake + Ninja + Clang\n\n"; >> "%MAIN_CPP%"
echo. >> "%MAIN_CPP%"
echo #if HAS_PRINT >> "%MAIN_CPP%"
echo     std::println("SUCCESS: std::print is available!"); >> "%MAIN_CPP%"
echo     int value = 42; >> "%MAIN_CPP%"
echo     std::string name = "C++26"; >> "%MAIN_CPP%"
echo     std::print("Formatted output: {0} = {1}\n", name, value); >> "%MAIN_CPP%"
echo #else >> "%MAIN_CPP%"
echo     std::cout ^<^< "std::print is not available\n"; >> "%MAIN_CPP%"
echo #endif >> "%MAIN_CPP%"
echo. >> "%MAIN_CPP%"
echo     std::cout ^<^< "\nCompiler Information:\n"; >> "%MAIN_CPP%"
echo     std::cout ^<^< "Clang version: " ^<^< __clang_major__ ^<^< "." ^<^< __clang_minor__ ^<^< "\n"; >> "%MAIN_CPP%"
echo     std::cout ^<^< "__cplusplus = " ^<^< __cplusplus ^<^< "\n"; >> "%MAIN_CPP%"
echo. >> "%MAIN_CPP%"
echo     return 0; >> "%MAIN_CPP%"
echo } >> "%MAIN_CPP%"

:: Create CMakeLists.txt
echo Creating CMakeLists.txt...
echo cmake_minimum_required(VERSION 3.20) > "%CMAKE_FILE%"
echo. >> "%CMAKE_FILE%"
echo project(Cpp26Example LANGUAGES CXX) >> "%CMAKE_FILE%"
echo. >> "%CMAKE_FILE%"
echo # Set C++26 standard >> "%CMAKE_FILE%"
echo set(CMAKE_CXX_STANDARD 26) >> "%CMAKE_FILE%"
echo set(CMAKE_CXX_STANDARD_REQUIRED ON) >> "%CMAKE_FILE%"
echo. >> "%CMAKE_FILE%"
echo # Add executable >> "%CMAKE_FILE%"
echo add_executable(${PROJECT_NAME} src/main.cpp) >> "%CMAKE_FILE%"
echo. >> "%CMAKE_FILE%"
echo # Compiler-specific options >> "%CMAKE_FILE%"
echo if(CMAKE_CXX_COMPILER_ID MATCHES "Clang") >> "%CMAKE_FILE%"
echo   if(MSVC) >> "%CMAKE_FILE%"
echo     target_compile_options(${PROJECT_NAME} PRIVATE /std:c++latest) >> "%CMAKE_FILE%"
echo   else() >> "%CMAKE_FILE%"
echo     target_compile_options(${PROJECT_NAME} PRIVATE -std=c++2c) >> "%CMAKE_FILE%"
echo   endif() >> "%CMAKE_FILE%"
echo endif() >> "%CMAKE_FILE%"

:: Create build directory
echo Creating build directory...
mkdir build
cd build

:: Setup Visual Studio environment 
echo Setting up Visual Studio environment...
set "VS_ENV_SET=0"

:: Try to use our setup script first
if exist "%ROOT_DIR%scripts\setup\setup_vs_env.bat" (
    echo Using setup_vs_env.bat script...
    
    :: Call setup_vs_env.bat and get the temporary file path
    for /f "tokens=*" %%i in ('call "%ROOT_DIR%scripts\setup\setup_vs_env.bat" 2^>nul') do (
        set "VS_ENV_FILE=%%i"
    )
    
    :: If we got a file path, source the environment variables from it
    if defined VS_ENV_FILE (
        if exist "!VS_ENV_FILE!" (
            call "!VS_ENV_FILE!"
            del "!VS_ENV_FILE!" >nul 2>&1
            set "VS_ENV_SET=1"
            echo Visual Studio environment set up successfully.
        ) else (
            echo Warning: Environment file not found at: !VS_ENV_FILE!
        )
    ) else (
        echo setup_vs_env.bat did not return a valid environment file path
    )
)

:: If our script didn't work, try some common paths
if "%VS_ENV_SET%"=="0" (
    echo Trying common Visual Studio paths...
    
    :: Define environment variable for Program Files folders
    set "PF=%ProgramFiles%"
    set "PF86=%ProgramFiles(x86)%"
    if not defined PF86 set "PF86=%ProgramFiles%"
    
    if exist "%PF%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        call "%PF%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "VS_ENV_SET=1"
    ) else if exist "%PF%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        call "%PF%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "VS_ENV_SET=1"
    ) else if exist "%PF%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        call "%PF%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "VS_ENV_SET=1"
    ) else if exist "%PF%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
        call "%PF%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "VS_ENV_SET=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        call "%PF86%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "VS_ENV_SET=1"
    )
)

:: Configure and build with CMake and Ninja
echo Configuring with CMake and Ninja...

if "%USING_CLANG_CL%"=="1" (
    :: Use MSVC-compatible flags for clang-cl
    cmake -G "Ninja" -DCMAKE_C_COMPILER="%CLANG_C%" -DCMAKE_CXX_COMPILER="%CLANG_CXX%" -DCMAKE_CXX_FLAGS="/std:c++latest" ..
) else (
    :: Try standard compilation first
    cmake -G "Ninja" -DCMAKE_C_COMPILER="%CLANG_C%" -DCMAKE_CXX_COMPILER="%CLANG_CXX%" -DCMAKE_CXX_FLAGS="-std=c++2c" ..
)

if %ERRORLEVEL% NEQ 0 (
    echo First attempt failed, trying alternative approaches...
    
    if "%USING_CLANG_CL%"=="1" (
        :: Retry with more explicit MSVC settings for clang-cl
        cmake -G "Ninja" -DCMAKE_C_COMPILER="%CLANG_C%" -DCMAKE_CXX_COMPILER="%CLANG_CXX%" -DCMAKE_CXX_FLAGS="/std:c++latest" -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY ..
    ) else (
        :: Try with libc++ for clang++
        echo Trying with libc++ instead of MSVC libraries...
        cmake -G "Ninja" -DCMAKE_C_COMPILER="%CLANG_C%" -DCMAKE_CXX_COMPILER="%CLANG_CXX%" -DCMAKE_CXX_FLAGS="-std=c++2c -stdlib=libc++" -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++" ..
    )
    
    if %ERRORLEVEL% NEQ 0 (
        :: Last resort - try static library approach
        echo Trying static library approach as last resort...
        cmake -G "Ninja" -DCMAKE_C_COMPILER="%CLANG_C%" -DCMAKE_CXX_COMPILER="%CLANG_CXX%" -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY ..
        
        if %ERRORLEVEL% NEQ 0 (
            echo ERROR: CMake configuration failed after all attempts
            echo.
            echo This may be due to:
            echo 1. Missing Visual Studio installation
            echo 2. Incompatible Clang version
            echo 3. Missing CMake or Ninja
            echo.
            echo Please run setup.bat to install all required dependencies.
            exit /b 1
        )
    )
)

:: Build the project
echo Building with Ninja...
ninja

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    exit /b 1
)

:: Run the executable
echo Running the C++26 test program...
echo.
Cpp26Example.exe

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Program execution failed
    exit /b 1
)

echo.
echo ===================================
echo CMake + Ninja Test Successful!
echo ===================================
echo.
echo Your C++26 CMake + Ninja environment is working correctly!
echo.

cd "%~dp0"
exit /b 0 