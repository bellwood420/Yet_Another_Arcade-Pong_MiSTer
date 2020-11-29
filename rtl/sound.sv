/*
 * Sound
 */
module sound(
  input   logic   CLK_DRV,
  input   logic   ATTRACT_N, SERVE_N, HIT_N, MISS_N,
  input   logic   _32V, VBLANK,
  input   logic   VVID, VVID_N,
  input   logic   VPOS16, VPOS32, VPOS256,
  output  logic   SOUND, HIT_SOUND, SC
);
  //
  // Top hit sound
  //
  logic F3a_Q, C3b;
  assign C3b = ~(VPOS32 & F3a_Q);

  SN74107 SN74107_F3a(
    .CLK_DRV,
    .CLK_N(VBLANK), .CLR_N(SERVE_N),
    .J(VVID), .K(VVID_N), .Q(F3a_Q), .Q_N()
  );

  //
  // Paddle hit sound
  //
  logic C3a;
  assign C3a = ~(HIT_SOUND & VPOS16);

  SN7474 SN7474_C2a(
    .CLK_DRV,
    .CLK(VPOS256), .PRE_N(1'b1), .CLR_N(HIT_N),
    .D(1'b1),
    .Q(), .Q_N(HIT_SOUND)
  );

  //
  // Score sound
  //
  logic C3c;
  assign C3c = ~(_32V & SC);

  oneshot_555 #(
    .COUNTS(3465063) // 0.242s
  ) ONESHOT_555 (
    .CLK(CLK_DRV),
    .TRG_N(MISS_N),
    .OUT(SC)
  );

  //
  // Sound mix
  //
  logic C4b, C1b;
  assign C4b = ~(C3b & C3a & C3c);
  assign C1b = ~(ATTRACT_N & C4b);
  assign SOUND = C1b;

endmodule
