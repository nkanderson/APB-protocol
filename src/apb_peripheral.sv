module apb_peripheral (
    apb_if.peripheral apb   // Connect to APB interface (peripheral side)
);
    // Internal storage (simple 4-register memory)
    logic [31:0] reg_mem [0:3];

    always_ff @(posedge apb.pclk or negedge apb.presetn) begin
        if (!apb.presetn) begin
            // Reset internal registers
            reg_mem[0] <= 32'd0;
            reg_mem[1] <= 32'd0;
            reg_mem[2] <= 32'd0;
            reg_mem[3] <= 32'd0;
            apb.prdata  <= 32'd0;
            apb.pready  <= 1'b0;
            apb.pslverr <= 1'b0;
        end else begin
            apb.pready <= 1'b0; // Default not ready

            if (apb.psel && apb.penable) begin
                apb.pready <= 1'b1; // Ready to respond

                if (apb.pwrite) begin
                    // Write operation
                    reg_mem[apb.paddr[3:2]] <= apb.pwdata; // Simple 4-register addressing
                end else begin
                    // Read operation
                    apb.prdata <= reg_mem[apb.paddr[3:2]];
                end
            end
        end
    end
endmodule
