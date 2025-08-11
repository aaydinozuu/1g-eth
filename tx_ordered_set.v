`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2025 18:15:02
// Design Name: 
// Module Name: tx_ordered_set
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


module tx_ordered_set(
input TX_EN, TX_ER, reset, TX_OSET_indicate, tx_even,
input [7:0] TXD,
input [1:0] xmit,
output reg [2:0] tx_o_set
    );
    
    reg [4:0] state_os;

    parameter TX_TEST_XMIT = 5'd0;
    parameter CONFIGURATION = 5'd1;
    parameter IDLE = 5'd2;
    parameter XMIT_DATA = 5'd3;
    parameter START_OF_PACKET = 5'd4;
    parameter ALIGN_ERR_START = 5'd5;
    parameter START_ERROR = 5'd6;
    parameter TX_DATA_ERROR = 5'd7;
    parameter TX_PACKET = 5'd8;
    parameter TX_DATA = 5'd9;
    parameter END_OF_PACKET_EXT = 5'd10;
    parameter END_OF_PACKET_NOEXT = 5'd11;
    parameter EXTEND_BY_1 = 5'd12;
    parameter CARRIER_EXTEND = 5'd13;
    parameter EPD2_NOEXT = 5'd14;
    parameter EPD3 = 5'd15;
    parameter XMIT_LPIDLE = 5'd16;
    
    
    wire xmit_idle_check;
    assign xmit_idle_check = ((xmit == 2'd1) | ((xmit == 2'd2) & TX_EN & TX_ER));
    
    wire VOID;
    assign VOID = (!TX_EN & TX_ER & TXD != 8'b00001111) | (TX_EN & TX_ER);
    
    reg transmitting, COL;
    
    always@(*) begin
        if(reset) begin
            state_os = 0;
            tx_o_set = 0;
        end else begin
        case (state_os)
            TX_TEST_XMIT: begin
                transmitting = 0;
                COL = 0;
                if(xmit == 2'd0) begin
                    state_os = CONFIGURATION;
                end else if(xmit_idle_check) begin
                    state_os = IDLE;
                end else if((xmit == 2'd2) & !TX_EN & !TX_ER) begin
                    state_os = XMIT_DATA;
                end 
            end
            
            XMIT_DATA: begin
                tx_o_set = 3'd1;
                if(TX_EN & TX_ER) begin state_os = ALIGN_ERR_START; end
                 else if(TX_EN & !TX_ER & TX_OSET_indicate) begin state_os = START_OF_PACKET; end
                 else if(!TX_EN & TX_OSET_indicate) begin state_os = XMIT_DATA; end                                  
            end
            
            ALIGN_ERR_START: begin
                if(TX_OSET_indicate) begin
                    state_os = START_ERROR;
                end
            end
            
            START_ERROR: begin
                transmitting = 1;
                COL = 1;
                tx_o_set = 3'd2;
                if(TX_OSET_indicate) begin
                    state_os = TX_DATA_ERROR;
                end
            end
            
            TX_DATA_ERROR: begin
                COL = 1;
                tx_o_set = 3'd3;
                if(TX_OSET_indicate) begin
                    state_os = TX_PACKET;
                end
            end

            TX_PACKET: begin
                if (TX_EN) begin
                    state_os = TX_DATA;
                end else if(!TX_EN & !TX_ER)begin
                    state_os = EPD2_NOEXT;
                end else if (!TX_EN & TX_ER) begin
                    state_os = END_OF_PACKET_EXT;
                end
            end
            
            END_OF_PACKET_NOEXT: begin                                        
                    if(!tx_even) begin
                        transmitting = 1'b0;                         
                    end                    
                    COL = 1'b0;                    
                    tx_o_set = 3'd4;
                    if(TX_OSET_indicate) begin
                        state_os = EPD2_NOEXT;
                    end
                end

            END_OF_PACKET_EXT: begin                    
                    COL = 1'b1; //receiving
                    if(VOID) begin
                        tx_o_set = 3'd3;
                    end else begin
                        tx_o_set = 3'd4;
                    end

                    if(TX_ER & TX_OSET_indicate) begin
                        state_os = CARRIER_EXTEND;
                    end else if(!TX_ER & TX_OSET_indicate) begin
                        state_os = EXTEND_BY_1;
                    end
                end

             EXTEND_BY_1: begin                    
                    COL = 1'b0;
                    tx_o_set = 3'd5;
                    if(!tx_even) begin ///////////////////////////////////////////////////////////////////////////
                        transmitting = 0;
                    end
                    if(TX_OSET_indicate) begin
                        state_os = EPD2_NOEXT;
                    end
                end
            
            CARRIER_EXTEND: begin                    
                    COL = 1'b0;
                    if(VOID) begin
                        tx_o_set = 3'd3;
                    end else begin
                        tx_o_set = 3'd5;
                    end

                    if(!TX_EN & !TX_ER & TX_OSET_indicate) begin
                        state_os = EXTEND_BY_1;
                    end else if(TX_EN & !TX_ER & TX_OSET_indicate) begin
                        state_os = START_OF_PACKET;
                    end else if(TX_EN & TX_ER & TX_OSET_indicate) begin
                        state_os = START_ERROR;
                    end else if(!TX_EN & TX_ER & TX_OSET_indicate) begin
                        state_os = CARRIER_EXTEND;
                    end
                end
                
             EPD2_NOEXT: begin                    
                    transmitting = 1'b0;
                    tx_o_set = 3'd5;
                    if(!tx_even & TX_OSET_indicate) begin
                        state_os = XMIT_DATA;
                    end else if(tx_even & TX_OSET_indicate) begin
                        state_os = EPD3;
                    end
                end

             EPD3: begin                    
                    tx_o_set = 3'd5;
                    if(TX_OSET_indicate) begin
                        state_os = XMIT_DATA;
                    end
               end
             
             CONFIGURATION: begin
                tx_o_set = 3'd0;
                if(xmit == 2 & TX_OSET_indicate & !TX_EN & !TX_ER) begin
                    state_os = XMIT_DATA; ///////////////////////////
                end          
             end 
              
             IDLE: begin
                tx_o_set = 3'd1;
                if(xmit == 2 & TX_OSET_indicate & !TX_EN & !TX_ER) begin
                    state_os = XMIT_DATA;
                end
             end
             
             TX_DATA: begin
                COL = 1;
                if(VOID) begin
                    tx_o_set = 3'd3;
                end else begin
                    tx_o_set = 3'd6;
                end
                
                if(TX_OSET_indicate) begin
                    state_os = TX_PACKET;
                end
             end
             
             START_OF_PACKET: begin
                transmitting = 1;
                COL = 1;
                tx_o_set = 3'd2;
                if(TX_OSET_indicate) begin
                    state_os = TX_PACKET;
                end
             end
             default: state_os = state_os - 1;
        endcase
    end
    end
endmodule
