# Clear previous waveforms
if {![batch_mode]} {
  delete wave *
}

# Add APB interface signals
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb/paddr
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb/pwdata
add wave -noupdate -radix hexadecimal sim:/apb_tb/apb/prdata
add wave -noupdate sim:/apb_tb/apb/pwrite
add wave -noupdate sim:/apb_tb/apb/penable
add wave -noupdate sim:/apb_tb/apb/psel

# Add control signals
add wave -noupdate sim:/apb_tb/apb.pclk
add wave -noupdate sim:/apb_tb/apb.presetn

# Zoom to full simulation length
if {![batch_mode]} {
  wave zoom full
}
