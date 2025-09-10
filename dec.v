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
output is_invalid,
output reg rd
    );
    
   reg is_invalid_4;
   reg is_invalid_6; 
   
   always@(posedge clk) begin
       if(reset) begin
           is_invalid_6 = 1;
           is_invalid_4 = 1;
           data = 0;
       end
   end
   
            always@(*) begin
//                is_invalid_6 = 1;       
                if(data_10b[9:4] == (6'b011000) || data_10b[9:4] == (6'b100111))  begin
                    data[4:0] = 5'd0;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b100010) || data_10b[9:4] == (6'b011101)) begin 
                    data[4:0] = 5'd1;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b010010) || data_10b[9:4] == (6'b101101)) begin 
                    data[4:0] = 5'd2;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b110001) || data_10b[9:4] == (6'b110001)) begin 
                    data[4:0] = 5'd3;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b001010) || data_10b[9:4] == (6'b110101)) begin 
                    data[4:0] = 5'd4;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b101001) || data_10b[9:4] == (6'b101001)) begin 
                    data[4:0] = 5'd5;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b011001) || data_10b[9:4] == (6'b011001)) begin 
                    data[4:0] = 5'd6;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b000111) || data_10b[9:4] == (6'b111000)) begin 
                    data[4:0] = 5'd7;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b000110) || data_10b[9:4] == (6'b111001)) begin 
                    data[4:0] = 5'd8;
                    is_invalid_6 = 0; 
                end
                else if(data_10b[9:4] == (6'b100101) || data_10b[9:4] == (6'b100101)) begin 
                    data[4:0] = 5'd9;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b010101) || data_10b[9:4] == (6'b010101)) begin 
                    data[4:0] = 5'd10;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b110100) || data_10b[9:4] == (6'b110100)) begin 
                    data[4:0] = 5'd11;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b001101) || data_10b[9:4] == (6'b001101)) begin 
                    data[4:0] = 5'd12;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b101100) || data_10b[9:4] == (6'b101100)) begin 
                    data[4:0] = 5'd13;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b011100) || data_10b[9:4] == (6'b011100)) begin 
                    data[4:0] = 5'd14;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b101000) || data_10b[9:4] == (6'b010111)) begin 
                    data[4:0] = 5'd15;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b100100) || data_10b[9:4] == (6'b011011)) begin 
                    data[4:0] = 5'd16;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b100011) || data_10b[9:4] == (6'b100011)) begin 
                    data[4:0] = 5'd17;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b010011) || data_10b[9:4] == (6'b010011)) begin 
                    data[4:0] = 5'd28;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b110010) || data_10b[9:4] == (6'b110010)) begin 
                    data[4:0] = 5'd19;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b001011) || data_10b[9:4] == (6'b001011)) begin 
                    data[4:0] = 5'd20;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b101010) || data_10b[9:4] == (6'b101010)) begin 
                    data[4:0] = 5'd21;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b011010) || data_10b[9:4] == (6'b011010)) begin 
                    data[4:0] = 5'd22;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b000101) || data_10b[9:4] == (6'b111010)) begin 
                    data[4:0] = 5'd23;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b001100) || data_10b[9:4] == (6'b110011)) begin 
                    data[4:0] = 5'd24;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b100110) || data_10b[9:4] == (6'b100110)) begin 
                    data[4:0] = 5'd25;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b010110) || data_10b[9:4] == (6'b010110)) begin 
                    data[4:0] = 5'd26;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b001001) || data_10b[9:4] == (6'b110110)) begin 
                    data[4:0] = 5'd27;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b110000) || data_10b[9:4] == (6'b001111) || data_10b[9:4] == (6'b001110) || data_10b[9:4] == (6'b001110)) begin 
                    data[4:0] = 5'd28;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b010001) || data_10b[9:4] == (6'b101110)) begin 
                    data[4:0] = 5'd29;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b100001) || data_10b[9:4] == (6'b011110)) begin 
                    data[4:0] = 5'd30;
                    is_invalid_6 = 0;
                end
                else if(data_10b[9:4] == (6'b010100) || data_10b[9:4] == (6'b101011)) begin 
                    data[4:0] = 5'd31;
                    is_invalid_6 = 0;
                end
                else begin
                    is_invalid_6 = 1;
                end
            end
    
    
    always@(*) begin
