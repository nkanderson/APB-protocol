// FIXME: This file is a placeholder for testing project directory setup
// and compilation scripting. Modify, edit, or delete this file as necessary
// once development begins.
module apb_tb;
  // Instantiate APB interface
  apb_if apb ();

  // Instantiate APB Peripheral
  apb_peripheral dut (.apb(apb));

  // Testbench process
  initial begin
    $display("Starting APB Test...");
    apb.pclk = 0;
    apb.presetn = 0;
    #10 apb.presetn = 1;  // Release reset
    #100 $finish;
  end

  // Generate Clock
  always #5 apb.pclk = ~apb.pclk;
endmodule
