/*
    apb_pkg - Package for APB Interface
    
    ECE 571 - Team 6 Winter 2025
*/

package apb_pkg;

// Possible states in APB protocol
typedef enum logic [1:0] {IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b10, ERROR = 2'b11} state; 

// Bus Widths
parameter ADDR_WIDTH = 16;              // Default: up to 32 bits - byte aligned 
parameter DATA_WIDTH = 32;              // Defaults: 8, 16, 32 bits
parameter STRB_WIDTH = DATA_WIDTH / 8;  // PSTRB[n] corresponds to PWDATA[(8n+7):(8n)] 

// Useful Parameters
parameter TRUE = 1;
parameter FALSE = 0;
parameter ALIGNBITS = $clog2((DATA_WIDTH / 8));     // Calculates number of bits that should
                                                    // be zero if byte-aligned
// Perhipheral Register
parameter REG_ITEMS = 2 ** (ADDR_WIDTH - ALIGNBITS);  // Calculates how many rows to create for peripheral

// Tasks/Functions
function automatic validAlign(
    input [ADDR_WIDTH-1:0] baseAddr
);
    logic [ALIGNBITS-1:0] compareVal = '0;
    return (baseAddr[ALIGNBITS-1:0] === compareVal) ? TRUE : FALSE;
endfunction: validAlign


endpackage
