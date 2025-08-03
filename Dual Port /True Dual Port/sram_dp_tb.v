`timescale 1ns/1ps
`include "sram_dp.v"

module sram_dp_tb;

    parameter depth = 256;
    parameter width = 16;

    reg [width-1:0] data_inA, data_inB;
    reg [$clog2(depth)-1:0] add_A, add_B;
    reg clk_A = 0, clk_B = 0;
    reg we_A = 0, we_B = 0, re_A = 0, re_B = 0, cs = 0;
    wire [width-1:0] data_outA, data_outB;

    sram_dp #(depth, width) DUT (
        .data_inA(data_inA),
        .data_inB(data_inB),
        .clk_A(clk_A),
        .clk_B(clk_B),
        .we_A(we_A),
        .we_B(we_B),
        .re_A(re_A),
        .re_B(re_B),
        .cs(cs),
        .add_A(add_A),
        .add_B(add_B),
        .data_outA(data_outA),
        .data_outB(data_outB)
    );

    // Clock generation
    always #5 clk_A = ~clk_A;
    always #7 clk_B = ~clk_B;

    initial begin
        $dumpfile("sram_dp_tb.vcd");
        $dumpvars(0,sram_dp_tb);
    end

    initial begin
        $display("Time\tclk_A clk_B | we_A re_A add_A data_inA | we_B re_B add_B data_inB || data_outA data_outB");
        $monitor("%4t\t%b     %b    |  %b    %b    %3d    %h   |  %b    %b    %3d    %h   ||   %h       %h",
                 $time, clk_A, clk_B,
                 we_A, re_A, add_A, data_inA,
                 we_B, re_B, add_B, data_inB,
                 data_outA, data_outB);

        // Initialize
        cs = 1;

        // Write to Port A @ addr 5
        @(negedge clk_A);
        data_inA = 16'hAAAA;
        add_A = 5;
        we_A = 1; re_A = 0;

        // Write to Port B @ addr 10
        @(negedge clk_B);
        data_inB = 16'hBBBB;
        add_B = 10;
        we_B = 1; re_B = 0;

        // Disable writes
        @(negedge clk_A); we_A = 0;
        @(negedge clk_B); we_B = 0;

        // Read back from Port A @ addr 5
        @(negedge clk_A);
        add_A = 5;
        re_A = 1;

        // Read back from Port B @ addr 10
        @(negedge clk_B);
        add_B = 10;
        re_B = 1;

        // Simultaneous write from A and read from B
        @(negedge clk_A);
        data_inA = 16'h1234;
        add_A = 15;
        we_A = 1; re_A = 0;

        @(negedge clk_B);
        add_B = 5;
        re_B = 1; // Should read 0xAAAA from earlier write

        @(negedge clk_A);
        we_A = 0;

        // Final read to verify last write
        @(negedge clk_A);
        add_A = 15;
        re_A = 1;

        @(negedge clk_B);
        re_B = 0;

        #20;
        $finish;
    end
endmodule
