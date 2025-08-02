// This sram code is parameterized as it is for sync read not async read
module sram_sp #(
    parameter depth = 8 ,
    parameter width = 4
) (
    input  [width-1:0] data_in,
    input clk, we,re,
    input [$clog2(depth)-1:0] add,
    output reg [width-1:0] data_out // this is sync read, if this was not reg then assign statement after always block and this becomes async
// this is sync read, if this was not reg then assign statement after always block and this becomes async
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