//////////////////////////////////////////////////////////////
// apb_bridge.sv - APB Bridge, which serves as a testbench
//
// Description:
// ------------
// This module simulates the role of the APB requester by
// acting as an APB bridge. It initiates transfers such as
// reads and writes. The top module provides the pclk and
// presetn signals.
//
////////////////////////////////////////////////////////////////

module apb_bridge (
    apb_if.bridge apb
);

  // Import the read transfer tasks
  import test_read_pkg::*;

  // Main test sequence
  initial begin
    logic [apb.DATA_WIDTH-1:0] read_data;

    // Wait after reset before starting transactions
    repeat (4) @(posedge apb.pclk);
    $display("Performing APB Read Transaction...");

    //
    // Read transfer tests
    //
    test_read(apb, 32'h0000_0004, read_data);
    $display("Read Data: %h", read_data);

    test_invalid_reads(apb);

    // Wait a few cycles before finishing
    repeat (4) @(posedge apb.pclk);
    $finish;
  end
endmodule
