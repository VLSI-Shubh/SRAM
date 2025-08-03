// This is a code for Pseudo dual port SRAM sync read

module sram_pdp #(
    parameter depth =8,
    parameter width = 8
) (
    input [width-1:0] data_inA,
    input clk, we_A, re_B, cs,
    input [$clog2(depth)-1:0]add_A, add_B,
    output reg [width-1:0]data_outB
    // if you want async read then declare data_outB as just output not reg
);
    reg [width-1:0] mem [0:depth-1];
    
// This is for Port A
    always @(posedge clk) begin
        if (cs && we_A) begin
            mem[add_A] <= data_inA;
        end
    end
// This is for port B
    always @(posedge clk) begin // here instead of clk signal, do direct assign for async read operation
        if (cs && re_B) begin
            data_outB <= mem[add_B]; // assign data_outB = re_B ? mem[add_B] : 'bz 
        end else begin
            data_outB <= 'bz;
        end
    end
endmodule