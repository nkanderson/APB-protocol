/*
    apb_pkg - Package for APB Interface

    ECE 571 - Team 6 Winter 2025
*/

package apb_pkg;

  // Possible states in APB protocol
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10,
    ERROR  = 2'b11
  } state_t;


  // Bus Widths
  parameter shortint ADDR_WIDTH = 16;  // Default: up to 32 bits - byte aligned
  parameter shortint DATA_WIDTH = 32;  // Defaults: 8, 16, 32 bits
  parameter shortint STRB_WIDTH = DATA_WIDTH / 8;  // PSTRB[n] corresponds to PWDATA[(8n+7):(8n)]

  // Useful Parameters
  parameter byte TRUE = 1;
  parameter byte FALSE = 0;
  parameter shortint ALIGNBITS = $clog2((DATA_WIDTH / 8));  // Calculates number of bits that should
  // be zero if byte-aligned
  // Perhipheral Register
  parameter longint REG_ITEMS = 2 ** (ADDR_WIDTH - ALIGNBITS);  // Calculates how many rows to
                                                                // create for peripheral

  // Tasks/Functions
  function automatic validAlign(input integer [ADDR_WIDTH-1:0] baseAddr);
    logic [ALIGNBITS-1:0] compareVal = '0;
    return (baseAddr[ALIGNBITS-1:0] === compareVal) ? TRUE : FALSE;
  endfunction : validAlign

  // getPprot and getAddrforPprot serve as mapping functions that provide a very basic
  // memory map for the different pprot regions. We'll begin with a single region based
  // on the MSB, which represents a privileged, non-secure, instruction region of memory.
  // This may be extended in the future to accommodate more complex mappings and tests.
  // Returns correct pprot bits for the specified address
  function automatic [2:0] getPprot(input integer [ADDR_WIDTH-1:0] addr);
    return addr[ADDR_WIDTH-1] ? 3'b111 : 3'd0;
  endfunction : getPprot

  // Returns a modified version of the recieved address to map to the specified pprot bits
  function automatic [ADDR_WIDTH-1:0] getAddrforPprot(input integer [2:0] pprot,
                                                      input integer [ADDR_WIDTH-1:0] addr);
    logic [ADDR_WIDTH-1:0] pprot_addr = addr | (1'b1 << (ADDR_WIDTH - 1));
    return pprot == 3'b111 ? pprot_addr : addr;
  endfunction : getAddrforPprot

endpackage
