// This is a code for True dual port SRAM sync read

module sram_dp #(
    parameter depth =8,
    parameter width = 8
) (
    input [width-1:0] data_inA,data_inB,
    input clk_A,clk_B, we_A, we_B, re_A, re_B, cs,
    input [$clog2(depth)-1:0]add_A, add_B,
    output reg [width-1:0]data_outA, data_outB
);
    // the first notable difference is that all the signal clk, output, input and address everything is different
    // that is because now Port A and Port B are truely 2 different ports working simultaneoulsy
    // if you want async read then declare data_outB as just output not reg
    
    reg [width-1:0] mem [0:depth-1];  
    // the memory array remains the same just the ports now are different
    // This is for Port A
    always @(posedge clk_A) begin
        if (cs && we_A) begin
            mem[add_A] <= data_inA;
        end else begin
            if (cs && re_A) begin
                data_outA <= mem[add_A];
            end else begin
                data_outA <= 'bz; 
            end
        end
    end 

    // This is for port B
    always @(posedge clk_B) begin
        if (cs && we_B) begin
            mem[add_B] <= data_inB;
        end else begin
            if (cs && re_B) begin
                data_outB<= mem[add_B];
            end else begin
                data_outB <= 'bz; 
            end
        end
    end
    // again if you remove the read enable signals out of the clocked always block and do a blocking assignment
    // this same code will become asynchoronus read true dual port SRAM
endmodule