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
input clk, reset, control,
input [9:0] data_10b,
output reg [7:0] data
    );
    
    always@(data_10b) begin
        if(reset) begin
            data[4:0] <= 8'd0;
        end else begin
            case(data_10b[9:4])
                (6'b011000 | 6'b100111):  data[4:0] = 5'd0;
                (6'b100010 | 6'b011101):  data[4:0] = 5'd1;
                (6'b010010 | 6'b101101):  data[4:0] = 5'd2;
                (6'b110001 | 6'b110001):  data[4:0] = 5'd3;
                (6'b001010 | 6'b110101):  data[4:0] = 5'd4;
                (6'b101001 | 6'b101001):  data[4:0] = 5'd5;
                (6'b011001 | 6'b011001):  data[4:0] = 5'd6;
                (6'b000111 | 6'b111000):  data[4:0] = 5'd7;
                (6'b000110 | 6'b111001):  data[4:0] = 5'd8;
                (6'b100101 | 6'b100101):  data[4:0] = 5'd9;
                (6'b010101 | 6'b010101):  data[4:0] = 5'd10;
                (6'b110100 | 6'b110100):  data[4:0] = 5'd11;
                (6'b001101 | 6'b001101):  data[4:0] = 5'd12;
                (6'b101100 | 6'b101100):  data[4:0] = 5'd13;
                (6'b011100 | 6'b011100):  data[4:0] = 5'd14;
                (6'b101000 | 6'b010111):  data[4:0] = 5'd15;
                (6'b100100 | 6'b011011):  data[4:0] = 5'd16;
                (6'b100011 | 6'b100011):  data[4:0] = 5'd17;
                (6'b010011 | 6'b010011):  data[4:0] = 5'd28;
                (6'b110010 | 6'b110010):  data[4:0] = 5'd19;
                (6'b001011 | 6'b001011):  data[4:0] = 5'd20;
                (6'b101010 | 6'b101010):  data[4:0] = 5'd21;
                (6'b011010 | 6'b011010):  data[4:0] = 5'd22;
                (6'b000101 | 6'b111010):  data[4:0] = 5'd23;
                (6'b001100 | 6'b110011):  data[4:0] = 5'd24;
                (6'b100110 | 6'b100110):  data[4:0] = 5'd25;
                (6'b010110 | 6'b010110):  data[4:0] = 5'd26;
                (6'b001001 | 6'b110110):  data[4:0] = 5'd27;
                (6'b110000 | 6'b001111 | 6'b001110 | 6'b001110): data[4:0] = 5'd28;
                (6'b010001 | 6'b101110):  data[4:0] = 5'd29;
                (6'b100001 | 6'b011110):  data[4:0] = 5'd30;
                (6'b010100 | 6'b101011):  data[4:0] = 5'd31;
                default: data[4:0] = 5'd0;
            endcase
        end
    end
    
    always@(data_10b) begin
        if(reset) begin
            data[7:5] = 0;
        end else begin
            case(data_10b[3:0])
                (4'b1011 | 4'b0100): data[7:5] = 3'd0;
                (4'b1001): data[7:5] = 3'd1;
                (4'b0101): data[7:5] = 3'd2;
                (4'b0011 | 4'b1100): data[7:5] = 3'd3;
                (4'b1101 | 4'b0010): data[7:5] = 3'd4;
                (4'b1010): data[7:5] = 3'd5;
                (4'b0110): data[7:5] = 3'd6;
                (4'b1110 | 4'b0001): data[7:5] = 3'd7;
                default: data[7:5] = 3'd0;
            endcase
        end
    end
endmodule
