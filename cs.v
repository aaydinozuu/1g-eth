`timescale 1ns / 1ps

module cs(
    input clk,
    input reset,
    input repeater_mode,
    input transmitting,
    input receiving,
    output reg CRS
    );
    
    reg state, next_state;
    reg next_CRS;
    
    localparam
        CARRIER_SENSE_OFF   = 1'b0,
        CARRIER_SENSE_ON    = 1'b1;
        
    always@(posedge clk) begin
        if(reset) begin
            state <= 0;
            CRS <= 0;
        end else begin
            state <= next_state;
            CRS <= next_CRS;
        end
    end    
    
    always@(*) begin
        next_CRS = CRS;
        next_state = state;
        case(state)
            CARRIER_SENSE_OFF: begin
                next_CRS = 0;
                if((!repeater_mode && transmitting)|| receiving) begin
                    next_state = CARRIER_SENSE_ON;
                end
            end
            
            CARRIER_SENSE_ON: begin
                next_CRS = 1;
                if((repeater_mode || !transmitting) && !receiving) begin
                    next_state = CARRIER_SENSE_OFF;
                end
            end
        endcase
    end
    
endmodule
