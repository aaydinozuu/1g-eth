`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.08.2025 15:12:30
// Design Name: 
// Module Name: new_top
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


module new_top(
input TX_EN, TX_ER, clk, reset,
input [15:0] tx_Config_Reg,
input [7:0] TXD,
input [1:0] xmit,
output PUDR,
output [9:0] enc10b_exit
    );
    
    wire [2:0] tx_o_set;
    wire rd, control;
    wire [7:0] tx_code_group;
    
    new_tx tx (
    .TX_EN(TX_EN), .TX_ER(TX_ER), .reset(reset), .clk(clk), .tx_disparity(rd), .control(control),
    .xmit(xmit), .tx_code_group(tx_code_group), .tx_Config_Reg(tx_Config_Reg), .TXD(TXD)
    );
    
    
    enc en10 (
    .clk(clk), .reset(reset), .control(control), .data(tx_code_group),
    .encoded_data(enc10b_exit), .rd(rd)
    );
endmodule