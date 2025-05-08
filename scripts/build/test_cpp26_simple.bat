@echo off
setlocal enabledelayedexpansion
title Simple C++26 Compilation Test

echo ===================================
echo C++26 Direct Compilation Test
echo ===================================
echo.

:: Setup test directory - adjusted for running from scripts/build directory
set "ROOT_DIR=%~dp0..\..\"
set "TEST_DIR=%ROOT_DIR%build\simple_test"
mkdir "%TEST_DIR%" 2>nul
cd "%TEST_DIR%"

echo Creating C++26 test file...

:: Create a simple C++ file with C++26 features
echo #include ^<iostream^> > test.cpp
echo #include ^<string^> >> test.cpp
echo. >> test.cpp
echo // Check for C++26 features >> test.cpp
echo #if __has_include(^<print^>) >> test.cpp
echo #include ^<print^> >> test.cpp
echo #define HAS_PRINT 1 >> test.cpp
echo #else >> test.cpp
echo #define HAS_PRINT 0 >> test.cpp
echo #endif >> test.cpp
echo. >> test.cpp
echo int main() { >> test.cpp
echo     std::cout ^<^< "C++26 Feature Test\n\n"; >> test.cpp
echo. >> test.cpp
echo     // Test C++26 std::print if available >> test.cpp
echo     #if HAS_PRINT >> test.cpp
echo         std::println("SUCCESS: std::print is available!"); >> test.cpp
echo         int value = 42; >> test.cpp
echo         std::string name = "C++26"; >> test.cpp
echo         std::print("Formatted output: {0} = {1}\n", name, value); >> test.cpp
echo     #else >> test.cpp
echo         std::cout ^<^< "std::print is not available\n"; >> test.cpp
echo     #endif >> test.cpp
echo. >> test.cpp
echo     std::cout ^<^< "\nCompiler Information:\n"; >> test.cpp
echo     std::cout ^<^< "Clang version: " ^<^< __clang_major__ ^<^< "." ^<^< __clang_minor__ ^<^< "\n"; >> test.cpp
echo     std::cout ^<^< "__cplusplus = " ^<^< __cplusplus ^<^< "\n"; >> test.cpp
echo. >> test.cpp
echo     return 0; >> test.cpp
echo } >> test.cpp

echo Compiling with clang++...

:: Try compiling with clang++
clang++ -std=c++2c test.cpp -o test_cpp26.exe

if %ERRORLEVEL% NEQ 0 (
    echo Compilation failed, trying with libc++...
    clang++ -std=c++2c -stdlib=libc++ test.cpp -o test_cpp26.exe
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Compilation failed. C++26 features may not be supported.
        cd "%~dp0"
        exit /b 1
    )
)

echo Running the C++26 test...
test_cpp26.exe

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Program execution failed.
    cd "%~dp0"
    exit /b 1
)

echo.
echo ===================================
echo C++26 Test Successful!
echo ===================================
echo.
echo Your C++26 compiler is working correctly!
echo.

cd "%~dp0"
exit /b 0 