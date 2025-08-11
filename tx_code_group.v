`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2025 19:49:20
// Design Name: 
// Module Name: tx_code_group
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
`include "defines.vh"

module tx_code_group(
input clk, reset, cg_timer_done, tx_disparity,
input [2:0] tx_o_set,
input [7:0] TXD,
input [15:0] tx_Config_Reg,
output reg tx_even, PUDR, TX_OSET_indicate, control,
//output [9:0] enc10b_exit
output reg [7:0] tx_code_group 
    );
//    reg [7:0] tx_code_group; 
    reg [3:0] state;
//    reg control;
    
    wire [7:0] tx_Config_Reg_lo, tx_Config_Reg_hi;
    assign tx_Config_Reg_lo = tx_Config_Reg [7:0];
    assign tx_Config_Reg_hi = tx_Config_Reg [15:8];
    
    parameter GENERATE_CODE_GROUPS = 4'd0; 
    parameter CONFIGURATION_C1A = 4'd1;
    parameter CONFIGURATION_C1B = 4'd2;
    parameter CONFIGURATION_C1C = 4'd3;
    parameter CONFIGURATION_C1D = 4'd4;
    parameter CONFIGURATION_C2A = 4'd5;
    parameter CONFIGURATION_C2B = 4'd6;
    parameter CONFIGURATION_C2C = 4'd7;
    parameter CONFIGURATION_C2D = 4'd8;
    parameter DATA_GO = 4'd9;
    parameter SPECIAL_GO = 4'd10;
    parameter IDLE_DISPARITY_TEST = 4'd11;
    parameter IDLE_DISPARITY_WRONG = 4'd12;
    parameter IDLE_DISPARITY_OK = 4'd13;
    parameter IDLE_I1B = 4'd14;
    parameter IDLE_I2B = 4'd15;
    
    
//    enc Enc(
//    .clk(clk), .reset(reset), .control(control), .data(tx_code_group),
//    .data_10b(enc10b_exit), .rd(tx_disparity)
//    );
    
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            tx_even <= 0;
            PUDR <= 0;
            TX_OSET_indicate <= 0;
            tx_code_group <= 0;
            state <= 0;
            control <= 0;
        end else begin
            case(state)
               GENERATE_CODE_GROUPS: begin
                    case(tx_o_set) 
                        3'd0: state <= CONFIGURATION_C1A;
                        3'd1: state <= IDLE_DISPARITY_TEST;
                        3'd2: state <= SPECIAL_GO;
                        3'd3: state <= SPECIAL_GO;
                        3'd4: state <= SPECIAL_GO;
                        3'd5: state <= SPECIAL_GO;
                        3'd6: state <= DATA_GO;
                    endcase
               end
               
               CONFIGURATION_C1A: begin
                    tx_code_group <= `K28_5;
                    tx_even <= 1;
                    control <= 1;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C1B;
                    end
               end 
                
                CONFIGURATION_C1B: begin
                    tx_code_group <= `D21_5;
                    control <= 0;
                    tx_even <= 0;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C1C;
                    end
               end 
                
                CONFIGURATION_C1C: begin
                    tx_code_group <= tx_Config_Reg_lo;
                    tx_even <= 1;
                    control <= 0;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C1D;
                    end
               end
               
               CONFIGURATION_C1D: begin
                    tx_code_group <= tx_Config_Reg_hi;
                    tx_even <= 0;
                    control <= 0;
                    PUDR <= 1;
                    if((tx_o_set == 3'd0) & cg_timer_done) begin
                        state <= CONFIGURATION_C2A;
                    end else if((tx_o_set != 3'd0) & cg_timer_done) begin
                        state <= GENERATE_CODE_GROUPS;
                    end
               end
                 
                 CONFIGURATION_C2A: begin
                    tx_code_group <= `K28_5;
                    tx_even <= 1;
                    control <= 1;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C2B;
                    end
               end
               
                  CONFIGURATION_C2B: begin
                    tx_code_group <= `D2_2;
                    tx_even <= 0;
                    control <= 0;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C2C;
                    end
               end 
                
                CONFIGURATION_C2C: begin
                    tx_code_group <= tx_Config_Reg_lo;
                    tx_even <= 1;
                    control <= 0;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= CONFIGURATION_C2D;
                    end
               end 
                 
                 CONFIGURATION_C2D: begin
                    tx_code_group <= tx_Config_Reg_hi;
                    tx_even <= 0;
                    control <= 0;
                    TX_OSET_indicate <= 1;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= GENERATE_CODE_GROUPS;
                    end 
               end
               
                  SPECIAL_GO: begin
                    case(tx_o_set)
                        3'd2: tx_code_group <= `K27_7;
                        3'd3: tx_code_group <= `K30_7;
                        3'd4: tx_code_group <= `K29_7;
                        3'd5: tx_code_group <= `K23_7;
                    endcase
                    control <= 1;
                    tx_even <= !tx_even;
                    TX_OSET_indicate <= 1;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= GENERATE_CODE_GROUPS;
                    end 
                  end
                  
                  
                  DATA_GO: begin
                    tx_code_group <= TXD;
                    control <= 0;
                    tx_even <= !tx_even;
                    TX_OSET_indicate <= 1;
                    PUDR <= 1;
                    if(cg_timer_done) begin
                        state <= GENERATE_CODE_GROUPS;
                    end
                    end
                    
                    IDLE_DISPARITY_TEST: begin
                        if(tx_disparity) begin
                            state <= IDLE_DISPARITY_WRONG;
                        end else begin
                            state <= IDLE_DISPARITY_OK;
                        end
                    end
                    
                    IDLE_DISPARITY_WRONG: begin
                        control <= 1;
                        tx_code_group <= `K28_5;
                        tx_even <= 1;
                        PUDR <= 1;
                        if(cg_timer_done) begin
                            state <= IDLE_I1B;
                        end
                    end
                    
                    IDLE_I1B: begin
                        tx_code_group <= `D5_6;
                        tx_even <= 0;
                        control <= 0;
                        TX_OSET_indicate <= 1;
                        PUDR <= 1;
                        if(cg_timer_done) begin
                            state <= GENERATE_CODE_GROUPS;
                        end
                    end
                    
                    IDLE_DISPARITY_OK: begin
                        tx_code_group <= `K28_5;
                        tx_even <= 1;
                        control <= 1;
                        PUDR <= 1;
                        if(cg_timer_done) begin
                            state <= IDLE_I2B;
                        end
                    end
                    
                    IDLE_I2B: begin
                        tx_code_group <= `D16_2;
                        tx_even <= 0;
                        control <= 0;
                        TX_OSET_indicate <= 1;
                        PUDR <= 1;
                        if(cg_timer_done) begin
                            state <= GENERATE_CODE_GROUPS;
                        end
                    end
                    default: state <= GENERATE_CODE_GROUPS;
            endcase
        end
    end 
endmodule
