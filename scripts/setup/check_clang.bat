@echo off
echo Checking Clang installation...

:: Check if clang++ exists
where clang++ >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Found clang++ in PATH
    set CLANG_EXE=clang++
    goto test_clang
)

:: Check if clang-cl exists
where clang-cl >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Found clang-cl in PATH
    set CLANG_EXE=clang-cl
    set USING_CLANG_CL=1
    goto test_clang
)

:: Check common install locations
if exist "C:\Program Files\LLVM\bin\clang++.exe" (
    echo Found clang++ at C:\Program Files\LLVM\bin\clang++.exe
    set CLANG_EXE="C:\Program Files\LLVM\bin\clang++.exe"
    goto test_clang
)

if exist "C:\Program Files\LLVM\bin\clang-cl.exe" (
    echo Found clang-cl at C:\Program Files\LLVM\bin\clang-cl.exe
    set CLANG_EXE="C:\Program Files\LLVM\bin\clang-cl.exe"
    set USING_CLANG_CL=1
    goto test_clang
)

echo ERROR: Clang not found. Please install LLVM/Clang.
exit /b 1

:test_clang
echo Testing Clang version...
%CLANG_EXE% --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run Clang.
    exit /b 1
)

echo.
echo ==========================================
echo Creating simple test file...
echo.

:: Create a simple C++ test file
echo #include ^<iostream^> > test.cpp
echo int main() { >> test.cpp
echo     std::cout ^<^< "Hello World!\n"; >> test.cpp
echo     return 0; >> test.cpp
echo } >> test.cpp

echo Test file created. Attempting to compile...

if defined USING_CLANG_CL (
    %CLANG_EXE% test.cpp -o test.exe /std:c++latest
) else (
    %CLANG_EXE% test.cpp -o test.exe -std=c++20
)

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed.
    exit /b 1
) else (
    echo Compilation successful! Running the test program...
    test.exe
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Program execution failed.
        exit /b 1
    ) else (
        echo Success! Clang is properly installed and working.
    )
)

echo Done! 