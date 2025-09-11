`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2025 12:19:33
// Design Name: 
// Module Name: pcs
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


module pcs(
    input clk_tx,
    input clk_rx,
    input reset,
    input [16:1] mr_adv_ability,
    input mr_an_enable,
    input [7:0] TXD,
    input TX_EN,
    input TX_ER,
    input [9:0] rx_code_group,
    input signal_detect,
    input repeater_mode,
    output COL,
    output CRS,
    output [7:0] RXD,
    output RX_DV,
    output RX_ER,
    output [9:0] tx_code_group,
    output mr_page_rx,
    output mr_an_complete,
    output mr_np_loaded,
    output toggle_tx,
    output toggle_rx,
    output np_rx,
    output resolve_priority
//    output comma_detected
    );
    
    wire [1:0] RUDI;
    wire [15:0] tx_Config_Reg;
    wire [15:0] rx_Config_Reg;
    wire [1:0] xmit;
    wire receiving;
    wire transmitting;
//    wire rd;
    
    new_top tx (
        .clk(clk_tx),
        .reset(reset),
        .TX_EN(TX_EN),
        .TX_ER(TX_ER),
        .tx_Config_Reg(tx_Config_Reg),
        .TXD(TXD),
//        .comma_detected(comma_detected),
        .xmit(xmit),
        .COL(COL),
        .enc10b_exit(tx_code_group),
        .transmitting(transmitting)
    );
    
    rx_top rx (
        .clk(clk_rx),
        .reset(reset),
        .signal_detect(signal_detect),
        .PUDI(rx_code_group),
//        .rd(rd),
        .xmit(xmit),
        .rx_Config_Reg(rx_Config_Reg),
        .receiving(receiving),
        .RX_DV(RX_DV),
        .RX_ER(RX_ER),
        .RXD(RXD),
        .RUDI(RUDI)
    );
    
    an auto_neg(
        .clk(clk_rx),
        .RUDI(RUDI),
        .reset(reset),
        .mr_adv_ability(mr_adv_ability),
        .mr_an_enable(mr_an_enable),
        .rx_Config_Reg(rx_Config_Reg),
        .mr_page_rx(mr_page_rx),
        .mr_an_complete(mr_an_complete),
        .mr_np_loaded(mr_np_loaded),
        .tx_Config_Reg(tx_Config_Reg),
        .xmit(xmit),
        .toggle_tx(toggle_tx),
        .toggle_rx(toggle_rx),
        .np_rx(np_rx),
        .resolve_priority(resolve_priority)
    );
    
    cs car_sen(
        .clk(clk_rx),
        .reset(reset),
        .repeater_mode(repeater_mode),
        .transmitting(transmitting),
        .receiving(receiving),
        .CRS(CRS)
    );
    
endmodule
