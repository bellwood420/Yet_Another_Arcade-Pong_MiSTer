/*
 * PONG top module
 */
module pongtop(
  input   logic   CLK_DRV, CLK,
  input   logic   FPGA_RESET,
  input   logic   COIN_SW,
  input   logic   SW1A, SW1B,
  output  logic   PAD_TRG_N,
  input   logic   PAD1_OUT, PAD2_OUT,
  output  logic   HBLANK, VBLANK, HSYNC, VSYNC,
  output  logic   VIDEO, SCORE,
  output  logic   SOUND
);
  logic CSYNC; // Unused in MiSTer

  logic _1H, _2H, _4H, _8H, _16H, _32H, _64H, _128H, _256H, _256H_N;
  logic HRESET, HRESET_N, HBLANK_N, HSYNC_N;

  logic _1V, _2V, _4V, _8V, _16V, _32V, _64V, _128V, _256V, _256V_N;
  logic VRESET, VRESET_N, VBLANK_N, VSYNC_N;

  logic NET, PAD1, PAD2;
  logic HVID_N, VVID_N, VVID;

  logic L, R;
  logic B1, C1, D1, B2, C2, D2;
  logic VPOS16, VPOS32, VPOS256;

  logic SRST, SRST_N, STOP_G, SERVE, SERVE_N, RST_SPEED, MISS_N;
  logic HIT_SOUND, SC;
  logic HIT1_N, HIT2_N, HIT, HIT_N;
  logic ATTRACT, ATTRACT_N;

  hcounter hcounter(.*);
  vcounter vcounter(.CLK(HRESET), .*);
  sync sync(.*);
  videosum videosum(.*);
  net net(.*);
  pad pad(.*);
  score score(.*);
  hball hball(.*);
  vball vball(.*);
  sound sound(.*);
  hit hit(.*);
  gamecntl gamecntl(.*);

  assign PAD_TRG_N = _256V_N;
  assign HSYNC = ~HSYNC_N;
  assign VSYNC = ~VSYNC_N;

endmodule
