# Clear previous waveforms
delete wave *

# TODO: Update / confirm signal names
# Add APB interface signals
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb_if/paddr
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb_if/pwdata
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb_if/prdata
add wave -noupdate sim:/apb_tb/apb_if/pwrite
add wave -noupdate sim:/apb_tb/apb_if/penable
add wave -noupdate sim:/apb_tb/apb_if/psel

# TODO: Update / confirm signal names
# Add control signals
add wave -noupdate sim:/apb_tb/clk
add wave -noupdate sim:/apb_tb/rst_n

# Organize waves into a group
group APB_Interface sim:/apb_tb/apb_if/*

# Zoom to full simulation length
wave zoom full
