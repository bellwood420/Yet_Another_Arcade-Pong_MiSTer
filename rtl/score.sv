/*
 * Score Count and Display
 */
module score(
  input   logic   CLK_DRV,
  input   logic   HVID_N, HBLANK, ATTRACT_N, L, R, SRST, SRST_N,
  input   logic   _4H, _8H, _16H, _32H, _64H, _128H, _256H,
  input   logic   _4V, _8V, _16V, _32V, _64V, _128V,
  input   logic   SW1A, SW1B,
  output  logic   MISS_N, STOP_G,
  output  logic   SCORE
);
  //
  // Score count signal
  //
  logic H6a, E6c, D1f, E1a, MISSED_N;
  assign H6a = ~HVID_N;
  assign E6c = ~(H6a & HBLANK);
  assign MISS_N = E6c;
  assign D1f = ~E6c;
  assign E1a = ~(D1f & ATTRACT_N);
  assign MISSED_N = E1a;

  logic F5b, F5a;
  assign F5b = ~(L | MISSED_N);
  assign F5a = ~(R | MISSED_N);

  //
  // Score counter (player 1)
  //
  logic S1A, S1B, S1C, S1D, S1E, S1E_N;

  SN7490 SN7490_C7(
    .CLK_DRV,
    .CKA_N(F5b), .CKB_N(S1A),
    .R01(SRST), .R02(SRST),
    .R91(1'b0), .R92(1'b0),
    .QA(S1A), .QB(S1B), .QC(S1C), .QD(S1D));

  SN74107 SN74107_C8a(
    .CLK_DRV,
    .CLK_N(S1D),
    .CLR_N(SRST_N),
    .J(1'b1), .K(1'b1),
    .Q(S1E), .Q_N(S1E_N));

  //
  // Score counter (player 2)
  //
  logic S2A, S2B, S2C, S2D, S2E, S2E_N;

  SN7490 SN7490_D7(
    .CLK_DRV,
    .CKA_N(F5a), .CKB_N(S2A),
    .R01(SRST), .R02(SRST),
    .R91(1'b0), .R92(1'b0),
    .QA(S2A), .QB(S2B), .QC(S2C), .QD(S2D));

  SN74107 SN74107_C8b(
    .CLK_DRV,
    .CLK_N(S2D),
    .CLR_N(SRST_N),
    .J(1'b1), .K(1'b1),
    .Q(S2E), .Q_N(S2E_N));

  //
  // Score count selector
  //
  logic A, B, C, D;

  SN74153 SN74153_C6(
    .A(_32H), .B(_64H),
    ._1G_N(1'b0), ._2G_N(1'b0),
    ._1C0(1'b1), ._1C1(S1A), ._1C2(1'b1), ._1C3(S2A),
    ._2C0(S1E_N), ._2C1(S1B), ._2C2(S2E_N), ._2C3(S2B),
    ._1Y(A), ._2Y(B));

  SN74153 SN74153_D6(
    .A(_32H), .B(_64H),
    ._1G_N(1'b0), ._2G_N(1'b0),
    ._1C0(S1E_N), ._1C1(S1C), ._1C2(S2E_N), ._1C3(S2C),
    ._2C0(S1E_N), ._2C1(S1D), ._2C2(S2E_N), ._2C3(S2D),
    ._1Y(C), ._2Y(D));

  //
  // 7-seg display enable signal
  //
  logic E3a, E3b, E2c, E3c, D2c, G1a, F2a;
  assign E3a = ~_128H;
  assign E3b = ~(_256H | _64H | E3a);
  assign E2c = ~(_256H & _64H & E3a);
  assign E3c = ~E2c;
  assign D2c = ~(E3b | E3c);
  assign G1a = ~_32V;
  assign F2a = ~(G1a | _64V | _128V | D2c); // 7-seg display enable negative

  //
  // 7-seg decoder
  //
  logic a, b, c, d, e, f, g;
  wire logic BI_RBO_N;
  assign BI_RBO_N = F2a;
  SN7448 SN7448_C5 (
    .BI_RBO_N,
    .RBI_N(1'b1), .LT_N(1'b1),
    .A, .B, .C, .D,
    .a, .b, .c, .d, .e, .f, .g
  );

  //
  // Score signal selector
  //
  logic E4b, E5c, C3d, D2b, E5b, E2a, E4a, E4c;
  logic scoreFE, scoreBC, scoreA, scoreGD;
  logic D4a, D5c, C4c, D5a, D4c, D4b, D5b;

  assign E4b = ~_16H;
  assign E5c = ~(E4b | _4H | _8H);
  assign C3d = ~(_4H & _8H);
  assign D2b = ~(E4b | C3d);
  assign E5b = ~(E4b | _4V | _8V);
  assign E2a = ~(_16H & _4V & _8V);
  assign E4a = ~E2a;
  assign E4c = ~_16V;

  assign scoreFE = E5c;
  assign scoreBC = D2b;
  assign scoreA  = E5b;
  assign scoreGD = E4a;

  assign D4a = ~(scoreFE &  E4c & f);
  assign D5c = ~(scoreFE & _16V & e);
  assign C4c = ~(scoreBC &  E4c & b);
  assign D5a = ~(scoreBC & _16V & c);
  assign D4c = ~(scoreA  &  E4c & a);
  assign D4b = ~(scoreGD &  E4c & g);
  assign D5b = ~(scoreGD & _16V & d);

  assign SCORE = ~(D4a & D5c & C4c & D5a & D4c & D4b & D5b);

  //
  // Game end signal
  //
  logic SW1AO, SW1BO;
  logic D8a, D8b, B2a;
  logic STOPG1_N, STOPG2_N, STOP_G_q;

  assign SW1AO = SW1A ? S1C : 1'b1;
  assign SW1BO = SW1B ? S2C : 1'b1;

  assign D8a = ~(S1A & SW1AO & S1E);
  assign D8b = ~(S2A & SW1BO & S2E);
  assign B2a = ~(D8a & D8b);

  assign STOP_G_q = B2a;

  // break combinational loop
  always_ff @(posedge CLK_DRV) begin
    STOP_G <= STOP_G_q;
  end

endmodule
