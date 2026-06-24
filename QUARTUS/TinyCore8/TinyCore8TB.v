`timescale 1ns / 1ps

module TinyCore8TB;
    reg CLK;
    reg RST;
    wire [7:0] REGA;
    wire [7:0] REGB;

    TinyCore8 uut (
        .CLK(CLK),
        .RST(RST),
        .REGA(REGA),
        .REGB(REGB)
    );

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // Clock de 10ns (100MHz)
    end

    initial begin
        RST = 1; #20;
        RST = 0;

        #350;
        $stop;
    end

endmodule