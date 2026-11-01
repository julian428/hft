@echo off
cd /d "%~dp0\.."
call C:\AMDDesignTools\2026.1\Vivado\settings64.bat
vivado -mode batch -source scripts/build_bitstream.tcl
pause
