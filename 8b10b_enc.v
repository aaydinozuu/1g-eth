module enc (
    input clk,
    input reset,
    input control,
    input [7:0] data,
    output reg [9:0] data_10b,
    output rd
);
    
    wire [3:0] one_count;
    
    function [3:0] count_ones;
        input [9:0] data;
        integer i;
        begin
          count_ones = 0;
          for (i = 0; i < 10; i = i + 1)
            count_ones = count_ones + data[i];
        end
    endfunction
    
    function rd_for_5bits;
        input [7:0] data;
        begin
            case(data[4:0])
            5'd0, 5'd1, 5'd2, 5'd4, 5'd8, 5'd15, 5'd16, 5'd23, 5'd24,
            5'd27, 5'd29, 5'd30, 5'd31: rd_for_5bits = 1'b1;
            
            default: rd_for_5bits = 1'b0;
            endcase
        end
    endfunction
    
    assign one_count = count_ones(data_10b);
    assign rd = (one_count > 4'd5) ? 1'b1 : 1'b0; 
       
    always @(data) begin
        if(reset) begin
            data_10b[9:4] = 6'd0;
        end else begin
        case (data[4:0])
                    5'd0: data_10b[9:4] = (rd != 1'b0) ? 6'b011000 : 6'b100111;
                    5'd1: data_10b[9:4] = (rd != 1'b0) ? 6'b100010 : 6'b011101; 
                    5'd2: data_10b[9:4] = (rd != 1'b0) ? 6'b010010 : 6'b101101; 
                    5'd3: data_10b[9:4] = (rd != 1'b0) ? 6'b110001 : 6'b110001; 
                    5'd4: data_10b[9:4] = (rd != 1'b0) ? 6'b001010 : 6'b110101; 
                    5'd5: data_10b[9:4] = (rd != 1'b0) ? 6'b101001 : 6'b101001; 
                    5'd6: data_10b[9:4] = (rd != 1'b0) ? 6'b011001 : 6'b011001; 
                    5'd7: data_10b[9:4] = (rd != 1'b0) ? 6'b000111 : 6'b111000; 
                    5'd8: data_10b[9:4] = (rd != 1'b0) ? 6'b000110 : 6'b111001; 
                    5'd9: data_10b[9:4] = (rd != 1'b0) ? 6'b100101 : 6'b100101; 
                    5'd10: data_10b[9:4] = (rd != 1'b0) ? 6'b010101 : 6'b010101; 
                    5'd11: data_10b[9:4] = (rd != 1'b0) ? 6'b110100 : 6'b110100; 
                    5'd12: data_10b[9:4] = (rd != 1'b0) ? 6'b001101 : 6'b001101; 
                    5'd13: data_10b[9:4] = (rd != 1'b0) ? 6'b101100 : 6'b101100; 
                    5'd14: data_10b[9:4] = (rd != 1'b0) ? 6'b011100 : 6'b011100; 
                    5'd15: data_10b[9:4] = (rd != 1'b0) ? 6'b101000 : 6'b010111; 
                    5'd16: data_10b[9:4] = (rd != 1'b0) ? 6'b100100 : 6'b011011; 
                    5'd17: data_10b[9:4] = (rd != 1'b0) ? 6'b100011 : 6'b100011; 
                    5'd18: data_10b[9:4] = (rd != 1'b0) ? 6'b010011 : 6'b010011; 
                    5'd19: data_10b[9:4] = (rd != 1'b0) ? 6'b110010 : 6'b110010; 
                    5'd20: data_10b[9:4] = (rd != 1'b0) ? 6'b001011 : 6'b001011; 
                    5'd21: data_10b[9:4] = (rd != 1'b0) ? 6'b101010 : 6'b101010; 
                    5'd22: data_10b[9:4] = (rd != 1'b0) ? 6'b011010 : 6'b011010; 
                    5'd23: data_10b[9:4] = (rd != 1'b0) ? 6'b000101 : 6'b111010;      
                    5'd24: data_10b[9:4] = (rd != 1'b0) ? 6'b001100 : 6'b110011; 
                    5'd25: data_10b[9:4] = (rd != 1'b0) ? 6'b100110 : 6'b100110; 
                    5'd26: data_10b[9:4] = (rd != 1'b0) ? 6'b010110 : 6'b010110; 
                    5'd27: data_10b[9:4] = (rd != 1'b0) ? 6'b001001 : 6'b110110; 
                    5'd28: begin
                    if(control) begin
                        data_10b[9:4] = (rd != 1'b0) ? 6'b110000 : 6'b001111;
                    end else begin
                        data_10b[9:4] = (rd != 1'b0) ? 6'b001110 : 6'b001110; 
                    end
                    end
                    5'd29: data_10b[9:4] = (rd != 1'b0) ? 6'b010001 : 6'b101110; 
                    5'd30: data_10b[9:4] = (rd != 1'b0) ? 6'b100001 : 6'b011110; 
                    5'd31: data_10b[9:4] = (rd != 1'b0) ? 6'b010100 : 6'b101011;  
                        default: data_10b[9:4] = 6'd0;
                    endcase
        end
    end

    always@(data) begin
            if(reset) begin
                data_10b[3:0] = 3'd0;
            end else begin
            case (data[7:5])
                3'b000: begin
                    if(rd == 1'b1) begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b1011;
                        end else begin
                            data_10b[3:0] = 4'b0100;
                        end
                    end else begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b0100;
                        end else begin
                            data_10b[3:0] = 4'b1011;
                        end
                    end
                end
                
                3'b001: data_10b[3:0] = 4'b1001;
                
                3'b010: data_10b[3:0] = 4'b0101;
                
                3'b011: begin
                    if(rd == 1'b1) begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b1100;
                        end else begin
                            data_10b[3:0] = 4'b0011;
                        end
                    end else begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b0011;
                        end else begin
                            data_10b[3:0] = 4'b1100;
                        end
                    end
                end
                
                3'b100: begin
                    if(rd == 1'b1) begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b1101;
                        end else begin
                            data_10b[3:0] = 4'b0010;
                        end
                    end else begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b0010;
                        end else begin
                            data_10b[3:0] = 4'b1101;
                        end
                    end
                end
                
                3'b101: data_10b[3:0] = 4'b1010;
                
                3'b110: data_10b[3:0] = 4'b0110;
                
                3'b111: begin
                    if(rd == 1'b1) begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b1110;
                        end else begin
                            data_10b[3:0] = 4'b0001;
                        end
                    end else begin
                        if(rd_for_5bits(data)) begin
                            data_10b[3:0] = 4'b0001;
                        end else begin
                            data_10b[3:0] = 4'b1110;
                        end
                    end
                end
                
                default: data_10b[3:0] = 4'd0;
            endcase
            end
        end
    endmodule
    
    
    
    
    