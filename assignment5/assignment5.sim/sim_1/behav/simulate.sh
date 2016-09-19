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
ExecStep $xv_path/bin/xsim mega_adder_tb_behav -key {Behavioral:sim_1:Functional:mega_adder_tb} -tclbatch mega_adder_tb.tcl -log simulate.log
