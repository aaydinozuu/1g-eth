`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2025 13:05:10
// Design Name: 
// Module Name: dec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dec(
input clk, reset, 
input [9:0] data_10b,
output control,
output reg [7:0] data,
output reg is_invalid
    );
    
    function [4:0] data_5b;
        input [5:0] x;
            
                if(x == (6'b011000) || x == (6'b100111))  data_5b[4:0] = 5'd0;
                else if(x == (6'b100010) || x == (6'b011101))  data_5b[4:0] = 5'd1;
                else if(x == (6'b010010) || x == (6'b101101))  data_5b[4:0] = 5'd2;
                else if(x == (6'b110001) || x == (6'b110001))  data_5b[4:0] = 5'd3;
                else if(x == (6'b001010) || x == (6'b110101))  data_5b[4:0] = 5'd4;
                else if(x == (6'b101001) || x == (6'b101001))  data_5b[4:0] = 5'd5;
                else if(x == (6'b011001) || x == (6'b011001))  data_5b[4:0] = 5'd6;
                else if(x == (6'b000111) || x == (6'b111000))  data_5b[4:0] = 5'd7;
                else if(x == (6'b000110) || x == (6'b111001))  data_5b[4:0] = 5'd8;
                else if(x == (6'b100101) || x == (6'b100101))  data_5b[4:0] = 5'd9;
                else if(x == (6'b010101) || x == (6'b010101))  data_5b[4:0] = 5'd10;
                else if(x == (6'b110100) || x == (6'b110100))  data_5b[4:0] = 5'd11;
                else if(x == (6'b001101) || x == (6'b001101))  data_5b[4:0] = 5'd12;
                else if(x == (6'b101100) || x == (6'b101100))  data_5b[4:0] = 5'd13;
                else if(x == (6'b011100) || x == (6'b011100))  data_5b[4:0] = 5'd14;
                else if(x == (6'b101000) || x == (6'b010111))  data_5b[4:0] = 5'd15;
                else if(x == (6'b100100) || x == (6'b011011))  data_5b[4:0] = 5'd16;
                else if(x == (6'b100011) || x == (6'b100011))  data_5b[4:0] = 5'd17;
                else if(x == (6'b010011) || x == (6'b010011))  data_5b[4:0] = 5'd28;
                else if(x == (6'b110010) || x == (6'b110010))  data_5b[4:0] = 5'd19;
                else if(x == (6'b001011) || x == (6'b001011))  data_5b[4:0] = 5'd20;
                else if(x == (6'b101010) || x == (6'b101010))  data_5b[4:0] = 5'd21;
                else if(x == (6'b011010) || x == (6'b011010))  data_5b[4:0] = 5'd22;
                else if(x == (6'b000101) || x == (6'b111010))  data_5b[4:0] = 5'd23;
                else if(x == (6'b001100) || x == (6'b110011))  data_5b[4:0] = 5'd24;
                else if(x == (6'b100110) || x == (6'b100110))  data_5b[4:0] = 5'd25;
                else if(x == (6'b010110) || x == (6'b010110))  data_5b[4:0] = 5'd26;
                else if(x == (6'b001001) || x == (6'b110110))  data_5b[4:0] = 5'd27;
                else if(x == (6'b110000) || x == (6'b001111) || x == (6'b001110) || x == (6'b001110)) data_5b[4:0] = 5'd28;
                else if(x == (6'b010001) || x == (6'b101110))  data_5b[4:0] = 5'd29;
                else if(x == (6'b100001) || x == (6'b011110))  data_5b[4:0] = 5'd30;
                else if(x == (6'b010100) || x == (6'b101011))  data_5b[4:0] = 5'd31;
                else is_invalid = 1;
  
    endfunction
    
    function [2:0] data_3b;
        input [3:0] x;
                if(x == 4'b1011 || x == 4'b0100) data_3b = 3'd0;
                else if(x == 4'b1001) data_3b = 3'd1;
                else if(x == 4'b0101) data_3b = 3'd2;
                else if(x == 4'b0011 || x == 4'b1100) data_3b = 3'd3;
                else if(x == 4'b1101 || x == 4'b0010) data_3b = 3'd4;
                else if(x == 4'b1010) data_3b = 3'd5;
                else if(x == 4'b0110) data_3b = 3'd6;
                else if(x == 4'b1110 || x == 4'b0001) data_3b = 3'd7;
                else is_invalid = 1;
    endfunction

assign control = (data_10b == 10'b0011110100 ||
                  data_10b == 10'b1100001011 ||
                  data_10b == 10'b0011111001 ||
                  data_10b == 10'b1100000110 ||
                  data_10b == 10'b0011110101 ||
                  data_10b == 10'b1100001010 ||
                  data_10b == 10'b0011110011 ||
                  data_10b == 10'b1100001100 ||
                  data_10b == 10'b0011110010 ||
                  data_10b == 10'b1100001101 ||
                  data_10b == 10'b0011111010 ||
                  data_10b == 10'b1100000101 ||
                  data_10b == 10'b0011110110 ||
                  data_10b == 10'b1100001001 ||
                  data_10b == 10'b0011111000 ||
                  data_10b == 10'b1100000111 ||
                  data_10b == 10'b1110101000 ||
                  data_10b == 10'b0001010111 ||
                  data_10b == 10'b1101101000 ||
                  data_10b == 10'b0010010111 ||
                  data_10b == 10'b1011101000 ||
                  data_10b == 10'b0100010111 ||
                  data_10b == 10'b0111101000 ||
                  data_10b == 10'b1000010111 )       ? 1: 0;

always @(*) begin
    data = {data_3b(data_10b[3:0]), data_5b(data_10b[9:4])};
    is_invalid = 0;
end
endmodule
