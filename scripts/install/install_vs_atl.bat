@echo off
setlocal enabledelayedexpansion

set "DOWNLOAD_DIR=%~1"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%TEMP%"

echo Installing Visual Studio ATL components...

:: Check if ATL components are already installed
echo Checking for ATL components...

:: Define Program Files variables that work on both 32 and 64-bit Windows
set "PF=%ProgramFiles%"
set "PF86=%ProgramFiles(x86)%"
if not defined PF86 set "PF86=%ProgramFiles%"

:: Look for ATL components in various VS installations
set "ATL_FOUND=0"

:: Try to find atlbase.h in different possible locations
set "ATL_PATHS="

:: Visual Studio 2022 locations
set "ATL_PATHS=%ATL_PATHS% "%PF%\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF%\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF%\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF%\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\atlmfc\include""

:: Visual Studio 2022 (x86) locations
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\atlmfc\include""

:: Visual Studio 2019 locations
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2019\Professional\VC\Tools\MSVC\*\atlmfc\include""
set "ATL_PATHS=%ATL_PATHS% "%PF86%\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\*\atlmfc\include""

:: Check each path for atlbase.h
for %%p in (%ATL_PATHS%) do (
    for /d %%d in (%%p) do (
        if exist "%%d\atlbase.h" (
            echo Found ATL at: "%%d"
            set "ATL_FOUND=1"
            goto :atl_check_done
        )
    )
)

:atl_check_done
if "%ATL_FOUND%"=="1" (
    echo ATL components found: OK
    exit /b 0
) else (
    echo ATL components not found. Attempting to download and install...
)

:: Try to install ATL components if Visual Studio is installed
:: Note: This requires VS installer which may not be available in all environments

:: First check if VS installer is available
set "VS_INSTALLER_PATH="
if exist "%PF86%\Microsoft Visual Studio\Installer\vs_installer.exe" (
    set "VS_INSTALLER_PATH=%PF86%\Microsoft Visual Studio\Installer\vs_installer.exe"
) else if exist "%PF%\Microsoft Visual Studio\Installer\vs_installer.exe" (
    set "VS_INSTALLER_PATH=%PF%\Microsoft Visual Studio\Installer\vs_installer.exe"
)

if defined VS_INSTALLER_PATH (
    echo Found Visual Studio Installer at: "!VS_INSTALLER_PATH!"
    echo Attempting to install ATL components using VS Installer...
    
    :: Use VS installer to add ATL/MFC components
    "!VS_INSTALLER_PATH!" modify --installPath "%VSINSTALLDIR%" --add Microsoft.VisualStudio.Component.VC.ATLMFC --passive --norestart
    
    if %ERRORLEVEL% EQU 0 (
        echo Successfully installed ATL components.
        exit /b 0
    ) else (
        echo Failed to install ATL components using VS Installer.
    )
) else (
    echo Visual Studio Installer not found.
)

:: If we get here, VS Installer approach failed or wasn't available
:: Recommend manual installation
echo.
echo ATL components are needed for some C++ libraries.
echo.
echo To install ATL components, you need to:
echo 1. Open Visual Studio Installer
echo 2. Modify your Visual Studio installation
echo 3. Select "Desktop development with C++"
echo 4. Check "C++ ATL for latest v143 build tools (x86 & x64)"
echo 5. Click "Modify" to install
echo.
echo Alternatively, you can try installing Visual C++ Build Tools from:
echo https://visualstudio.microsoft.com/visual-cpp-build-tools/
echo.

:: This is not a critical failure, so return success
echo Visual Studio ATL components not installed, but continuing setup.
exit /b 0