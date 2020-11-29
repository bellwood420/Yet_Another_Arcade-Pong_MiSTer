/*
 * Vertical Ball Counter
 */
module vball(
  input   logic   CLK_DRV,
  input   logic   HIT, HIT_N,
  input   logic   _256H, _256H_N, HSYNC_N, VBLANK, VBLANK_N,
  input   logic   B1, C1, D1, B2, C2, D2,
  input   logic   ATTRACT,
  output  logic   VVID, VVID_N,
  output  logic   VPOS16, VPOS32, VPOS256
);

//
// Vertical ball speed control
//
logic A5b_Q, A5a_Q, B5a_Q, B5a_Q_N, A2a_Q, A2a_Q_N;
logic D1c, A6a, A6b, B6b;

assign D1c = ~ATTRACT;
assign A6a = ~((B1 & _256H_N) | (B2 & _256H));
assign A6b = ~((C1 & _256H_N) | (C2 & _256H));
assign B6b = ~((D1 & _256H_N) | (D2 & _256H));

SN7474 SN7474_A5b(
  .CLK_DRV,
  .CLK(HIT), .PRE_N(1'b1), .CLR_N(D1c),
  .D(A6a),
  .Q(A5b_Q), .Q_N()
);

SN7474 SN7474_A5a(
  .CLK_DRV,
  .CLK(HIT), .PRE_N(1'b1), .CLR_N(D1c),
  .D(A6b),
  .Q(A5a_Q), .Q_N()
);

SN7474 SN7474_B5a(
  .CLK_DRV,
  .CLK(HIT), .PRE_N(1'b1), .CLR_N(D1c),
  .D(B6b),
  .Q(B5a_Q), .Q_N(B5a_Q_N)
);

SN74107 SN74107_A2a(
  .CLK_DRV,
  .CLK_N(VBLANK), .CLR_N(HIT_N),
  .J(VVID), .K(VVID), .Q(A2a_Q), .Q_N(A2a_Q_N)
);

logic A4c, A4b, B6a, C4a;
logic Ab, Bb, Cb, Db;

assign A4c = A5b_Q ^ A2a_Q;
assign A4b = A5a_Q ^ A2a_Q;
assign B6a = ~((B5a_Q & A2a_Q) | (B5a_Q_N & A2a_Q_N));
assign C4a = ~B6a;

SN7483 SN7483_B4(
  .A1(A4c), .A2(A4b), .A3(B6a), .A4(1'b0),
  .B1(C4a), .B2(1'b1), .B3(1'b1), .B4(1'b0),
  .S1(Ab), .S2(Bb), .S3(Cb), .S4(Db),
  .C0(1'b0), .C4()
);

//
// Vertical ball counter
//
logic B3_RCO, B3_QC, B3_QD, A3_RCO;
logic B2b, E2b, D2d;

assign B2b = ~(B3_RCO & A3_RCO);
assign E2b = ~(B3_QC & B3_QD & A3_RCO);
assign D2d = ~E2b;
assign VPOS256 = A3_RCO;
assign VVID_N = E2b;
assign VVID = D2d;

DM9316 DM9316_B3(
  .CLK_DRV,
  .CLK(HSYNC_N), .CLR_N(1'b1), .LOAD_N(B2b), .ENP(1'b1), .ENT(VBLANK_N),
  .A(Ab), .B(Bb), .C(Cb), .D(Db),
  .QA(), .QB(), .QC(B3_QC), .QD(B3_QD),
  .RCO(B3_RCO)
);

DM9316 DM9316_A3(
  .CLK_DRV,
  .CLK(HSYNC_N), .CLR_N(1'b1), .LOAD_N(B2b), .ENP(B3_RCO), .ENT(1'b1),
  .A(1'b0), .B(1'b0), .C(1'b0), .D(1'b0),
  .QA(VPOS16), .QB(VPOS32), .QC(), .QD(),
  .RCO(A3_RCO)
);

endmodule
