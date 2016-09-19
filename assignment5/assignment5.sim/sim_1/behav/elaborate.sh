#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 370952dc9ab94906a14a4cd41398f151 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot mega_adder_tb_behav xil_defaultlib.mega_adder_tb -log elaborate.log
