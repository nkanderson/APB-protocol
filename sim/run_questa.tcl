# Set up the simulation environment
set SRC_DIR [file normalize "$env(PWD)/src"]
set TB_DIR [file normalize "$env(PWD)/tb"]

quit -sim
vlib work
vmap work work

# Compile source files
vlog -sv "$SRC_DIR/apb_pkg.sv"
vlog -sv "$SRC_DIR/apb_interface.sv"
vlog -sv "$SRC_DIR/apb_peripheral.sv"

# Compile testbench
vlog -sv "$TB_DIR/apb_tb.sv"

# Run simulation
vsim -voptargs=+acc work.apb_tb
do wave.do
run -all
