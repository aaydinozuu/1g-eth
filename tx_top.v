`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2025 11:46:48
// Design Name: 
// Module Name: tx_top
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


module tx_top(
input TX_EN, TX_ER, clk, reset, cg_timer_done,
input [7:0] TXD,
input [15:0] tx_Config_Reg,
input [1:0] xmit,
output  tx_even, PUDR,
input TX_OSET_indicate,
output [9:0] enc10b_exit
    );
    
    wire [2:0] tx_o_set;
    wire rd, control;
    wire [7:0] tx_code_group;
    
    tx_ordered_set tos (
    .TX_EN(TX_EN), .TX_ER(TX_ER), .reset(reset),
    .TX_OSET_indicate(TX_OSET_indicate), .tx_even(tx_even),
    .TXD(TXD), .xmit(xmit),
    .tx_o_set(tx_o_set)
    );
    
    tx_code_group tcg (
    .clk(clk), .reset(reset), 
    .cg_timer_done(cg_timer_done), .tx_disparity(rd),
    .tx_o_set(tx_o_set), .TXD(TXD), .tx_Config_Reg(tx_Config_Reg),
    .tx_even(tx_even), .PUDR(PUDR), .TX_OSET_indicate(TX_OSET_indicate),
    .tx_code_group(tx_code_group), .control(control) 
    );
    
    enc en10 (
    .clk(clk), .reset(reset), .control(control), .data(tx_code_group),
    .data_10b(enc10b_exit), .rd(rd)
    );
endmodule
