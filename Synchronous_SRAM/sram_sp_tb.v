`timescale 1ns/1ns
`include "sram_sp.v"

module sram_sp_tb;

    parameter depth = 10;
    parameter width = 8;

    reg [width-1 : 0] data_in;
    reg [$clog2(depth)-1:0] add;
    reg clk, re, we;
    wire [width-1:0] data_out;

    sram_sp #(.depth(depth) , .width(width)) uut1 (.data_in(data_in), .clk(clk), .re(re), .we(we), .add(add),  .data_out(data_out));

    initial begin
        clk =0;
        forever begin
        #5 clk = ~clk;
        end
    end


    initial begin
        data_in = 0;
        add = 0;
        re = 0; we = 0;

        $dumpfile("sram_sp_tb.vcd");
        $dumpvars(0, sram_sp_tb);

        // Write 25 to address 0
        #10;
        data_in = 8'd25;
        add = 0;
        we = 1;

        #10;
        we = 0;

        // Read from address 0
        #10;
        re = 1;

        #10;
        re = 0;

        // Finish simulation
        #10;
        $finish;
    end

    initial begin
        $monitor("time = %0t | addr = %d | data_in = %d | data_out = %d | we = %b | re = %b",
                 $time, add, data_in, data_out, we, re);
    end



endmodule