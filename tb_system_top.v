`timescale 1ps/1ps

module tb_system_top;

  // -----------------------------
  // Fixed periods (ps) for Verilog delays
  // -----------------------------
  localparam integer REFCLK_PERIOD_PS  = 6400;   // 6.4 ns @ 156.25 MHz
  localparam integer FREECLK_PERIOD_PS = 16000;  // 16 ns @ 62.5 MHz
  localparam integer PAYLOAD_LEN       = 64;
  localparam integer IDLE_CYCLES_BEFORE = 4000; // let GT align/settle
  localparam time   TIMEOUT_PS         = 5_000_000_000; // 5 ms

  // -----------------------------
  // DUT I/Os
  // -----------------------------
  reg  gtrefclk_p, gtrefclk_n;
  wire gtytxp_out, gtytxn_out;
  wire gtyrxp_in_w, gtyrxn_in_w;   // looped-back serial

  reg  clk_freerun;
  reg  rst_button;

  reg        TX_EN;
  reg        TX_ER;
  reg [7:0]  TXD;
  wire [7:0] RXD;
  wire       RX_DV;
  wire       RX_ER;

  reg        mr_an_enable;
  reg [16:1] mr_adv_ability;
  reg        repeater_mode;
  wire       CRS, COL;
  wire       mr_page_rx, mr_an_complete, mr_np_loaded;
  wire       toggle_tx, toggle_rx, np_rx, resolve_priority;

  // -----------------------------
  // Serial loopback wiring (TB-level)
  // -----------------------------
  assign gtyrxp_in_w = gtytxp_out;
  assign gtyrxn_in_w = gtytxn_out;

  // -----------------------------
  // Instantiate DUT
  // -----------------------------
  system_top dut (
    .gtrefclk_p(gtrefclk_p),
    .gtrefclk_n(gtrefclk_n),
    .gtyrxp_in (gtyrxp_in_w),
    .gtyrxn_in (gtyrxn_in_w),
    .gtytxp_out(gtytxp_out),
    .gtytxn_out(gtytxn_out),

    .clk_freerun(clk_freerun),
    .rst_button (rst_button),

    .TX_EN(TX_EN),
    .TX_ER(TX_ER),
    .TXD  (TXD),
    .RXD  (RXD),
    .RX_DV(RX_DV),
    .RX_ER(RX_ER),

    .mr_an_enable  (mr_an_enable),
    .mr_adv_ability(mr_adv_ability),
    .repeater_mode (repeater_mode),
    .CRS(CRS), .COL(COL),

    .mr_page_rx(mr_page_rx),
    .mr_an_complete(mr_an_complete),
    .mr_np_loaded(mr_np_loaded),
    .toggle_tx(toggle_tx),
    .toggle_rx(toggle_rx),
    .np_rx(np_rx),
    .resolve_priority(resolve_priority)
  );

//    initial begin
//        #(60_000_000) TX_EN = 1'b1;
//    end

  // -----------------------------
  // Clocks
  // -----------------------------
  initial begin
    gtrefclk_p = 1'b0;
    forever #(REFCLK_PERIOD_PS/2) gtrefclk_p = ~gtrefclk_p;
  end

  // complement of p
  always @(*) gtrefclk_n = ~gtrefclk_p;

  initial begin
    clk_freerun = 1'b0;
    forever #(FREECLK_PERIOD_PS/2) clk_freerun = ~clk_freerun;
  end

  // -----------------------------
  // Reset & defaults
  // -----------------------------
  initial begin
    rst_button     = 1'b1;
    TX_EN          = 1'b0;
    TX_ER          = 1'b0;
    TXD            = 8'h00;

    mr_an_enable   = 1'b0;
    mr_adv_ability = 16'h0000;
    repeater_mode  = 1'b0;

    // hold reset for a while then release
    repeat (300) @(posedge clk_freerun);
    rst_button = 1'b0;
    
  end

  // -----------------------------
  // Timeout guard
  // -----------------------------
  initial begin
    #(TIMEOUT_PS);
    $fatal(1, "[TB] Timeout at %0t ps. Check clocks/refclk or serializers.", $time);
  end

  // (scoreboard, helpers, scenario kısımlarını aynen bırakabilirsin)
endmodule
