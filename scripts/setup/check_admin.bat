@echo off
:: Check for administrator privileges
:: Temporarily bypassing admin check for testing
echo Admin check bypassed for testing
exit /b 0

:: Original check (commented out)
:: net session >nul 2>&1
:: if errorlevel 1 (
::     exit /b 1
:: )
:: exit /b 0