module enc (
    input clk, reset, control,
    input [7:0] data,
    output reg [9:0] encoded_data,
    output rd
);

reg rd_reg, rd_next;

function selection_4b;
        input [4:0] x;
        begin
            case(x)
            5'd0, 5'd1, 5'd2, 5'd4, 5'd8, 5'd15, 5'd16, 5'd23, 5'd24,
            5'd27, 5'd29, 5'd30, 5'd31: selection_4b = 1'b1;
            
            default: selection_4b = 1'b0;
            endcase
        end
    endfunction


function [5:0] data_6b;
    input [4:0] x;
    input is_k;
    input rd;
    begin         
        case (x)
                    5'd0: data_6b = (rd != 1'b0) ? 6'b011000 : 6'b100111;
                    5'd1: data_6b = (rd != 1'b0) ? 6'b100010 : 6'b011101; 
                    5'd2: data_6b = (rd != 1'b0) ? 6'b010010 : 6'b101101; 
                    5'd3: data_6b = (rd != 1'b0) ? 6'b110001 : 6'b110001; 
                    5'd4: data_6b = (rd != 1'b0) ? 6'b001010 : 6'b110101; 
                    5'd5: data_6b = (rd != 1'b0) ? 6'b101001 : 6'b101001; 
                    5'd6: data_6b = (rd != 1'b0) ? 6'b011001 : 6'b011001; 
                    5'd7: data_6b = (rd != 1'b0) ? 6'b000111 : 6'b111000; 
                    5'd8: data_6b = (rd != 1'b0) ? 6'b000110 : 6'b111001; 
                    5'd9: data_6b = (rd != 1'b0) ? 6'b100101 : 6'b100101; 
                    5'd10: data_6b = (rd != 1'b0) ? 6'b010101 : 6'b010101; 
                    5'd11: data_6b = (rd != 1'b0) ? 6'b110100 : 6'b110100; 
                    5'd12: data_6b = (rd != 1'b0) ? 6'b001101 : 6'b001101; 
                    5'd13: data_6b = (rd != 1'b0) ? 6'b101100 : 6'b101100; 
                    5'd14: data_6b = (rd != 1'b0) ? 6'b011100 : 6'b011100; 
                    5'd15: data_6b = (rd != 1'b0) ? 6'b101000 : 6'b010111; 
                    5'd16: data_6b = (rd != 1'b0) ? 6'b100100 : 6'b011011; 
                    5'd17: data_6b = (rd != 1'b0) ? 6'b100011 : 6'b100011; 
                    5'd18: data_6b = (rd != 1'b0) ? 6'b010011 : 6'b010011; 
                    5'd19: data_6b = (rd != 1'b0) ? 6'b110010 : 6'b110010; 
                    5'd20: data_6b = (rd != 1'b0) ? 6'b001011 : 6'b001011; 
                    5'd21: data_6b = (rd != 1'b0) ? 6'b101010 : 6'b101010; 
                    5'd22: data_6b = (rd != 1'b0) ? 6'b011010 : 6'b011010; 
                    5'd23: data_6b = (rd != 1'b0) ? 6'b000101 : 6'b111010;      
                    5'd24: data_6b = (rd != 1'b0) ? 6'b001100 : 6'b110011; 
                    5'd25: data_6b = (rd != 1'b0) ? 6'b100110 : 6'b100110; 
                    5'd26: data_6b = (rd != 1'b0) ? 6'b010110 : 6'b010110; 
                    5'd27: data_6b = (rd != 1'b0) ? 6'b001001 : 6'b110110; 
                    5'd28: data_6b = is_k ? (rd ? 6'b110000 : 6'b001111) : 6'b001110;                
                    5'd29: data_6b = (rd != 1'b0) ? 6'b010001 : 6'b101110; 
                    5'd30: data_6b = (rd != 1'b0) ? 6'b100001 : 6'b011110; 
                    5'd31: data_6b = (rd != 1'b0) ? 6'b010100 : 6'b101011;  
                        default: data_6b = 6'd0;
                    endcase        
    end    
endfunction


function [3:0] data_4b;
    input [2:0] x;
    input rd;
    input is_k;
    input selection_4b;
    begin
    case (x)
        3'd0: data_4b = selection_4b ? (rd ? 4'b1011 : 4'b0100) : (rd ? 4'b0100 : 4'b1011);
        3'd1: data_4b = 4'b1001;
        3'd2: data_4b = 4'b0101;
        3'd3: data_4b = selection_4b ? (rd ? 4'b1100 : 4'b0011) : (rd ? 4'b0011 : 4'b1100);
        3'd4: data_4b = selection_4b ? (rd ? 4'b1101 : 4'b0010) : (rd ? 4'b0010 : 4'b1101);
        3'd5: data_4b = (is_k & rd) ? 4'b0101 : 4'b1010;
        3'd6: data_4b = 4'b0110;
        3'd7: data_4b = selection_4b ? (rd ? 4'b1110 : 4'b0001) : (rd ? 4'b0001 : 4'b1110);
        default: data_4b = 4'd0;
    endcase
    end
endfunction



function [3:0] count_ones10;
    input [9:0] data_10b;
    integer i;
    begin
        count_ones10  = 4'd0;
        for (i=0; i<10 ; i=i+1) begin
            count_ones10 = (data_10b[i] == 1) ? (count_ones10 + 1) : count_ones10;
        end
    end
endfunction


reg [9:0] sym_next;

always @(*) begin
    sym_next = {data_6b(data[4:0], control, rd_reg), data_4b(data[7:5], rd_reg, control, selection_4b(data[4:0]))};
end


always @(*) begin
    if(rd_reg == 0) begin
        rd_next = (count_ones10(sym_next) > 5) ? 1 : 0;
    end else begin
        rd_next = (count_ones10(sym_next) < 5) ? 0 : 1;
    end
end


always @(posedge clk) begin
if (reset) begin
    encoded_data <= 0;
    rd_reg <= 0;
end else begin
    encoded_data <= sym_next;
    rd_reg <= rd_next;
end

end

assign rd = rd_reg;

endmodule