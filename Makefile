# Paths
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim
WORK_DIR = work

# QuestaSim Commands
VLOG = vlog -sv
VSIM = vsim -c -do

# Source Files
SRC_FILES = $(SRC_DIR)/apb_pkg.sv \
            $(SRC_DIR)/apb_if.sv \
            $(SRC_DIR)/apb_peripheral.sv

# Testbench Files
TB_FILES = $(TB_DIR)/apb_tb.sv

# Default target
all: compile simulate

# Create working directory
init:
	@vlib $(WORK_DIR)
	@vmap work $(WORK_DIR)

# Compile design and testbench
compile: init
	$(VLOG) $(SRC_FILES)
	$(VLOG) $(TB_FILES)

# Run simulation
simulate:
	$(VSIM) $(SIM_DIR)/run_questa.tcl

# Clean up generated files
clean:
	rm -rf $(WORK_DIR) transcript vsim.wlf

.PHONY: all init compile simulate clean
