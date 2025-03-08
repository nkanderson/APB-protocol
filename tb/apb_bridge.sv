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

  // Main test sequence
  initial begin
    logic [apb.DATA_WIDTH-1:0] read_data;

    // Wait after reset before starting transactions
    repeat (4) @(posedge apb.pclk);
    $display("Performing APB Read Transaction...");

    test_read(32'h0000_0004, read_data);
    $display("Read Data: %h", read_data);

    // Wait a few cycles before finishing
    repeat (4) @(posedge apb.pclk);
    $finish;
  end

  // Task for performing an APB Read transaction
  task test_read(input logic [apb.ADDR_WIDTH-1:0] addr, output logic [apb.DATA_WIDTH-1:0] data);
    // Counter for clock cycles waited
    automatic int wait_cycles = 0;

    begin
      //
      // Setup phase (1st clock cycle)
      //
      @(posedge apb.pclk);
      apb.psel    = 1;
      apb.pwrite  = 0;
      // Ensure 4-byte alignment
      apb.paddr   = addr & ~(32'h3);
      apb.penable = 0;

      //
      // Access phase (2nd clock cycle)
      //
      @(posedge apb.pclk);
      apb.penable = 1;

      // Wait for `pready` while counting cycles
      wait_cycles = 0;
      while (!apb.pready) begin
        @(posedge apb.pclk);
        wait_cycles++;
      end
      // Then read the data
      data = apb.prdata;

      // Check for peripheral error
      assert (!apb.pslverr)
      else $error("APB Read transaction failed: Peripheral error detected.");

      // Deassert signals
      @(posedge apb.pclk);
      apb.psel    = 0;
      apb.penable = 0;

      $display("APB Read completed in %0d cycles.", wait_cycles);
    end
  endtask
endmodule
