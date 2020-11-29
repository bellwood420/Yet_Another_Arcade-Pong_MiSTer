/*
 * Horizontal counter
 */
module hcounter(
  input   logic   CLK_DRV, CLK,
  output  logic   _1H, _2H, _4H, _8H, _16H, _32H, _64H, _128H, _256H, _256H_N,
  output  logic   HRESET, HRESET_N
);
  SN7493 SN7493_F8(.CLK_DRV,
                   .CKA_N(CLK), .CKB_N(_1H),
                   .R0(HRESET), .R1(HRESET),
                   .QA(_1H), .QB(_2H), .QC(_4H), .QD(_8H));

  SN7493 SN7493_F9(.CLK_DRV,
                   .CKA_N(_8H), .CKB_N(_16H),
                   .R0(HRESET), .R1(HRESET),
                   .QA(_16H), .QB(_32H), .QC(_64H), .QD(_128H));

  SN74107 SN74107_F6b(.CLK_DRV,
                      .CLK_N(_128H), .CLR_N(HRESET_N),
                      .J(1'b1), .K(1'b1),
                      .Q(_256H), .Q_N(_256H_N));

  logic F7;
  assign F7 = ~(_2H & _4H & _64H & _128H & _256H);

  SN7474 SN7474_E7b(.CLK_DRV,
                    .CLK(CLK),
                    .PRE_N(1'b1), .CLR_N(1'b1),
                    .D(F7),
                    .Q(HRESET_N), .Q_N(HRESET));
endmodule
