/*
 * Game Control
 */
module gamecntl(
  input   logic   CLK_DRV,
  input   logic   FPGA_RESET,
  input   logic   COIN_SW,
  input   logic   MISS_N,
  input   logic   STOP_G,
  input   logic   PAD1,
  output  logic   SRST, SRST_N,
  output  logic   RST_SPEED,
  output  logic   SERVE, SERVE_N,
  output  logic   ATTRACT, ATTRACT_N
);
  assign SRST = COIN_SW;
  assign SRST_N = ~SRST;

  logic Q1_C;

  always_ff @(posedge CLK_DRV, posedge FPGA_RESET) begin
    if (FPGA_RESET)
      Q1_C <= 1'b1;
    else if (STOP_G)
      Q1_C <= 1'b1;
    else if (SRST)
      Q1_C <= 1'b0;
  end

  logic E6b, E6a, F4_OUT;
  assign E6b = ~(SRST_N & MISS_N);
  assign E6a = ~E6b;
  assign RST_SPEED = E6b;

  oneshot_555 #(
    .COUNTS(24428694) // 1.7s
  ) oneshot_555 (
    .CLK(CLK_DRV),
    .TRG_N(E6a),
    .OUT(F4_OUT)
  );

  logic D2a, E5a, D1b;
  assign D2a = ~(STOP_G | Q1_C);
  assign E5a = ~(STOP_G | Q1_C | F4_OUT);
  assign D1b = ~D2a;

  assign ATTRACT = D1b;
  assign ATTRACT_N = D2a;

  SN7474 SN7474_B5b(
    .CLK_DRV,
    .CLK(PAD1), .PRE_N(1'b1), .CLR_N(E5a),
    .D(E5a),
    .Q(SERVE_N), .Q_N(SERVE)
  );

endmodule
