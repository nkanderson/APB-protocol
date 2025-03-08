//////////////////////////////////////////////////////////////
// apb_interface.sv - Interface for APB bridge and peripheral
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
    input logic pclk,  // APB Clock
    presetn  // Active-low Reset
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
  logic [           2:0] pprot;  // Protection Unit Signals

  // APB bridge
  modport bridge(
      input pclk, presetn, prdata, pready, pslverr,
      output paddr, psel, penable, pwrite, pwdata, pstrb, pprot
  );

  // APB peripheral
  modport peripheral(
      input pclk, paddr, psel, penable, pwrite, pwdata, pstrb, pprot,
      output prdata, pready, pslverr
  );

  //
  // Assertions
  //
  // PENABLE should only be high when PSEL is already high
  property psel_before_penable;
    @(posedge pclk) disable iff (!presetn) penable |-> psel;
  endproperty
  assert property (psel_before_penable)
  else $error("PENABLE asserted without PSEL being high");

  // PREADY must not be asserted unless PSEL and PENABLE are high
  property pready_valid;
    @(posedge pclk) disable iff (!presetn) pready |-> (psel && penable);
  endproperty
  assert property (pready_valid)
  else $error("PREADY asserted without valid PSEL and PENABLE");

  // PWRITE and PSTRB must be stable while PENABLE is asserted
  property stable_pwrite_pstrb;
    @(posedge pclk) disable iff (!presetn) penable |-> ##1 ($stable(
        pwrite
    ) && $stable(
        pstrb
    ));
  endproperty
  assert property (stable_pwrite_pstrb)
  else $error("PWRITE or PSTRB changed while PENABLE asserted");

  // Reset must clear all control signals
  property reset_clear_signals;
    @(posedge pclk) !presetn |-> !(psel || penable || pwrite);
  endproperty
  assert property (reset_clear_signals)
  else $error("Control signals not cleared on reset");
endinterface
