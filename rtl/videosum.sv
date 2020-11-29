/*
 * Video signal sum
 */
module videosum(
  input   logic   HSYNC_N, VSYNC_N,
  input   logic   HVID_N, VVID_N,
  input   logic   HBLANK_N, VBLANK_N,
  input   logic   NET, PAD1, PAD2,
  output  logic   CSYNC, VIDEO
);
  logic A4d;
  assign A4d = HSYNC_N ^ VSYNC_N;
  assign CSYNC = ~A4d;

  logic G1b, F2b, E4e;
  assign G1b = ~(HVID_N | VVID_N); // Ball
  assign F2b = ~(G1b | NET | PAD1 | PAD2);
  assign E4e = ~F2b;

  // Masking VIDEO signal while in blanking
  // to prevent flikering noise on screen.
  // This feature is not present in original ciruit.
  assign VIDEO = E4e & HBLANK_N & VBLANK_N;

endmodule
