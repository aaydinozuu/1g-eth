`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.08.2025 14:19:11
// Design Name: 
// Module Name: new_tx
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


module new_tx(
    input clk, reset, TX_EN, TX_ER, tx_disparity, 
    input [1:0] xmit,
    input [7:0] TXD,
    input [15:0] tx_Config_Reg,
    output reg control,
    output reg [7:0] tx_code_group,
    output reg COL,
    output reg transmitting
    );
    `include "defines.vh"
    wire VOID;
    assign VOID = (!TX_EN && TX_ER && TXD != 8'b00001111) || (TX_EN && TX_ER);
    
    localparam [4:0]    
        TX_TEST_XMIT = 5'd0,
        CONFIGURATION = 5'd1,
        IDLE = 5'd2,
        XMIT_DATA = 5'd3,
        START_OF_PACKET = 5'd4,
        ALIGN_ERR_START = 5'd5,
        START_ERROR = 5'd6,
        TX_DATA_ERROR = 5'd7,
        TX_PACKET = 5'd8,
        TX_DATA = 5'd9,
        END_OF_PACKET_EXT = 5'd10,
        END_OF_PACKET_NOEXT = 5'd11,
        EXTEND_BY_1 = 5'd12,
        CARRIER_EXTEND = 5'd13,
        EPD2_NOEXT = 5'd14,
        EPD3 = 5'd15,
        XMIT_LPIDLE = 5'd16;

    
///////////////////////// xmit_set ////////////////////////////
    reg xmit_config_set, xmit_idle_set, xmit_data_set;
//    reg next_xmit_config_set, next_xmit_idle_set, next_xmit_data_set;
//    always@(posedge clk) begin
//        if(reset) begin
//            xmit_config_set <= 1'b0;
//            xmit_idle_set   <= 1'b0;
//            xmit_data_set   <= 1'b0;
//        end else begin            
//            xmit_config_set <= next_xmit_config_set;
//            xmit_idle_set <= next_xmit_idle_set;
//            xmit_data_set <= next_xmit_data_set;
//        end
//    end
    
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
 
 
 //////////////////////// state next_state ////////////////////
    
    reg [7:0] next_tx_code_group;
    reg next_control;
    reg [4:0] state, next_state;
    reg next_transmitting, next_COL;   
    reg [3:0] config_cnt, next_config_cnt;
    reg idle_cnt, next_idle_cnt;
    reg tx_even, next_tx_even, PUDR, next_PUDR;
    reg first_config_flag, next_first_config_flag;
    reg first_idle_flag, next_first_idle_flag;
    
    wire [7:0] tx_Config_Reg_lo = tx_Config_Reg[7:0]; 
    wire [7:0] tx_Config_Reg_hi = tx_Config_Reg[15:8]; 

    
    ///////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////
         
    always@(posedge clk) begin
        if(reset) begin
            state <= TX_TEST_XMIT;
            config_cnt <= 0;
            idle_cnt <= 0;
            control <= 0;
            PUDR <= 0;
            transmitting <= 0;
            COL <= 0;
            first_idle_flag <= 0;
            tx_even <= 0;
            first_config_flag <= 0;
        end else begin
            state <= next_state;
            transmitting <= next_transmitting;
            COL <= next_COL;
            config_cnt <= next_config_cnt;
            idle_cnt <= next_idle_cnt;
            tx_even <= next_tx_even;
            PUDR <= next_PUDR;
            control <= next_control;
            tx_code_group <= next_tx_code_group;
            first_config_flag <= next_first_config_flag;
            first_idle_flag <= next_first_idle_flag;
        end
    end
    
    ////////////////////////////////// states ///////////////////////////////////
    
    always@(*) begin
    
        next_state             = state;
        next_transmitting      = transmitting;
        next_COL               = COL;
        next_config_cnt        = config_cnt;
        next_idle_cnt          = idle_cnt;
        next_tx_even           = tx_even;
        next_PUDR              = PUDR;
        next_first_config_flag = first_config_flag;
        next_first_idle_flag   = first_idle_flag;
        next_control           = control;
        next_tx_code_group     = tx_code_group;

        case(state)
            TX_TEST_XMIT: begin
                next_transmitting = 0;
                next_COL = 0;
                if(xmit_config_set) begin
                    next_state = CONFIGURATION;
                    next_first_config_flag = 1;
                end else if(xmit_idle_set || (xmit_data_set && (TX_EN || TX_ER))) begin
                    next_first_idle_flag = 1;
                    next_state = IDLE;
                end else if(!TX_EN && !TX_ER && xmit_data_set) begin
                    next_state = XMIT_DATA;
                end else begin
                    next_state = TX_TEST_XMIT;
                end
            end
            
            CONFIGURATION: begin
                if(config_cnt == 0) begin
                    next_control = 1;
                    next_tx_code_group = `K28_5;
                    next_tx_even = 1;
                    next_PUDR = 1;
                    next_config_cnt = config_cnt + 1;
                end else if(config_cnt == 1) begin
                    next_control = 0;
                    next_tx_code_group = first_config_flag ? `D21_5 : `D2_2;
                    next_tx_even = 0;
                    next_PUDR = 1;
                    next_config_cnt = config_cnt + 1;
                end else if(config_cnt == 2) begin
                    next_control = 0;
                    next_tx_code_group = tx_Config_Reg_lo;
                    next_tx_even = 1;
                    next_PUDR = 1;
                    next_config_cnt = config_cnt + 1;
                end else if(config_cnt == 3) begin
                    next_control = 0;
                    next_tx_code_group = tx_Config_Reg_hi;
                    next_tx_even = 0;
                    next_PUDR = 1;
                    next_config_cnt = 0;                    
                    if(xmit_config_set) begin
                        next_first_config_flag = 0;
                        next_state = CONFIGURATION;
                    end else begin                        
                        next_first_config_flag = 1;
                        next_state = TX_TEST_XMIT;                                      
                    end
                end
            end
            
            IDLE: begin                
                if(idle_cnt == 0) begin
                    next_tx_code_group = `K28_5;
                    next_tx_even = 1;
                    next_control = 1;
                    next_PUDR = 1;
                    next_idle_cnt = idle_cnt + 1;
                end else if(idle_cnt == 1) begin
                    next_tx_code_group = first_idle_flag ? `D5_6 : `D16_2;
                    next_tx_even = 0;
                    next_control = 0;
                    next_PUDR = 1;
                    next_idle_cnt = 0;
                    if(xmit_data_set && !TX_EN && !TX_ER) begin
                        next_state = XMIT_DATA;
                    end else begin
                        next_first_idle_flag = 0;
                        next_state = IDLE;
                    end
                end                
            end
            
            XMIT_DATA: begin
                if(idle_cnt == 0) begin
                    next_tx_code_group = `K28_5;
                    next_tx_even = 1;
                    next_control = 1;
                    next_PUDR = 1;
                    next_idle_cnt = idle_cnt + 1;
                end else if(idle_cnt == 1) begin
                    next_tx_code_group = first_idle_flag ? `D5_6 : `D16_2;
                    next_tx_even = 0;
                    next_control = 0;
                    next_PUDR = 1;
                    next_idle_cnt = 0;
                    if(!TX_EN) begin
                        next_first_idle_flag = 0;
                        next_state = XMIT_DATA;
                    end 
                    if(TX_EN && !TX_ER) begin                        
                        next_state = START_OF_PACKET;
                    end 
                    if(TX_EN && TX_ER) begin
                        next_state = ALIGN_ERR_START;
                    end 
                end 
            end
            
            START_OF_PACKET: begin
                next_transmitting = 1;
                next_COL = 1;
                next_control = 1;
                next_tx_code_group = `K27_7;
                next_tx_even = !tx_even;
                next_PUDR = 1;
                next_state = TX_PACKET;
            end
            
            TX_PACKET: begin
                if(TX_EN) begin
                    next_state = TX_DATA;
                end 
                if(!TX_EN && !TX_ER) begin
                    next_state = END_OF_PACKET_NOEXT;
                end 
                if(!TX_EN && TX_ER) begin
                    next_state = END_OF_PACKET_EXT;
                end
            end 
            
            TX_DATA: begin
                if(VOID) begin
                    next_control = 1;
                    next_tx_code_group = `K30_7;
                end else begin
                    next_control = 0;
                    next_tx_code_group = TXD;
                end
                next_COL = 1;
                next_tx_even = !tx_even;
                next_PUDR = 1;
                next_state = TX_PACKET;                
            end
            
            END_OF_PACKET_NOEXT: begin
                if(!tx_even) begin ////////////////////////////////////////////////////////////////////////////
                    next_transmitting = 0;
                end
                next_tx_code_group = `K29_7; 
                next_COL = 0;
                next_PUDR = 1;
                next_tx_even = !tx_even;
                next_state = EPD2_NOEXT;
                next_control = 1;
                               
            end
            
            EPD2_NOEXT: begin
                next_PUDR = 1;
                next_tx_even = !tx_even;
                next_transmitting = 0;
                next_control = 1;
                next_tx_code_group = `K23_7;
                if(!tx_even) begin/////////////////////////////////////////////////////////////////////
                    next_state = XMIT_DATA;
                end 
                if(tx_even) begin
                    next_state = EPD3;
                end
            end
            
            EPD3: begin
                next_tx_code_group = `K23_7;
                next_control = 1;
                next_state = XMIT_DATA;
                next_PUDR = 1;
                next_tx_even = !tx_even;
            end
            
            END_OF_PACKET_EXT: begin
                next_COL = 1;
                next_PUDR = 1;
                next_control = 1;
                next_tx_even = !tx_even;
                if(VOID) begin
                    next_tx_code_group = `K30_7;
                end else begin
                    next_tx_code_group = `K29_7;
                end
                
                if(!TX_ER) begin
                    next_state = EXTEND_BY_1;
                end if(TX_ER) begin
                    next_state = CARRIER_EXTEND;
                end
            end
            
            EXTEND_BY_1: begin
                if(!tx_even) begin ////////////////////////////////////////////////////////////////////////////
                    next_transmitting = 0;
                end
                next_COL = 0;
                next_control = 1;
                next_tx_code_group = `K23_7;
                next_PUDR = 1;
                next_tx_even = !tx_even;
                next_state = EPD2_NOEXT;
            end
            
            CARRIER_EXTEND: begin
                next_COL = 1;
                next_PUDR = 1;
                next_control = 1;
                next_tx_even = !tx_even;
                if(VOID) begin
                    next_tx_code_group = `K30_7;
                end else begin
                    next_tx_code_group = `K23_7;
                end
                
                if(!TX_EN && !TX_ER) begin
                    next_state = EXTEND_BY_1;
                end 
                if(TX_EN && TX_ER) begin
                    next_state = START_ERROR;
                end 
                if(TX_EN && !TX_ER) begin
                    next_state = START_OF_PACKET;
                end
                if(!TX_EN && TX_ER) begin
                    next_state = CARRIER_EXTEND;
                end
            end
            
            ALIGN_ERR_START: begin
                next_state = START_ERROR;
            end
            
            START_ERROR: begin
                next_transmitting = 1;
                next_COL = 1;
                next_control = 0;
                next_tx_code_group = TXD;
                next_PUDR = 1;
                next_tx_even = !tx_even;
                next_state = TX_DATA_ERROR;
            end
            
            TX_DATA_ERROR: begin
                next_COL = 1;
                next_control = 0;
                next_tx_code_group = TXD;
                next_PUDR = 1;
                next_tx_even = !tx_even;
                next_state = TX_PACKET;
            end
        endcase
    end
    
    //////////////////////////////////////////////////////////////
    

endmodule
