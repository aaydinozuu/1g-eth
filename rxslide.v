`timescale 1ns / 1ps

module rxslide (
  input  wire        clk,            
  input  wire        rst,           
  input  wire [19:0] rwenb,            
  output reg  [9:0]  renb,    
  output reg         rxslide           
);

wire locked_up;
wire locked_down;

assign locked_up = ((rwenb[19:10] == 10'b0011111010) || (rwenb[19:10] == 10'b1100000101)) ? 1 : 0;
assign locked_down = ((rwenb[9:0] == 10'b0011111010) || (rwenb[9:0] == 10'b1100000101)) ? 1 : 0;

reg [1:0] slide_2cyc;
reg [5:0] rxslide_cnt;
reg phase;

always@(posedge clk) begin
    if(rst) begin
        slide_2cyc <= 0;
        rxslide_cnt <= 0;
        rxslide <= 0;
        renb <= 0;
        phase <= 0;
    end else begin
        if(!locked_up && !locked_down) begin
            phase <= 0;
            if(rxslide_cnt == 35) begin                
                rxslide <= 1;
                slide_2cyc <= slide_2cyc + 1;
                
                if(slide_2cyc == 2) begin
                    rxslide_cnt <= 0;
                    slide_2cyc <= 0;
                    rxslide <= 0;
                end
            end else begin
                rxslide <= 0;
                rxslide_cnt <= rxslide_cnt + 1;
            end
        end else begin
            
            if(slide_2cyc) begin
                rxslide <= 1;
                slide_2cyc <= 0;
            end else begin
                rxslide <= 0;
            end
            rxslide_cnt <= 0;
            
            if(!phase) begin
                renb <= rwenb[19:10];
                phase <= 1;
            end else begin
                renb <= rwenb[9:0];
                phase <= 0;    
            end
        end 
    end
end

endmodule


