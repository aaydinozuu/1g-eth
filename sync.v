`timescale 1ns / 1ps


module sync(
input clk,
input signal_detect,
input [9:0] PUDI,
//input rd,
input reset,
output [7:0] data_8b,
output reg carrier_detect,
output control,
output reg code_sync_status,
output reg rx_even
    );
  `ifdef COUNT_ONES10_DEFINED
  `undef COUNT_ONES10_DEFINED
  `endif
    `include "defines.vh"
    
    localparam [3:0]
        LOSS_OF_SYNC        = 4'd0,
        COMMA_DETECT_1      = 4'd1,
        ACQUIRE_SYNC_1      = 4'd2,
        COMMA_DETECT_2      = 4'd3,
        ACQUIRE_SYNC_2      = 4'd4,
        COMMA_DETECT_3      = 4'd5,
        SYNC_ACQUIRED_1     = 4'd6,
        SYNC_ACQUIRED_2     = 4'd7,
        SYNC_ACQUIRED_2A    = 4'd8,
        SYNC_ACQUIRED_3     = 4'd9,
        SYNC_ACQUIRED_3A    = 4'd10,
        SYNC_ACQUIRED_4     = 4'd11,
        SYNC_ACQUIRED_4A    = 4'd12;      
    
    reg [3:0] state, next_state;
    reg next_code_sync_status;
    reg next_rx_even;
    
    
    ////////////////////////////////////////INVALID PUDI //////////////////////////////////////////
    wire is_invalid;
    wire rd;
    
    dec deco(
    .clk(clk),
    .reset(reset),
    .data_10b(PUDI),
    .is_invalid(is_invalid),
    .rd(rd),
    .control(control),
    .data(data_8b)
    );
    
    /////////////////////////////////////////CARRIER DETECT//////////////////////////////////////////
    wire [9:0] xor_result_n_k    = PUDI ^ `K28_5_10b_n;
    wire [9:0] xor_result_p_k    = PUDI ^ `K28_5_10b_p;
    wire [3:0] count_ones_pk = count_ones10(xor_result_p_k);
    wire [3:0] count_ones_nk = count_ones10(xor_result_n_k);
    always@(*) begin
        if(rx_even) begin
            if((count_ones_pk >= 2) && (count_ones_nk >= 2)) begin
                carrier_detect = 1;
            end else begin
                carrier_detect = 0;
            end
        end else begin
            if(rd) begin
                if((count_ones_pk >= 2) && (count_ones_pk <= 9)) begin
                    carrier_detect = 1;
                end else begin
                    carrier_detect = 0;
                end
            end else begin
                if((count_ones_nk >= 2) && (count_ones_nk <= 9)) begin
                    carrier_detect = 1;
                end else begin
                    carrier_detect = 0;
                end
            end            
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////CG GOOD - CG BAD////////////////////////////////////////
    wire cggood, cgbad;
    assign cggood = !(is_invalid || ((PUDI == `K28_5_10b_n || PUDI == `K28_5_10b_p || PUDI == `K28_7_10b_n ||
    PUDI == `K28_7_10b_p || PUDI == `K28_1_10b_n || PUDI == `K28_1_10b_p) && next_rx_even));
    assign cgbad = (is_invalid || ((PUDI == `K28_5_10b_n || PUDI == `K28_5_10b_p || PUDI == `K28_7_10b_n ||
    PUDI == `K28_7_10b_p || PUDI == `K28_1_10b_n || PUDI == `K28_1_10b_p) && next_rx_even));
    
        
    ///////////////////////////////////////PUDI CHECK/////////////////////////////////////////////
    reg pudi_is_comma,  pudi_is_data, pudi_is_invalid;
    
    always@(*) begin
        pudi_is_comma = 0;
        pudi_is_data = 0;
        pudi_is_invalid = 0;
        if(is_invalid) begin
            pudi_is_invalid = 1;
            pudi_is_comma = 0;
            pudi_is_data = 0;
        end else if(PUDI == `K28_5_10b_n || PUDI == `K28_5_10b_p || PUDI == `K28_1_10b_n || PUDI == `K28_1_10b_p || PUDI == `K28_7_10b_n || PUDI == `K28_7_10b_p) begin 
            pudi_is_comma = 1;
            pudi_is_data = 0;
            pudi_is_invalid = 0; 
        end
        
        if(!control && !is_invalid) begin
            pudi_is_data = 1;
            pudi_is_comma = 0;
            pudi_is_invalid = 0;
        end
            
    end
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    reg [1:0] good_cgs, next_good_cgs; 

    always@(posedge clk) begin
        if(reset) begin
            state <= 0;
            good_cgs <= 0;
            code_sync_status <= 0;
            rx_even <= 0;
        end else begin
            state <= next_state;
            code_sync_status <= next_code_sync_status;
            rx_even <= next_rx_even;
            good_cgs <= next_good_cgs;
        end
    end
    
    always@(*) begin
        next_code_sync_status = code_sync_status;
        next_state = state;
        next_good_cgs = good_cgs;
        next_rx_even = rx_even;
        next_rx_even = rx_even;
        
        case(state)
            LOSS_OF_SYNC: begin
                next_code_sync_status = 0;
                next_rx_even = !rx_even;
                if(!pudi_is_comma || !signal_detect) begin
                    next_state = LOSS_OF_SYNC;
                end else if(signal_detect && pudi_is_comma) begin
                    next_state = COMMA_DETECT_1;
                end
            end
            
            COMMA_DETECT_1: begin
                next_rx_even = 1;
                if(pudi_is_data) begin
                    next_state = ACQUIRE_SYNC_1;
                end else begin
                    next_state = LOSS_OF_SYNC;
                end 
            end
            
            ACQUIRE_SYNC_1: begin
                next_rx_even = !rx_even;
                if(cgbad) begin
                    next_state = LOSS_OF_SYNC;
                end else if(!next_rx_even && pudi_is_comma) begin
                    next_state = COMMA_DETECT_2;
                end else if(!pudi_is_comma && !pudi_is_invalid) begin
                    next_state = ACQUIRE_SYNC_1;
                end
            end
            
            COMMA_DETECT_2: begin
                next_rx_even = 1;
                if(!pudi_is_data) begin
                    next_state = LOSS_OF_SYNC;
                end else begin
                    next_state = ACQUIRE_SYNC_2;
                end
            end
            
            ACQUIRE_SYNC_2: begin
                next_rx_even = !rx_even;
                if(cgbad) begin
                    next_state = LOSS_OF_SYNC;
                end else if(!next_rx_even && pudi_is_comma) begin
                    next_state = COMMA_DETECT_3;
                end else if(!pudi_is_comma && !pudi_is_invalid) begin
                    next_state = ACQUIRE_SYNC_2;
                end
            end
            
            COMMA_DETECT_3: begin
                next_rx_even = 1;
                if(!pudi_is_data) begin
                    next_state = LOSS_OF_SYNC;
                end else begin
                    next_state = SYNC_ACQUIRED_1;
                end
            end
            
            SYNC_ACQUIRED_1: begin
                next_code_sync_status = 1;
                next_rx_even = !rx_even;
                if(cggood) begin
                    next_state = SYNC_ACQUIRED_1;
                end else if(cgbad) begin
                    next_state = SYNC_ACQUIRED_2;
                end 
            end
            
            SYNC_ACQUIRED_2: begin
                next_rx_even = !rx_even;
                next_good_cgs = 0;
                if(cgbad) begin
                    next_state = SYNC_ACQUIRED_3;
                end else if(cggood) begin
                    next_state = SYNC_ACQUIRED_2A; 
                end
            end
            
            SYNC_ACQUIRED_2A: begin
                next_rx_even = !rx_even;
                next_good_cgs = good_cgs + 1;
                if(next_good_cgs != 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_2A; 
                end else if(next_good_cgs == 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_1;
                end else if(cgbad) begin
                    next_state = SYNC_ACQUIRED_3;
                end
            end
            
            SYNC_ACQUIRED_3: begin
                next_rx_even = !rx_even;
                next_good_cgs = 0;
                if(cgbad) begin
                    next_state = SYNC_ACQUIRED_4;
                end else if(cggood) begin
                    next_state = SYNC_ACQUIRED_3A;
                end
            end
            
            SYNC_ACQUIRED_3A: begin
                next_rx_even = !rx_even;
                next_good_cgs = good_cgs + 1;
                if(next_good_cgs != 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_3A; 
                end else if(next_good_cgs == 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_2;
                end else if(cgbad) begin
                    next_state = SYNC_ACQUIRED_4;
                end
            end
            
            SYNC_ACQUIRED_4: begin
                next_rx_even = !rx_even;
                next_good_cgs = 0;
                if(cgbad) begin
                    next_state = LOSS_OF_SYNC;
                end else if(cggood) begin
                    next_state = SYNC_ACQUIRED_4A;
                end
            end
            
            SYNC_ACQUIRED_4A: begin
                next_rx_even = !rx_even;
                next_good_cgs = good_cgs + 1;
                if(next_good_cgs != 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_4A; 
                end else if(next_good_cgs == 3 && cggood) begin
                    next_state = SYNC_ACQUIRED_3;
                end else if(cgbad) begin
                    next_state = LOSS_OF_SYNC;
                end
            end
        endcase
    end
    
endmodule
