`timescale 1ns / 1ps

module rx_unpack_20b_to_10b #(
  parameter LOCK_ON_RISING = 1  // 1: lock phase when align_event rises
)(
  input  wire        clk,            // RXUSRCLK2 domain
  input  wire        rst,            // sync reset, active high
//  input  wire        tx20,
  // 20b input from the transceiver user data bus
  input  wire [19:0] rwenb,          // {upper_10b, lower_10b}
  input  wire        rwenb_valid,    // pulses when 'rwenb' is a fresh word (tie 1'b1 if stream-based)

  // Alignment/phase control (optional but recommended)
  // Provide a one-cycle pulse on 'align_event' when RX has achieved byte alignment on a comma (e.g., rxbyteisaligned & rxcommadet rising).
  input  wire        align_event,    // 1-cycle pulse to lock the phase (can be derived from rxbyteisaligned/rxcommadet)
  input  wire        prefer_upper_first, // 1: output [19:10] first; 0: output [9:0] first (used when align_event occurs)
  
//  input  wire        comma_detected,

  // 10b output stream
  output reg  [9:0]  renb,           // unpacked 10b code group
  output reg         renb_valid      // pulses high when 'renb' is valid
);

  // 'phase' decides which half of the 20b goes out on the next cycle.
  // phase = 0 → output rwenb[19:10] first, then rwenb[9:0]
  // phase = 1 → output rwenb[9:0]  first, then rwenb[19:10]
  reg phase;
  wire [19:0] rwenb_sl;
  assign rwenb_sl = {rwenb[18:0], rwenb[19]};  
//  assign rwenb_sl = (tx20 == rwenb) ? rwenb : {rwenb[18:0], rwenb[19]};

  // Simple edge detector for align_event (optional; you can feed a clean pulse directly)
  reg align_event_d;
  wire align_event_rise = align_event & ~align_event_d;
  

  always @(posedge clk) begin
    if (rst) begin
      phase          <= 1'b0;
      align_event_d  <= 1'b0;
      renb           <= 10'd0;
      renb_valid     <= 1'b0;
    end else begin
      align_event_d <= align_event;

      // Optional phase lock: when an alignment event happens, pick the preferred starting half
      if (LOCK_ON_RISING ? align_event_rise : align_event) begin
        phase <= prefer_upper_first ? 1'b0 : 1'b1;
      end

      renb_valid <= 1'b0; // default each cycle

      if (rwenb_valid) begin
        // On each valid 20b, emit one 10b per clock, alternating halves based on 'phase'
        if (phase == 1'b0) begin
          // First emit upper half, then flip phase
          renb       <= rwenb_sl[19:10];
          renb_valid <= 1'b1;
          phase      <= 1'b1;
        end else begin
          // Then emit lower half, and flip phase back
          renb       <= rwenb_sl[9:0];
          renb_valid <= 1'b1;
          phase      <= 1'b0;
        end
      end
    end
  end

endmodule
