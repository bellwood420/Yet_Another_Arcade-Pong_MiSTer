/*
 * Horizontal Ball Counter
 */
module hball(
  input   logic   CLK, CLK_DRV,
  input   logic   HIT_SOUND,
  input   logic   RST_SPEED,
  input   logic   _256H_N,
  input   logic   VRESET,
  input   logic   HIT1_N, HIT2_N,
  input   logic   SC,
  input   logic   HBLANK_N,
  input   logic   ATTRACT, ATTRACT_N,
  input   logic   SERVE,
  output  logic   L, R,
  output  logic   HVID_N
);
  //
  // Horizontal ball speed control
  //
  logic E1d, E1c, G1d, H1a, H1d, H1c, H1b, G1c, H4a, MOVE;
  logic F1_QA, F1_QC, F1_QD, H2b_Q, H2a_Q;

  assign E1d = ~(E1c & HIT_SOUND);
  assign E1c = ~(F1_QC & F1_QD);
  assign G1d = ~(F1_QC | F1_QD);
  assign H1a = ~G1d;
  assign H1d = ~(E1c & H1a);
  assign H1c = ~(VRESET & H1d);
  assign H1b = ~(VRESET & H1a);
  assign G1c = ~(_256H_N | VRESET);
  assign H4a = ~(H2b_Q & H2a_Q);
  assign MOVE = H4a;

  // break combinational loop
  logic E1d_q;
  always_ff @(posedge CLK_DRV) begin
    E1d_q <= E1d;
  end

  SN7493 SN7493_F1(
    .CLK_DRV,
    .CKA_N(E1d_q), .CKB_N(F1_QA),
    .R0(RST_SPEED), .R1(RST_SPEED),
    .QA(F1_QA), .QB(), .QC(F1_QC), .QD(F1_QD)
  );

  SN74107 SN74107_H2b(
    .CLK_DRV,
    .CLK_N(G1c), .CLR_N(H1c),
    .J(1'b1), .K(H4a), .Q(H2b_Q), .Q_N()
  );

  SN74107 SN74107_H2a(
    .CLK_DRV,
    .CLK_N(G1c), .CLR_N(H1b),
    .J(H2b_Q), .K(1'b0), .Q(H2a_Q), .Q_N()
  );

  //
  // Counter load value generation
  //
  logic C1d, D1a, H4d, H4b, H4c;
  logic H3b_Q, H3b_Q_N;
  logic Ba, Aa;

  assign C1d = ~(SC & ATTRACT);
  assign D1a = ~C1d;
  assign H4d = ~(H3b_Q & MOVE);
  assign H4b = ~(H3b_Q_N & MOVE);
  assign H4c = ~(H4d & H4b);
  assign Ba = H4b;
  assign Aa = H4c;
  assign L = H3b_Q;
  assign R = H3b_Q_N;

  SN7474 SN7474_H3b(
    .CLK_DRV,
    .CLK(D1a), .PRE_N(HIT2_N), .CLR_N(HIT1_N),
    .D(H3b_Q_N),
    .Q(H3b_Q), .Q_N(H3b_Q_N)
  );

  //
  // Horizontal counter
  //
  logic E1b, G5c, H6b;
  logic G7_QC, G7_QD;
  logic G7_RCO, H7_RCO, G6b_Q;

  assign E1b = ~(ATTRACT_N & SERVE);
  assign G5c = ~(G7_RCO & H7_RCO & G6b_Q);
  assign H6b = ~(G7_QC & G7_QD & H7_RCO & G6b_Q);
  assign HVID_N = H6b;

  DM9316 DM9316_G7(
    .CLK_DRV,
    .CLK, .CLR_N(E1b), .LOAD_N(G5c), .ENP(1'b1), .ENT(HBLANK_N),
    .A(Aa), .B(Ba), .C(1'b0), .D(1'b1),
    .QA(), .QB(), .QC(G7_QC), .QD(G7_QD),
    .RCO(G7_RCO)
  );

  DM9316 DM9316_H7(
    .CLK_DRV,
    .CLK, .CLR_N(E1b), .LOAD_N(G5c), .ENP(G7_RCO), .ENT(1'b1),
    .A(1'b0), .B(1'b0), .C(1'b0), .D(1'b1),
    .QA(), .QB(), .QC(), .QD(),
    .RCO(H7_RCO)
  );

  SN74107 SN74107_G6b(
    .CLK_DRV,
    .CLK_N(H7_RCO), .CLR_N(E1b),
    .J(1'b1), .K(1'b1), .Q(G6b_Q), .Q_N()
  );

endmodule