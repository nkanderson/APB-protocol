// FIXME: This file is a placeholder for testing project directory setup
// and compilation scripting. Modify, edit, or delete this file as necessary
// once development begins.
interface apb_if;
  import apb_pkg::ADDR_WIDTH, apb_pkg::DATA_WIDTH;

  logic                   pclk;  // APB Clock
  logic                   presetn;  // Active-low Reset
  logic [ADDR_WIDTH-1:0]  paddr;  // Address Bus
  logic                   psel;  // Peripheral Select
  logic                   penable;  // Enable Signal
  logic                   pwrite;  // Write Enable
  logic [DATA_WIDTH-1:0]  pwdata;  // Write Data
  logic [DATA_WIDTH-1:0]  prdata;  // Read Data
  logic                   pready;  // Ready Signal
  logic                   pslverr;  // Peripheral Error

  // Clocking block for the APB bus
  modport apb_bus(
      input pclk, presetn, prdata, pready, pslverr,
      output paddr, psel, penable, pwrite, pwdata
  );

  // Clocking block for the APB peripheral
  modport peripheral(
      input pclk, presetn, paddr, psel, penable, pwrite, pwdata,
      output prdata, pready, pslverr
  );
endinterface
