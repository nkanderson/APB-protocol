module tb_apb_peripheral;
    reg PCLK, PRESETn, PSEL, PENABLE, PWRITE;
    reg [31:0] PADDR, PWDATA;
    reg [3:0] PSTRB;
    wire [31:0] PRDATA;
    wire PREADY, PERROR;

    apb_peripheral uut (
        .PCLK(PCLK), .PRESETn(PRESETn), .PSEL(PSEL), 
        .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PADDR(PADDR), .PWDATA(PWDATA),
        .PSTRB(PSTRB), .PRDATA(PRDATA), 
        .PREADY(PREADY), .PERROR(PERROR)
    );

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        PRESETn = 0;
        #10 PRESETn = 1;

        // Valid Write Operation
        PSEL = 1; PWRITE = 1; PADDR = 5; PWDATA = 32'hA5A5A5A5; PSTRB = 4'b1100;
        #10 PENABLE = 1; #10 PENABLE = 0; PSEL = 0;

        // Read Operation to Verify Write
        PWRITE = 0; PSEL = 1; PADDR = 5;
        #10 PENABLE = 1; #10 PENABLE = 0; PSEL = 0;

        // Invalid Address Test
        PSEL = 1; PWRITE = 1; PADDR = 20; PSTRB = 4'b1111;
        #10 PENABLE = 1; #10 PENABLE = 0; PSEL = 0;

        #50 $finish;
    end
endmodule
