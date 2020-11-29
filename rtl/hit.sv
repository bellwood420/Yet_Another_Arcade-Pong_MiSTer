/*
 * Hit detection
 */
module hit(
  input   logic   HVID_N, VVID_N,
  input   logic   PAD1, PAD2,
  output  logic   HIT, HIT_N, HIT1_N, HIT2_N
);
  logic G1b, G3a, G3d, B2c, B2d;
  assign G1b = ~(HVID_N | VVID_N);
  assign G3a = ~(G1b & PAD2);
  assign G3d = ~(G1b & PAD1);
  assign B2c = ~(G3a & G3d);
  assign B2d = ~(B2c & B2c);

  assign HIT = B2c;
  assign HIT_N = B2d;
  assign HIT1_N = G3d;
  assign HIT2_N = G3a;

endmodule