//                is_invalid_4 = 1;
                if(control) begin
                    if(data_10b[3:0] == 4'b0111 || data_10b[3:0] == 4'b1000) begin
                        data[7:5] = 3'd7;
                        is_invalid_4 = 0;
                    end else if(data_10b[3:0] == 4'b0100 || data_10b[3:0] == 4'b1011) begin
                        data[7:5] = 3'd0;
                        is_invalid_4 = 0;
                    end else if(data_10b[3:0] == 4'b1001 || data_10b[3:0] == 4'b0110) begin
                        data[7:5] = 3'd1;
                        is_invalid_4 = 0;
                    end else if(data_10b[3:0] == 4'b0101) begin
                        if(data_10b[9:4] == 6'b001111) begin
                            data[7:5] = 3'd5;
                            is_invalid_4 = 0;
                        end else begin
                            data[7:5] = 3'd2;
                            is_invalid_4 = 0;
                        end                        
                    end else if(data_10b[3:0] == 4'b0011 || data_10b[3:0] == 4'b1100) begin
                        data[7:5] = 3'd3;
                        is_invalid_4 = 0;
                    end else if(data_10b[3:0] == 4'b0010 || data_10b[3:0] == 4'b1101) begin
                        data[7:5] = 3'd4;
                        is_invalid_4 = 0;
                    end else if(data_10b[3:0] == 4'b1010) begin
                        if(data_10b[9:4] == 6'b110000) begin
                            data[7:5] = 3'd2;
                            is_invalid_4 = 0;
                        end else begin
                            data[7:5] = 3'd5;
                            is_invalid_4 = 0;
                        end 
                    end else if(data_10b[3:0] == 4'b0110 || data_10b[3:0] == 4'b1001) begin
                        data[7:5] = 3'd6;
                        is_invalid_4 = 0;
                    end 
                end else begin
                    if(data_10b[3:0] == 4'b1011 || data_10b[3:0] == 4'b0100) begin
                        data[7:5] = 3'd0;
                        is_invalid_4 = 0;
                    end
                    else if(data_10b[3:0] == 4'b1001) begin 
                        data[7:5] = 3'd1;
                        is_invalid_4 = 0;   
                    end
                    else if(data_10b[3:0] == 4'b0101) begin 
                        data[7:5] = 3'd2;
                        is_invalid_4 = 0;
                    end
                    else if(data_10b[3:0] == 4'b0011 || data_10b[3:0] == 4'b1100) begin 
                        data[7:5] = 3'd3;
                        is_invalid_4 = 0;
                    end
                    else if(data_10b[3:0] == 4'b1101 || data_10b[3:0] == 4'b0010) begin 
                        data[7:5] = 3'd4;
                        is_invalid_4 = 0;    
                    end
                    else if(data_10b[3:0] == 4'b1010) begin 
                        data[7:5] = 3'b101;
                        is_invalid_4 = 0;  
                    end
                    else if(data_10b[3:0] == 4'b0110) begin 
                        data[7:5] = 3'd6;
                        is_invalid_4 = 0;      
                    end
                    else if(data_10b[3:0] == 4'b1110 || data_10b[3:0] == 4'b0001) begin 
                        data[7:5] = 3'd7;
                        is_invalid_4 = 0;  
                    end
                    else begin
                        is_invalid_4 = 1;
                    end
                end
    end
        
        assign is_invalid =(is_invalid_6 || is_invalid_4);
        
        reg [3:0] ones6;
        reg [2:0] ones4;
        reg rd_after6;
        reg disp_err6, disp_err4;
    
    function [3:0] popcnt6; input [5:0] x; begin popcnt6 = x[0]+x[1]+x[2]+x[3]+x[4]+x[5]; end endfunction
    function [2:0] popcnt4; input [3:0] x; begin popcnt4 = x[0]+x[1]+x[2]+x[3]; end endfunction

always @(*) begin
    if (reset) begin
        rd = 1'b0;
    end else begin

        ones6 = popcnt6(data_10b[9:4]);
        ones4 = popcnt4(data_10b[3:0]);

        disp_err6 = ((rd == 1'b1) && (ones6 > 3)) || ((rd == 1'b0) && (ones6 < 3));

        if (ones6 == 3) rd_after6 = rd;
        else if (ones6 > 3) rd_after6 = 1'b1;
        else rd_after6 = 1'b0;

        disp_err4 = ((rd_after6 == 1'b1) && (ones4 > 2)) || ((rd_after6 == 1'b0) && (ones4 < 2));

        if (!is_invalid_6 && !is_invalid_4 && !(disp_err6 || disp_err4)) begin
            if (ones4 == 2) rd = rd_after6;
            else if (ones4 > 2) rd = 1'b1;
            else rd = 1'b0;
        end
    end
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
