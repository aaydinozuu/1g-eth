`timescale 1ns / 1ps

module rx(
    input clk, reset, EVEN, carrier_detect,
    input sync_status,
    input [1:0] xmit,
    input [9:0] data_10b, 
    output reg [15:0] rx_Config_Reg,
    output reg receiving, RX_DV, RX_ER,
    output reg [7:0] RXD,
    output reg [1:0] RUDI
//    output reg [9:0] data_out
    );
    
    localparam [4:0]
        WAIT_FOR_K          = 5'd0,
        RX_K                = 5'd1,
        RX_CB               = 5'd2,
        IDLE_D              = 5'd3,
        RX_CC               = 5'd4,
        CARRIER_DETECT      = 5'd5,
        RX_CD               = 5'd6,
        RX_INVALID          = 5'd7,
        FALSE_CARRIER       = 5'd8,
        LINK_FAILED         = 5'd9,
        START_OF_PACKET     = 5'd10,
        RECEIVE             = 5'd11,
        EARLY_END           = 5'd12,
        RX_DATA_ERROR       = 5'd13,
        TRI_RRI             = 5'd14,
        RX_DATA             = 5'd15,
        TRR_EXTEND          = 5'd16,
        EARLY_END_EXT       = 5'd17,
        EPD2_CHECK_END      = 5'd18,
        PACKET_BURST_RRS    = 5'd19,
        EXTEND_ERR          = 5'd20;
       
       reg [4:0] state, next_state;
       reg next_receiving, next_RX_DV, next_RX_ER;
       reg [7:0] next_RXD;
       reg [9:0] next_data_out;
       reg [1:0] next_RUDI; 
       reg [8:0] SUDI [0:2];
       reg [15:0] next_rx_Config_Reg;


//////////////////////////////// CHECK_END ////////////////////////

localparam  KDK = 4'd0,
            KDD = 4'd1,
            TRK = 4'd2,
            TRR = 4'd3,
            RRR = 4'd4,
            DDD = 4'd5,
            RRK = 4'd6,
            RRS = 4'd7;

wire [3:0] check_end =
    ((SUDI[2]=={1'b1,8'hBC}) && (SUDI[1][8]==1'b0) && (SUDI[0]=={1'b1,8'hBC}))                                                  ? KDK :
    ((SUDI[2]=={1'b1,8'hBC}) && ((SUDI[1]=={1'b0,8'hB5}) || (SUDI[1]=={1'b0,8'h42})) && (SUDI[0]=={1'b0,8'h00}))                ? KDD :
    ((SUDI[2]=={1'b1,8'hFD}) && (SUDI[1]=={1'b1,8'hF7}) && (SUDI[0]=={1'b1,8'hBC}))                                             ? TRK :
    ((SUDI[2]=={1'b1,8'hFD}) && (SUDI[1]=={1'b1,8'hF7}) && (SUDI[0]=={1'b1,8'hF7}))                                             ? TRR :
    ((SUDI[2]=={1'b1,8'hF7}) && (SUDI[1]=={1'b1,8'hF7}) && (SUDI[0]=={1'b1,8'hF7}))                                             ? RRR :
    ((SUDI[2][8]==1'b0) && (SUDI[1][8]==1'b0) && (SUDI[0][8]==1'b0))                                                            ? DDD :
    ((SUDI[2]=={1'b1,8'hF7}) && (SUDI[1]=={1'b1,8'hF7}) && (SUDI[0]=={1'b1,8'hBC}))                                             ? RRK :
    ((SUDI[2]=={1'b1,8'hF7}) && (SUDI[1]=={1'b1,8'hF7}) && (SUDI[0]=={1'b1,8'hFB}))                                             ? RRS :
                                                                                                                                4'd8; // NONE  
//////////////////////////////////////////////////////////////////////////////////////////////////
 
wire [7:0] data_in;
wire control, is_invalid;       
///////////////////////////////////////////////////DECODER///////////////////////////////////////////
dec deco(
.clk(clk),
.reset(reset),
.data_10b(data_10b),
.is_invalid(is_invalid),
.control(control),
.data(data_in)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////        



always@(posedge clk) begin
    if(reset) begin
        SUDI[0] <= 0;
        SUDI[1] <= 0;
        SUDI[2] <= 0;
    end else begin
        SUDI[0] <= {control, data_in};
        SUDI[1] <= SUDI[0];
        SUDI[2] <= SUDI[1];
    end
end
 
///////////////////////////////////////////////////////
reg sudi_is_k, sudi_is_d2, sudi_is_d21, sudi_is_s, sudi_is_data, sudi_is_t, sudi_is_r;
always@(*) begin
    sudi_is_k = 0;
    sudi_is_r = 0;
    sudi_is_t = 0;
    sudi_is_d2 = 0;
    sudi_is_d21 = 0;
    sudi_is_s = 0;
    sudi_is_data = 0;
    
    case(SUDI[0][8:0])
        9'b110111100: begin 
        sudi_is_k = 1;
        sudi_is_r = 0;
        sudi_is_t = 0;
        sudi_is_d2 = 0;
        sudi_is_d21 = 0;
        sudi_is_s = 0;
        sudi_is_data = 0; 
        end
        
        9'b001000010: begin 
        sudi_is_k = 0;
        sudi_is_r = 0;
        sudi_is_t = 0;
        sudi_is_d2 = 1;
        sudi_is_d21 = 0;
        sudi_is_s = 0;
        sudi_is_data = 1; 
        end
        
        9'b010110101: begin 
        sudi_is_k = 0;
        sudi_is_d2 = 0;
        sudi_is_d21 = 1;
        sudi_is_r = 0;
        sudi_is_t = 0;
        sudi_is_s = 0;
        sudi_is_data = 1; 
        end
        
        9'b111111011: begin 
        sudi_is_k = 0;
        sudi_is_d2 = 0;
        sudi_is_r = 0;
        sudi_is_t = 0;
        sudi_is_d21 = 0;
        sudi_is_s = 1;
        sudi_is_data = 0; 
        end
        
        9'b111111101: begin 
        sudi_is_k = 0;
        sudi_is_d2 = 0;
        sudi_is_r = 0;
        sudi_is_t = 1;
        sudi_is_d21 = 0;
        sudi_is_s = 0;
        sudi_is_data = 0; 
        end
        
        9'b111110111: begin 
        sudi_is_k = 0;
        sudi_is_d2 = 0;
        sudi_is_r = 1;
        sudi_is_t = 0;
        sudi_is_d21 = 0;
        sudi_is_s = 0;
        sudi_is_data = 0; 
        end
        
        default: begin 
        sudi_is_k = 0;
        sudi_is_d2 = 0;
        sudi_is_r = 0;
        sudi_is_t = 0;
        sudi_is_d21 = 0;
        sudi_is_s = 0;
        sudi_is_data = 1; 
        end
    endcase 
end

//////////////// SUDI SET //////////////////////////////

///////////////////////// xmit_set ////////////////////////////
    reg xmit_config_set, xmit_idle_set, xmit_data_set;
    always@(*) begin
        xmit_config_set = 1'b0;
        xmit_idle_set   = 1'b0;
        xmit_data_set   = 1'b0;            
        if(xmit == 0) begin
            xmit_config_set = 1;
            xmit_idle_set = 0;
            xmit_data_set = 0;
        end else if(xmit == 1) begin
            xmit_config_set = 0;
            xmit_idle_set = 1;
            xmit_data_set = 0;
        end else if(xmit == 2) begin
            xmit_config_set = 0;
            xmit_idle_set = 0;
            xmit_data_set = 1;
        end
    end
 /////////////////////////////////////////////////////////////
        
always@(posedge clk) begin
    if(reset) begin
        RUDI <= 0;
        state <= WAIT_FOR_K;
        receiving <= 0;
        RXD <= 0;
        rx_Config_Reg <= 0;
//        data_out <= 0;
        RX_DV <= 0;
        RX_ER <= 0;
    end else begin
        RUDI <= next_RUDI;
        RXD <= next_RXD;
        rx_Config_Reg <= next_rx_Config_Reg;
        state <= next_state;
        receiving <= next_receiving;
        RX_DV <= next_RX_DV;
        RX_ER <= next_RX_ER;
//        data_out <= next_data_out;
    end
end 


wire idle_d = (!sudi_is_d21 && !sudi_is_d2) ? 1 : 0;

always@(*) begin
    next_state = state;
    next_RXD = RXD;
    next_RUDI = RUDI;
    next_receiving = receiving;
    next_RX_DV = RX_DV;
    next_RX_ER = RX_ER;
    next_rx_Config_Reg = rx_Config_Reg;
//    next_data_out = data_out;
    case(state)
        WAIT_FOR_K: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_receiving = 0;
            next_RX_DV = 0;
            next_RX_ER = 0;
            if(sudi_is_k && EVEN) begin
                next_state = RX_K; 
            end 
        end
    
        RX_K: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_DV = 0;
            next_RX_ER = 0;
            next_receiving = 0;
            if((!xmit_data_set && sudi_is_data && !sudi_is_d21 && !sudi_is_d2) || (xmit_data_set && idle_d)) begin
                next_state = IDLE_D;
            end 
            else if(!sudi_is_data && !xmit_data_set) begin
                next_state = RX_INVALID;
            end 
            else if(sudi_is_d21 || sudi_is_d2) begin
                next_state = RX_CB;
            end
        end
        
        RX_CB: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_receiving = 0;
            next_RX_DV = 0;
            next_RX_ER = 0;
            if(sudi_is_data) begin
                next_state = RX_CC;
            end 
            if(!sudi_is_data) begin
                next_state = RX_INVALID;
            end
        end
        
        RX_CC: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_rx_Config_Reg[7:0] = data_in;
            if(sudi_is_data) begin
                next_state = RX_CD;
            end 
            if(!sudi_is_data) begin
                next_state = RX_INVALID;
            end
        end
        
        RX_CD: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_rx_Config_Reg[15:8] = data_in;
            next_RUDI = 0;
            if(sudi_is_k && EVEN) begin
                next_state = RX_K;
            end 
            if(!sudi_is_k && !EVEN) begin
                next_state = RX_INVALID;
            end
        end
        
        IDLE_D: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_receiving = 0;
            next_RX_DV = 0;
            next_RX_ER = 0;
            next_RUDI = 1;
            if(!sudi_is_k && !xmit_data_set) begin
                next_state = RX_INVALID;
            end 
            if((xmit_data_set && !carrier_detect) || sudi_is_k) begin
                next_state = RX_K;
            end 
            if(xmit_data_set && carrier_detect) begin
                next_state = CARRIER_DETECT;
            end
        end
        
        CARRIER_DETECT: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_receiving = 1;
            if(!sudi_is_s) begin
                next_state = FALSE_CARRIER;
            end 
            if(sudi_is_s) begin
                next_state = START_OF_PACKET;
            end
        end
        
        FALSE_CARRIER: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_ER = 1;
            next_RXD = 8'b00001110;
            if(sudi_is_k && EVEN) begin
                next_state = RX_K;
            end
        end
        
        RX_INVALID: begin
            if(!sync_status) next_state = LINK_FAILED;
            if(xmit_config_set) begin
                next_RUDI = 2;
            end
            if(xmit_data_set) begin
                next_receiving = 1;
            end
            
            if(sudi_is_k && EVEN) begin
                next_state = RX_K;
            end 
            if(!(sudi_is_k && EVEN)) begin
                next_state = WAIT_FOR_K;
            end
        end
        
        START_OF_PACKET: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_DV = 1;
            next_RX_ER = 0;
            next_RXD = 8'b01010101;
            next_state = RECEIVE;
        end
        
        RECEIVE: begin
            if(!sync_status) next_state = LINK_FAILED;
            if(((check_end == KDK) || (check_end == KDD)) && EVEN) begin
                next_state = EARLY_END;
            end 
            if((check_end == TRK) && EVEN) begin
                next_state = TRI_RRI;
            end 
            if(check_end == TRR) begin
                next_state = TRR_EXTEND;
            end 
            if(check_end == RRR) begin
                next_state = EARLY_END_EXT;
            end 
            if(check_end == DDD) begin
                next_state = RX_DATA;
            end else begin
                next_state = RX_DATA_ERROR;
            end
        end
        
        EARLY_END: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_ER = 1;
            if(!sudi_is_d21 && !sudi_is_d2) begin
                next_state = IDLE_D;
            end 
            if(sudi_is_d21 || sudi_is_d2) begin
                next_state = RX_CB;
            end
        end
        
        RX_DATA_ERROR: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_ER = 1;
            next_state = RECEIVE;
        end
        
        TRI_RRI: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_receiving = 0;
            next_RX_DV = 0;
            next_RX_ER = 0;
            if(sudi_is_k && EVEN) begin
                next_state = RX_K;
            end
        end
        
        RX_DATA: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_ER = 0;
            next_RXD = data_in;
            next_state = RECEIVE;
        end
        
        TRR_EXTEND: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_DV = 0;
            next_RX_ER = 1;
            next_RXD = 8'b00001111;
            next_state = EPD2_CHECK_END;
        end
        
        EARLY_END_EXT: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_ER = 1;
            next_state = EPD2_CHECK_END;
        end
        
        EPD2_CHECK_END: begin
            if(!sync_status) next_state = LINK_FAILED;
            if(check_end == RRR) begin
                next_state = TRR_EXTEND;
            end 
            if(check_end == RRK && EVEN) begin
                next_state = TRI_RRI;
            end 
            if(check_end == RRS) begin
                next_state = PACKET_BURST_RRS;
            end else begin
                next_state = EXTEND_ERR;
            end
        end
        
        PACKET_BURST_RRS: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_DV = 0;
            next_RXD = 8'b00001111;
            if(sudi_is_s) begin
                next_state = START_OF_PACKET;
            end
        end
        
        EXTEND_ERR: begin
            if(!sync_status) next_state = LINK_FAILED;
            next_RX_DV = 0;
            next_RXD = 8'b00011111;
            if(sudi_is_s) begin
                next_state = START_OF_PACKET;
            end 
            if(!sudi_is_k && EVEN) begin
                next_state = RX_K;
            end 
            if(!sudi_is_s && !sudi_is_k && EVEN) begin
                next_state = EPD2_CHECK_END;
            end
        end
        
        LINK_FAILED: begin
            if(!xmit_data_set) begin
                next_RUDI = 2;
            end
            
            if(receiving) begin
                next_receiving = 0;
                next_RX_ER = 0;
            end else begin
                next_RX_DV = 0;
                next_RX_ER = 0;
            end
            next_state = WAIT_FOR_K;
        end
        
    endcase
    
    
end
        

endmodule
