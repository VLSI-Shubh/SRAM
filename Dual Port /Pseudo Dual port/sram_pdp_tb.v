`timescale 1ns/1ns
`include "sram_pdp.v"

module sram_pdp_tb;

    parameter depth = 1024;
    parameter width = 16;

    reg [width -1:0] A;
    reg clk, w, r, cs;
    reg [$clog2(depth)-1:0] aa, ab;
    wire [width -1:0] y;

    // Instantiate the DUT
    sram_pdp #(.depth(depth), .width(width)) uut1 (
        .data_inA(A), .clk(clk), .we_A(w), .re_B(r), .cs(cs),
        .add_A(aa), .add_B(ab), .data_outB(y)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize signals
        A = 0; w = 0; r = 0; cs = 0; aa = 0; ab = 0;

        // Dump waveform
        $dumpfile("sram_pdp_tb.vcd");
        $dumpvars(0, sram_pdp_tb);

        // --- Write Operation ---
        @(posedge clk);
        cs = 1; w = 1; aa = 12; A = 16'hABCD;

        @(posedge clk);
        w = 0; A = 0; // Finish write

        // --- Read Operation ---
        @(posedge clk);
        r = 1; ab = 12;

        @(posedge clk);
        r = 0;

        // --- Second Write ---
        @(posedge clk);
        w = 1; aa = 100; A = 16'h1234;

        @(posedge clk);
        w = 0;

        // --- Second Read ---
        @(posedge clk);
        r = 1; ab = 100;

        @(posedge clk);
        r = 0;

        // --- Done ---
        @(posedge clk);
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | clk=%b | cs=%b | we_A=%b | re_B=%b | A=%h | aa=%d | ab=%d | y=%h",
            $time, clk, cs, w, r, A, aa, ab, y);
    end

endmodule
