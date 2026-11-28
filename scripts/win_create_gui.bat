@echo off
setlocal
cd /d "%~dp0\.."

where vivado >nul 2>nul
if not errorlevel 1 goto :run_vivado

if not defined VIVADO_SETTINGS (
    for /f "delims=" %%F in ('dir /b /ad /o-n "C:\AMDDesignTools" 2^>nul') do (
        if not defined VIVADO_SETTINGS if exist "C:\AMDDesignTools\%%F\Vivado\settings64.bat" set "VIVADO_SETTINGS=C:\AMDDesignTools\%%F\Vivado\settings64.bat"
    )
)
if not defined VIVADO_SETTINGS (
    for /f "delims=" %%F in ('dir /b /ad /o-n "C:\Xilinx\Vivado" 2^>nul') do (
        if not defined VIVADO_SETTINGS if exist "C:\Xilinx\Vivado\%%F\settings64.bat" set "VIVADO_SETTINGS=C:\Xilinx\Vivado\%%F\settings64.bat"
    )
)

if not defined VIVADO_SETTINGS (
    echo BLAD: Nie znaleziono Vivado. Ustaw zmienna VIVADO_SETTINGS na sciezke do settings64.bat lub dodaj Vivado do PATH.
    pause
    exit /b 1
)

call "%VIVADO_SETTINGS%"

:run_vivado
vivado -source scripts/create_project.tcl
