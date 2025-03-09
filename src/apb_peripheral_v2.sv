module apb_peripheral (
    input wire PCLK, PRESETn, PSEL, PENABLE, PWRITE,
    input wire [31:0] PADDR, PWDATA,
    input wire [3:0] PSTRB,       // Write Strobe
    output reg [31:0] PRDATA,
    output reg PREADY, PERROR
);

    reg [31:0] mem [0:15]; // Simple memory array (16 x 32-bit)
    reg [1:0] state;
    reg [3:0] wait_counter;  // 4-bit counter to simulate wait states

    // State Encoding
    localparam IDLE = 2'b00, SETUP = 2'b01, ENABLE = 2'b10;

    // Assertions for State Machine
    initial begin
        assert (IDLE < SETUP && SETUP < ENABLE)
            else $fatal("State encoding is incorrect!");
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
            PREADY <= 1'b0;
            PERROR <= 1'b0;
            wait_counter <= 4'b0;
        end else begin
            case (state)
                IDLE: begin
                    PREADY <= 1'b0;
                    if (PSEL) state <= SETUP;
                end
                SETUP: begin
                    if (PENABLE) state <= ENABLE;
                end
                ENABLE: begin
                    if (PWRITE) begin
                        if (PADDR < 16) begin
                            // Write Operation with Write Strobes
                            if (PSTRB[0]) mem[PADDR][7:0]   <= PWDATA[7:0];
                            if (PSTRB[1]) mem[PADDR][15:8]  <= PWDATA[15:8];
                            if (PSTRB[2]) mem[PADDR][23:16] <= PWDATA[23:16];
                            if (PSTRB[3]) mem[PADDR][31:24] <= PWDATA[31:24];
                            PERROR <= 1'b0;
                        end else begin
                            PERROR <= 1'b1; // Error: Invalid Address
                        end
                    end else begin
                        PRDATA <= mem[PADDR]; // Read Operation
                        PERROR <= 1'b0;
                    end

                    // Implementing Wait State Simulation
                    if (PENABLE && !PREADY) begin
                        wait_counter <= wait_counter + 1;
                        if (wait_counter == 4'b1111) begin // Wait state complete
                            PREADY <= 1'b1;
                        end
                    end else begin
                        PREADY <= 1'b0;
                        wait_counter <= 4'b0;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end

    // Assertions for Protocol Compliance
    always_ff @(posedge PCLK) begin
        if (PREADY) begin
            assert (state == ENABLE)
                else $fatal("PREADY active outside ENABLE state!");
        end

        // Ensure PERROR is only high on invalid addresses
        if (PADDR >= 16) begin
            assert (PERROR == 1'b1)
                else $fatal("PERROR not asserted on invalid address!");
        end

        // Check that memory is not written when PWRITE is low
        if (!PWRITE && PSEL && PENABLE) begin
            assert (PRDATA == mem[PADDR])
                else $fatal("Read data mismatch!");
        end
    end

endmodule
