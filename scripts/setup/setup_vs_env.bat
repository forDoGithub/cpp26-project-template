@echo off
setlocal

echo Setting up Visual Studio environment for C++ development...

:: Try to find Visual Studio installation (prefer newer versions)
set "FOUND_VS=0"

:: Define environment variable for Program Files folders that work on both 32 and 64-bit Windows
set "PF=%ProgramFiles%"
set "PF86=%ProgramFiles(x86)%"
if not defined PF86 set "PF86=%ProgramFiles%"

echo DEBUG: PF = "%PF%"
echo DEBUG: PF86 = "%PF86%"

:: Visual Studio 2022 paths (preferred)
if exist "%PF%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Professional
    call "%PF%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
    set "FOUND_VS=1"
) else if exist "%PF%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Enterprise
    call "%PF%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
    set "FOUND_VS=1"
) else if exist "%PF%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Community
    call "%PF%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
    set "FOUND_VS=1"
) else if exist "%PF%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Build Tools
    call "%PF%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
    set "FOUND_VS=1"
)

echo DEBUG: After checking PF locations, FOUND_VS = %FOUND_VS%

:: Visual Studio 2022 paths in Program Files (x86) - rare but possible
if "%FOUND_VS%"=="0" (
    if exist "%PF86%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2022 Professional (x86)
        call "%PF86%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2022 Enterprise (x86)
        call "%PF86%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2022 Community (x86)
        call "%PF86%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2022 Build Tools (x86)
        call "%PF86%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    )
)

echo DEBUG: After checking PF86 locations, FOUND_VS = %FOUND_VS%

:: Visual Studio 2019 paths (fallback)
if "%FOUND_VS%"=="0" (
    if exist "%PF86%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2019 Professional
        call "%PF86%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2019 Enterprise
        call "%PF86%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2019 Community
        call "%PF86%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2019 Build Tools
        call "%PF86%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    )
)

echo DEBUG: After checking 2019 locations, FOUND_VS = %FOUND_VS%

:: Visual Studio 2017 paths (last resort)
if "%FOUND_VS%"=="0" (
    if exist "%PF86%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2017 Professional
        call "%PF86%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2017 Enterprise
        call "%PF86%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2017 Community
        call "%PF86%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    ) else if exist "%PF86%\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
        echo Found Visual Studio 2017 Build Tools
        call "%PF86%\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
        set "FOUND_VS=1"
    )
)

echo DEBUG: After checking 2017 locations, FOUND_VS = %FOUND_VS%

:: Try to find installation using vswhere utility if available
if "%FOUND_VS%"=="0" (
    where vswhere >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo Trying to locate Visual Studio installation using vswhere...
        for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
            if exist "%%i\VC\Auxiliary\Build\vcvarsall.bat" (
                echo Found Visual Studio using vswhere: "%%i"
                call "%%i\VC\Auxiliary\Build\vcvarsall.bat" x64
                set "FOUND_VS=1"
            )
        )
    )
)

echo DEBUG: After vswhere check, FOUND_VS = %FOUND_VS%

:: Check if we found Visual Studio
if "%FOUND_VS%"=="0" (
    echo WARNING: Could not find any Visual Studio installation.
    echo Please make sure Visual Studio with C++ workload is installed.
    echo CMake may fail to configure without Visual Studio libraries.
    exit /b 1
) else (
    echo Visual Studio environment setup complete.
    echo DEBUG: Checking environment variables...
    
    :: Check if LIB and INCLUDE are set properly
    if not defined LIB (
        echo WARNING: LIB environment variable is not set.
    ) else (
        echo DEBUG: LIB is defined.
    )
    if not defined INCLUDE (
        echo WARNING: INCLUDE environment variable is not set.
    ) else (
        echo DEBUG: INCLUDE is defined.
    )
    
    :: Just print verification message without processing paths
    echo DEBUG: All variables verified. Now exporting to parent process...
    echo LIB and INCLUDE variables verified.
)

echo DEBUG: About to enter endlocal section

endlocal & (
    :: Export environment variables from vcvarsall to the parent script
    echo DEBUG: Exporting PATH
    set "PATH=%PATH%"
    echo DEBUG: Exporting INCLUDE
    set "INCLUDE=%INCLUDE%"
    echo DEBUG: Exporting LIB
    set "LIB=%LIB%"
    echo DEBUG: Exporting LIBPATH
    set "LIBPATH=%LIBPATH%"
    echo DEBUG: Export complete
)

echo DEBUG: After endlocal section

:: Create a temporary file to pass environment variables back to the parent script
:: This avoids the issue with paths containing backslashes
set "TEMP_ENV_FILE=%TEMP%\vs_env_%RANDOM%.bat"

echo @echo off > "%TEMP_ENV_FILE%"
echo set "VS_PATH=%PATH%" >> "%TEMP_ENV_FILE%"
echo set "VS_INCLUDE=%INCLUDE%" >> "%TEMP_ENV_FILE%"
echo set "VS_LIB=%LIB%" >> "%TEMP_ENV_FILE%"
echo set "VS_LIBPATH=%LIBPATH%" >> "%TEMP_ENV_FILE%"

:: Return the temp file path for the parent script to use
echo %TEMP_ENV_FILE%

exit /b 0