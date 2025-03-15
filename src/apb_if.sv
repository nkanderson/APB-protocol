//////////////////////////////////////////////////////////////
// apb_if.sv - Interface for APB bridge and peripheral
//
// Description:
// ------------
// Interface for APB bridge and peripheral. Assumes that a top
// module will be used to instantiate this interface and the two
// modules for the bridge and peripheral, as well as initiate a
// pclk clocking signal and perform the initial reset using
// presetn. Defaults for the interface parameters should be taken
// from apb_pkg.sv
//
////////////////////////////////////////////////////////////////

interface apb_if #(
    parameter ADDR_WIDTH,
    DATA_WIDTH,
    STRB_WIDTH
) (
    input logic pclk, // APB Clock
    presetn // Active-low Reset
);
  logic [ADDR_WIDTH-1:0] paddr;  // Address Bus
  logic                  psel;  // Peripheral Select
  logic                  penable;  // Enable Signal
  logic                  pwrite;  // Write Enable
  logic [DATA_WIDTH-1:0] pwdata;  // Write Data
  logic [STRB_WIDTH-1:0] pstrb;  // Strobe Signal
  logic [DATA_WIDTH-1:0] prdata;  // Read Data
  logic                  pready;  // Ready Signal
  logic                  pslverr;  // Peripheral Error
  logic [2:0]            pprot;  // Protection Unit Signals

  // APB bridge
  modport bridge(
      input pclk, presetn, prdata, pready, pslverr,
      output paddr, psel, penable, pwrite, pwdata, pstrb, pprot
  );

  // APB peripheral
  modport peripheral(
      input pclk, presetn, paddr, psel, penable, pwrite, pwdata, pstrb, pprot,
      output prdata, pready, pslverr
  );
endinterface
