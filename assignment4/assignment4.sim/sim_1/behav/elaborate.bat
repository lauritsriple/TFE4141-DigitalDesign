@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto 3a5fb9ab55694f4aae686dadcec8a0bf -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot thing_with_latch_behav xil_defaultlib.thing_with_latch -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
