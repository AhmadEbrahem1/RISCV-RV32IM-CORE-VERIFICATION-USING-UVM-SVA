#!/bin/bash

# Clean previous build artifacts
clear
rm -rf simv simv.daidir *.vdb Merged.vdb urgReport *.vpd *.txt

# Compile with VCS
vcs -full64 -sverilog -ntb_opts uvm -timescale=100ns/1ns \
    -f rtl.f -f tb.f \
    -debug_access+all +vcs+vcdpluson \
    -cm line+cond+fsm+tgl+branch+assert \
    -o simv

# Run simulations with unique log and VPD per test
./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=I_type_store_load_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir I_type_store_load_test.vdb +vpdfile=I_type_store_load_test.vpd | tee I_type_store_load_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=JALR_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir JALR_test.vdb +vpdfile=JALR_test.vpd | tee JALR_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=I_type_std_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir I_type_std_test.vdb +vpdfile=I_type_std_test.vpd | tee I_type_std_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=M_Extension_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir M_Extension_test.vdb +vpdfile=M_Extension_test.vpd | tee M_Extension_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=R_type_std_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir R_type_std_test.vdb +vpdfile=R_type_std_test.vpd | tee R_type_std_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=B_type_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir B_type_test.vdb +vpdfile=B_type_test.vpd | tee B_type_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=S_type_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir S_type_test.vdb +vpdfile=S_type_test.vpd | tee S_type_test.log

./simv -cm line+cond+fsm+tgl+branch+assert +UVM_TESTNAME=Hazard_test +UVM_VERBOSITY=UVM_LOW \
       -cm_dir Hazard_test.vdb +vpdfile=Hazard_test.vpd | tee Hazard_test.log


# Merge coverage results
urg \
  -dir I_type_store_load_test.vdb \
   -dir JALR_test.vdb \
   -dir I_type_std_test.vdb \
   -dir M_Extension_test.vdb \
   -dir R_type_std_test.vdb \
   -dir B_type_test.vdb \
   -dir Hazard_test.vdb \
   -dir S_type_test.vdb \
   -dir simv.vdb      \
  -dbname Merged

# Generate reports
urg -dir Merged -format text -elf my_ex.el
dve -cov -dir Merged.vdb -elf my_ex.el &

# View waveform
dve -vpd vcdplus.vpd  &	

# Open logs in editor
gedit I_type_store_load_test.log JALR_test.log I_type_std_test.log M_Extension_test.log \
      R_type_std_test.log B_type_test.log Hazard_test.log S_type_test.log &

# View URG test list
cd urgReport
gedit tests.txt &

