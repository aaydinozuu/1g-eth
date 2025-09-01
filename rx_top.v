`timescale 1ns / 1ps

module rx_top(
    input clk,
    input reset,
    input signal_detect,
    input [9:0] PUDI,
//    input rd,
    input [1:0] xmit,
    output [15:0] rx_Config_Reg,
    output receiving, 
    output RX_DV,
    output RX_ER,
    output [7:0] RXD,
    output [1:0] RUDI
    );
    
    wire [7:0] data_8b;
    wire carrier_detect, control, code_sync_status, rx_even;
    
    sync SYNC(
        .clk(clk),
        .reset(reset),
        .signal_detect(signal_detect),
        .PUDI(PUDI),
//        .rd(rd),
        .data_8b(data_8b),
        .carrier_detect(carrier_detect),
        .control(control),
        .code_sync_status(code_sync_status),
        .rx_even(rx_even)
    );
    
    
    rx RX(
        .clk(clk),
        .reset(reset),
        .EVEN(rx_even),
        .carrier_detect(carrier_detect),
        .sync_status(code_sync_status),
        .xmit(xmit),
        .control(control),
        .data_in(data_8b),
        .rx_Config_Reg(rx_Config_Reg),
        .receiving(receiving),
        .RX_DV(RX_DV),
        .RX_ER(RX_ER),
        .RXD(RXD),
        .RUDI(RUDI)       
    );
    
    
endmodule
