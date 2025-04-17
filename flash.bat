@echo off
setlocal

:: Automatically find the latest .bin file in the build folder
set "bin_file="

for /f "delims=" %%i in ('dir /b /o-d build\*.bin 2^>nul') do (
    set "bin_file=%%i"
    goto :found
)

echo No .bin file found in the build directory!
goto :exit

:found
echo Flashing the latest binary: build\%bin_file%
if not exist build\%bin_file% (
    echo Error: Could not find the binary file: build\%bin_file%
    goto :exit
)

:: Run OpenOCD with the found .bin file
openocd_debugger\bin\openocd.exe -f ./openocd.cfg -c "program build/%bin_file% reset exit 0x08000000"

