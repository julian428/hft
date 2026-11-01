@echo off
cd /d "%~dp0\.."
call C:\Xilinx\Vivado\2026.1\settings64.bat
vivado -source scripts/create_project.tcl
