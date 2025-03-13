//////////////////////////////////////////////////////////////
// test_read_pkg.sv - Package with tasks for testing read transfers
//
// Description:
// ------------
// This package contains tasks to support testing APB read transfers.
// It depends on the apb_if interface being compiled and instantiated.
//
////////////////////////////////////////////////////////////////

package test_read_pkg;
  // Task for performing an APB Read transaction
  task test_read(input apb_if.bridge apb, input logic [apb.ADDR_WIDTH-1:0] addr,
                 output logic [apb.DATA_WIDTH-1:0] data);
    // NOTE: No reset is performed here so that we can test sequential reads / writes
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

  task test_invalid_reads(input apb_if.bridge apb);
    logic [apb.DATA_WIDTH-1:0] data;

    // Test Case 1: Deassert PSEL too early
    begin
      reset_apb(apb);
      $display("Starting Invalid Read Test: Early PSEL deassertion...");
      @(posedge apb.pclk);
      apb.psel    = 1;
      apb.pwrite  = 0;
      apb.paddr   = 32'h4;
      apb.penable = 0;

      @(posedge apb.pclk);
      apb.penable = 1;

      //
      // **Break the protocol: Deassert PSEL early**
      //
      @(posedge apb.pclk);
      apb.psel = 0;

      // Wait for PREADY and check PSLVERR
      @(posedge apb.pclk);
      wait (apb.pready);
      assert (apb.pslverr)
      else $error("APB Invalid Read Test (Early PSEL Deassertion) FAILED: PSLVERR not asserted.");

      @(posedge apb.pclk);
      apb.penable = 0;
    end

    // Test Case 2: Unaligned Address
    begin
      reset_apb(apb);
      $display("Starting Invalid Read Test: Unaligned Address...");
      @(posedge apb.pclk);
      apb.psel    = 1;
      apb.pwrite  = 0;
      //
      // **Intentionally misaligned**
      //
      apb.paddr   = 32'h3;
      apb.penable = 0;

      @(posedge apb.pclk);
      apb.penable = 1;

      // Wait for PREADY and check PSLVERR
      @(posedge apb.pclk);
      wait (apb.pready);
      assert (apb.pslverr)
      else $error("APB Invalid Read Test (Unaligned Address) FAILED: PSLVERR not asserted.");

      @(posedge apb.pclk);
      apb.psel    = 0;
      apb.penable = 0;
    end

    $display("Invalid Read Test Completed.");
  endtask


  task reset_apb(input apb_if.bridge apb);
    // Ensure all signals start with known values
    apb.psel    = 0;
    apb.penable = 0;
    apb.pwrite  = 0;
    apb.paddr   = 0;
    apb.pwdata  = 0;
    apb.pstrb   = 0;

    // Wait one clock cycle for values to settle
    @(posedge apb.pclk);
  endtask
endpackage
