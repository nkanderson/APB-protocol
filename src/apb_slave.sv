module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic [7:0]  PADDR,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    output logic        PREADY,
    output logic        PSLVERR
);
    logic [31:0] mem [0:15]; // Simple memory array

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY   <= 0;
            PSLVERR  <= 0;
        end else begin
            if (PSEL && !PENABLE) begin
                PSLVERR <= (PADDR[7:4] != 4'b0000); // Error if address is out of range
            end
            if (PSEL && PENABLE && PWRITE) begin
                if (PADDR[7:4] == 4'b0000) begin
                    mem[PADDR[3:0]] <= PWDATA;
                    PSLVERR <= 0;
                end else begin
                    PSLVERR <= 1;
                end
                PREADY <= 1;
            end else begin
                PREADY <= 0;
            end
        end
    end
endmodule
