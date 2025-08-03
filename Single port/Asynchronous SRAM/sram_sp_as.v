// This sram code is parameterized as it is for sync read not async read
// Most importantly this is a single port SRAM but read enable and write enable ports are different. 
module sram_sp_as #(
    parameter depth = 8 ,
    parameter width = 4
) (
    input  [width-1:0] data_in,
    input clk, we,re, // see re and we, where as if you can use just we and in else condition do reading operation directly. 
    input [$clog2(depth)-1:0] add,
    output [width-1:0] data_out // this is async read,
);
    reg [width-1:0]mem[0:depth-1];
    
    always @(posedge clk) begin
        if(we) begin
            mem[add] <= data_in;
        end
    end

    assign data_out = re ? mem[add] :'bz; // This is outside the clocked always block hence async
    // This is alittle unstable, hence used mostly in ROM s or small LUT's
endmodule