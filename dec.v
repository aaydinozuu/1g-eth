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
    
    
    
    always@(*) begin        
                if(data_10b[9:4] == (6'b011000) || data_10b[9:4] == (6'b100111))  data[4:0] = 5'd0;
                else if(data_10b[9:4] == (6'b100010) || data_10b[9:4] == (6'b011101))  data[4:0] = 5'd1;
                else if(data_10b[9:4] == (6'b010010) || data_10b[9:4] == (6'b101101))  data[4:0] = 5'd2;
                else if(data_10b[9:4] == (6'b110001) || data_10b[9:4] == (6'b110001))  data[4:0] = 5'd3;
                else if(data_10b[9:4] == (6'b001010) || data_10b[9:4] == (6'b110101))  data[4:0] = 5'd4;
                else if(data_10b[9:4] == (6'b101001) || data_10b[9:4] == (6'b101001))  data[4:0] = 5'd5;
                else if(data_10b[9:4] == (6'b011001) || data_10b[9:4] == (6'b011001))  data[4:0] = 5'd6;
                else if(data_10b[9:4] == (6'b000111) || data_10b[9:4] == (6'b111000))  data[4:0] = 5'd7;
                else if(data_10b[9:4] == (6'b000110) || data_10b[9:4] == (6'b111001))  data[4:0] = 5'd8;
                else if(data_10b[9:4] == (6'b100101) || data_10b[9:4] == (6'b100101))  data[4:0] = 5'd9;
                else if(data_10b[9:4] == (6'b010101) || data_10b[9:4] == (6'b010101))  data[4:0] = 5'd10;
                else if(data_10b[9:4] == (6'b110100) || data_10b[9:4] == (6'b110100))  data[4:0] = 5'd11;
                else if(data_10b[9:4] == (6'b001101) || data_10b[9:4] == (6'b001101))  data[4:0] = 5'd12;
                else if(data_10b[9:4] == (6'b101100) || data_10b[9:4] == (6'b101100))  data[4:0] = 5'd13;
                else if(data_10b[9:4] == (6'b011100) || data_10b[9:4] == (6'b011100))  data[4:0] = 5'd14;
                else if(data_10b[9:4] == (6'b101000) || data_10b[9:4] == (6'b010111))  data[4:0] = 5'd15;
                else if(data_10b[9:4] == (6'b100100) || data_10b[9:4] == (6'b011011))  data[4:0] = 5'd16;
                else if(data_10b[9:4] == (6'b100011) || data_10b[9:4] == (6'b100011))  data[4:0] = 5'd17;
                else if(data_10b[9:4] == (6'b010011) || data_10b[9:4] == (6'b010011))  data[4:0] = 5'd28;
                else if(data_10b[9:4] == (6'b110010) || data_10b[9:4] == (6'b110010))  data[4:0] = 5'd19;
                else if(data_10b[9:4] == (6'b001011) || data_10b[9:4] == (6'b001011))  data[4:0] = 5'd20;
                else if(data_10b[9:4] == (6'b101010) || data_10b[9:4] == (6'b101010))  data[4:0] = 5'd21;
                else if(data_10b[9:4] == (6'b011010) || data_10b[9:4] == (6'b011010))  data[4:0] = 5'd22;
                else if(data_10b[9:4] == (6'b000101) || data_10b[9:4] == (6'b111010))  data[4:0] = 5'd23;
                else if(data_10b[9:4] == (6'b001100) || data_10b[9:4] == (6'b110011))  data[4:0] = 5'd24;
                else if(data_10b[9:4] == (6'b100110) || data_10b[9:4] == (6'b100110))  data[4:0] = 5'd25;
                else if(data_10b[9:4] == (6'b010110) || data_10b[9:4] == (6'b010110))  data[4:0] = 5'd26;
                else if(data_10b[9:4] == (6'b001001) || data_10b[9:4] == (6'b110110))  data[4:0] = 5'd27;
                else if(data_10b[9:4] == (6'b110000) || data_10b[9:4] == (6'b001111) || data_10b[9:4] == (6'b001110) || data_10b[9:4] == (6'b001110)) data[4:0] = 5'd28;
                else if(data_10b[9:4] == (6'b010001) || data_10b[9:4] == (6'b101110))  data[4:0] = 5'd29;
                else if(data_10b[9:4] == (6'b100001) || data_10b[9:4] == (6'b011110))  data[4:0] = 5'd30;
                else if(data_10b[9:4] == (6'b010100) || data_10b[9:4] == (6'b101011))  data[4:0] = 5'd31;
                else is_invalid = 1;
  
    end
    
    always@(*) begin
                is_invalid = 0;
                if(data_10b[3:0] == 4'b1011 || data_10b[3:0] == 4'b0100) data[7:4] = 3'd0;
                else if(data_10b[3:0] == 4'b1001) data[7:4] = 3'd1;
                else if(data_10b[3:0] == 4'b0101) data[7:4] = 3'd2;
                else if(data_10b[3:0] == 4'b0011 || data_10b[3:0] == 4'b1100) data[7:4] = 3'd3;
                else if(data_10b[3:0] == 4'b1101 || data_10b[3:0] == 4'b0010) data[7:4] = 3'd4;
                else if(data_10b[3:0] == 4'b1010) data[7:4] = 3'd5;
                else if(data_10b[3:0] == 4'b0110) data[7:4] = 3'd6;
                else if(data_10b[3:0] == 4'b1110 || data_10b[3:0] == 4'b0001) data[7:4] = 3'd7;
                else is_invalid = 1;
    end

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
endmodule
