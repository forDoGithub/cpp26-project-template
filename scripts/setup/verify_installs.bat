@echo off
setlocal

:: This script verifies that all required tools are installed correctly

echo Verifying installations...

:: Check for Git
echo Checking for Git...
where git >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    git --version
    echo Git found: OK
) else (
    echo Git not found
    exit /b 1
)

:: Check for CMake
echo Checking for CMake...
where cmake >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    cmake --version | findstr version
    echo CMake found: OK
) else (
    echo CMake not found
    exit /b 1
)

:: Check for Ninja
echo Checking for Ninja...
where ninja >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    ninja --version
    echo Ninja found: OK
) else (
    echo Ninja not found
    exit /b 1
)

:: Check for Python
echo Checking for Python...
where python >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    python --version
    echo Python found: OK
) else (
    where py >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        py --version
        echo Python found: OK
    ) else (
        echo Python not found
        exit /b 1
    )
)

:: Check for LLVM/Clang
echo Checking for LLVM/Clang...
where clang >nul 2>&1 || where clang++ >nul 2>&1 || where clang-cl >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    where clang++ >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        clang++ --version | findstr version
    ) else (
        where clang-cl >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            clang-cl --version | findstr version
        ) else (
            clang --version | findstr version
        )
    )
    echo LLVM/Clang found: OK
) else (
    echo LLVM/Clang not found
    exit /b 1
)

:: Check for ATL components using a robust approach
echo Checking for ATL components...

set "ATL_FOUND=0"
set "ATL_PATH="

:: Check if atlbase.h exists in VS2022 BuildTools
set "CHECK_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC"
if exist "%CHECK_PATH%" (
    for /d %%d in ("%CHECK_PATH%\*") do (
        if exist "%%d\atlmfc\include\atlbase.h" (
            set "ATL_FOUND=1"
            set "ATL_PATH=%%d\atlmfc\include"
        )
    )
)

:: Check if atlbase.h exists in VS2022 Community
if "%ATL_FOUND%"=="0" (
    set "CHECK_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC"
    if exist "%CHECK_PATH%" (
        for /d %%d in ("%CHECK_PATH%\*") do (
            if exist "%%d\atlmfc\include\atlbase.h" (
                set "ATL_FOUND=1"
                set "ATL_PATH=%%d\atlmfc\include"
            )
        )
    )
)

:: Check if atlbase.h exists in VS2022 Professional
if "%ATL_FOUND%"=="0" (
    set "CHECK_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC"
    if exist "%CHECK_PATH%" (
        for /d %%d in ("%CHECK_PATH%\*") do (
            if exist "%%d\atlmfc\include\atlbase.h" (
                set "ATL_FOUND=1"
                set "ATL_PATH=%%d\atlmfc\include"
            )
        )
    )
)

:: Check if atlbase.h exists in VS2022 Enterprise
if "%ATL_FOUND%"=="0" (
    set "CHECK_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC"
    if exist "%CHECK_PATH%" (
        for /d %%d in ("%CHECK_PATH%\*") do (
            if exist "%%d\atlmfc\include\atlbase.h" (
                set "ATL_FOUND=1"
                set "ATL_PATH=%%d\atlmfc\include"
            )
        )
    )
)

:: Check if atlbase.h exists in VS2022 BuildTools (Program Files)
if "%ATL_FOUND%"=="0" (
    set "CHECK_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC"
    if exist "%CHECK_PATH%" (
        for /d %%d in ("%CHECK_PATH%\*") do (
            if exist "%%d\atlmfc\include\atlbase.h" (
                set "ATL_FOUND=1"
                set "ATL_PATH=%%d\atlmfc\include"
            )
        )
    )
)

:: Display ATL check result
if "%ATL_FOUND%"=="1" (
    echo Found ATL at: "%ATL_PATH%"
    echo ATL components found: OK
) else (
    echo ATL components not found. This may cause issues with some libraries.
    echo We recommend installing Visual Studio ATL components for complete functionality.
)

:: Check for vcpkg
echo Checking for vcpkg...

:: First check if vcpkg is in PATH
where vcpkg >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    vcpkg version
    echo vcpkg found in PATH: OK
    goto :vcpkg_found
)

:: Then check in the expected deps directory location
set "VCPKG_ROOT=%~dp0..\..\deps\vcpkg"
set "VCPKG_EXE=%VCPKG_ROOT%\vcpkg.exe"

if exist "%VCPKG_EXE%" (
    "%VCPKG_EXE%" version
    echo vcpkg found in deps directory: OK
    goto :vcpkg_found
)

:: If we get here, vcpkg wasn't found
echo vcpkg not found. This may cause issues with library installations.
exit /b 1

:vcpkg_found
echo All required tools verified successfully.
exit /b 0