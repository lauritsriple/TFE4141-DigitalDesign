@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto 224fe86e475542c9b2dcc137b2e7a5d5 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot test_behav xil_defaultlib.test -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
