# Set up the simulation environment
quit -sim
vlib work
vmap work work

# Compile source files
vlog -sv ../src/apb_pkg.sv
vlog -sv ../src/apb_interface.sv
vlog -sv ../src/apb_peripheral.sv

# Compile testbench
vlog -sv ../tb/apb_tb.sv

# Run simulation
vsim -voptargs=+acc work.apb_tb
do wave.do
run -all
