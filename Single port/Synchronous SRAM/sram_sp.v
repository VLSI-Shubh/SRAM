// This sram code is parameterized as it is for sync read not async read
// Most importantly this is a single port SRAM but read enable and write enable ports are different. 
module sram_sp #(
    parameter depth = 8 ,
    parameter width = 4
) (
    input  [width-1:0] data_in,
    input clk, we,re, // see re and we, where as if you can use just we and in else condition do reading operation directly. 
    input [$clog2(depth)-1:0] add,
    output reg [width-1:0] data_out 
// this is sync read, if this was not reg then assign statement after always block and then this becomes async read
);
    reg [width-1:0]mem[0:depth-1];
    
    always @(posedge clk) begin
        if(we) begin
            mem[add] <= data_in;
        end if (re) begin
            data_out <= mem[add]; // this is sync read 
        end else begin
            data_out <= 'bz; 
        end
    end
endmodule