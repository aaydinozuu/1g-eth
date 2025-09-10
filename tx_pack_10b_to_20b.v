`timescale 1ns / 1ps

module tx_pack_10b_to_20b #(
  parameter RESET_TO_KNOWN = 1  // 1: clear internal state on reset
)(
  input  wire        clk,            // TXUSRCLK2 domain
  input  wire        rst,            // sync reset, active high
  input  wire [9:0]  tenb,           // incoming 10b code group (every clock)
  input  wire        tenb_valid,     // 1 if 'tenb' is valid this cycle (tie 1'b1 if always valid)
  output reg  [19:0] twenb,          // packed 20b output: {first_10b, second_10b}
  output reg         twenb_valid     // pulses high when 'twenb' is newly formed
);

  reg        have_first;     // indicates we latched first 10b and are waiting for the second one
  reg [9:0] first_10b;

  always @(posedge clk) begin
    if (rst) begin
      have_first   <= 1'b0;
      first_10b    <= 10'd0;
      twenb        <= 20'd0;
      twenb_valid  <= 1'b0;
    end else begin
      twenb_valid <= 1'b0;   // default: no new 20b this cycle

      if (tenb_valid) begin
        if (!have_first) begin
          // Capture the first 10b; wait for the next valid 10b to complete a 20b word.
          first_10b  <= tenb;
          have_first <= 1'b1;
        end else begin
          // Second 10b arrived → produce a 20b word.
          twenb       <= {first_10b, tenb};
          twenb_valid <= 1'b1;
          have_first  <= 1'b0;  // ready for the next pair
        end
      end
    end
  end

endmodule
