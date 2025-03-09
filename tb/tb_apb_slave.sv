module tb_apb_slave;
    logic        PCLK;
    logic        PRESETn;
    logic [7:0]  PADDR;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PREADY;
    logic        PSLVERR;

    apb_slave dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK = 0; PRESETn = 0; PSEL = 0; PENABLE = 0; PWRITE = 0; PADDR = 8'h00; PWDATA = 32'hDEADBEEF;
        #10 PRESETn = 1;

        #10 PSEL = 1; PWRITE = 1; PADDR = 8'h02; PWDATA = 32'hCAFEBABE;
        #10 PENABLE = 1; wait (PREADY);
        #10 PENABLE = 0; PSEL = 0;

        #10 PSEL = 1; PWRITE = 1; PADDR = 8'h20; PWDATA = 32'hBADF00D;
        #10 PENABLE = 1; wait (PREADY);
        #10 PENABLE = 0; PSEL = 0;

        #10 PSEL = 1; PWRITE = 1; PADDR = 8'h05; PWDATA = 32'hFEEDBEEF;
        #10 PENABLE = 1; wait (PREADY);
        #10 PENABLE = 0; PSEL = 0;

        #10 PSEL = 1; PWRITE = 1; PADDR = 8'h03; PWDATA = 32'hABCD1234;
        #10 PENABLE = 0; PSEL = 0;

        #20 $finish;
    end
endmodule
