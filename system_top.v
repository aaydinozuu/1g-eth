`timescale 1ns / 1ps

module system_top (
  // MGT pins
  input  wire gtrefclk_p, gtrefclk_n,
  input  wire gtyrxp_in,  input  wire gtyrxn_in,
  output wire gtytxp_out, output wire gtytxn_out,

  // Board freerun clock & pushbutton reset
  input  wire clk_freerun,    // e.g., fabric clock
  input  wire rst_button,

  // PCS-side user ports (to/from MAC or testbench)
  input  wire        TX_EN,
  input  wire        TX_ER,
  input  wire [7:0]  TXD,
  output wire [7:0]  RXD,
  output wire        RX_DV,
  output wire        RX_ER,
  input  wire        mr_an_enable,
  input  wire [16:1] mr_adv_ability,
  input  wire        repeater_mode,
  output wire        CRS, COL,
  output wire        mr_page_rx, mr_an_complete, mr_np_loaded,
  output wire        toggle_tx, toggle_rx, np_rx, resolve_priority
);

  // ===== Refclk into MGT =====
  wire gtrefclk0_int;
  IBUFDS_GTE4 u_ibufds_gte4 (
    .I   (gtrefclk_p),
    .IB  (gtrefclk_n),
    .CEB (1'b0),
    .O   (gtrefclk0_int),
    .ODIV2()
  );
  wire rxslide_in;
  // ===== Freerun clock for reset/DRP =====
  wire clk_freerun_buf;
  BUFG u_bufg0 (.I(clk_freerun), .O(clk_freerun_buf));
  wire drpclk_buf = clk_freerun_buf;

  // ===== Reset helper =====
  wire reset_all = rst_button;

  // ===== GT Wizard wrapper (only always-present ports) =====
  wire        txusrclk2, rxusrclk2;
  (* mark_debug = "true" *) wire [19:0] tx20, rx20;
  wire        gtpowergood, txpmaresetdone, rxpmaresetdone;
  
//  (*mark_debug = "true"*) wire comma_detected;
  wire [2:0] loopback_in;
  assign loopback_in = 3'b010;
  
  wire rxslide;
//  wire rxbyteisaligned_out;
//  wire rxcommadeten_in;
     
  giga_eth gtwiz_inst (
    .gtrefclk0_in                 (gtrefclk0_int),
    .drpclk_in                    (drpclk_buf),
    .gtwiz_reset_clk_freerun_in   (clk_freerun_buf),
    .gtwiz_reset_all_in           (reset_all),

    .gtwiz_userclk_tx_usrclk2_out (txusrclk2),
    .gtwiz_userclk_rx_usrclk2_out (rxusrclk2),

    .gtwiz_userdata_tx_in         (tx20),
    .gtwiz_userdata_rx_out        (rx20),
    
    .gtpowergood_out              (gtpowergood),
    .txpmaresetdone_out           (txpmaresetdone),
    .rxpmaresetdone_out           (rxpmaresetdone),
    
//    .rxcommadeten_in              (rxcommadeten_in),
//    .rxbyteisaligned_out          (rxbyteisaligned_out),
    .rxslide_in                   (rxslide),
    .gtytxn_out                   (gtytxn_out),
    .gtytxp_out                   (gtytxp_out),
    .gtyrxn_in                    (gtyrxn_in),
    .gtyrxp_in                    (gtyrxp_in),
    
    .loopback_in                  (loopback_in)
  );



  // ===== 10b <-> 20b gearbox =====
  wire [9:0] tx_code_group;
  tx_pack_10b_to_20b u_txpack (
    .clk        (txusrclk2),
    .rst        (~txpmaresetdone),
    .tenb       (tx_code_group),
    .tenb_valid (1'b1),
    .twenb      (tx20),
    .twenb_valid()
  );
  
 
  wire [9:0] rx_code_group;
  rxslide slide (
    .clk               (rxusrclk2),
    .rst               (~rxpmaresetdone),
    .rwenb             (rx20),
    .renb              (rx_code_group),
    .rxslide           (rxslide)
  );

  // ===== PCS block =====
  wire signal_detect = 1'b1;  // for sim; in real hw drive from PMD
  pcs u_pcs (
    .clk_rx        (rxusrclk2), // NOTE: if you want true split domains, refactor PCS
    .clk_tx        (txusrclk2), // NOTE: if you want true split domains, refactor PCS
    .reset         (~(txpmaresetdone & rxpmaresetdone)),
    .mr_adv_ability(mr_adv_ability),
    .mr_an_enable  (mr_an_enable),
    .TXD           (TXD),
    .TX_EN         (TX_EN),
    .TX_ER         (TX_ER),
    .rx_code_group (rx_code_group),
    .signal_detect (signal_detect),
    .repeater_mode (repeater_mode),
    .COL           (COL),
    .CRS           (CRS),
    .RXD           (RXD),
    .RX_DV         (RX_DV),
    .RX_ER         (RX_ER),
    .tx_code_group (tx_code_group),
    .mr_page_rx    (mr_page_rx),
    .mr_an_complete(mr_an_complete),
    .mr_np_loaded  (mr_np_loaded),
    .toggle_tx     (toggle_tx),
    .toggle_rx     (toggle_rx),
    .np_rx         (np_rx),
    .resolve_priority(resolve_priority)
//    .comma_detected(comma_detected)
  );

endmodule
