/*
 * Vertical counter
 */
module vcounter(
  input   logic   CLK_DRV, CLK,
  output  logic   _1V, _2V, _4V, _8V, _16V, _32V, _64V, _128V, _256V, _256V_N,
  output  logic   VRESET, VRESET_N
);
  SN7493 SN7493_E8(.CLK_DRV,
                   .CKA_N(CLK), .CKB_N(_1V),
                   .R0(VRESET), .R1(VRESET),
                   .QA(_1V), .QB(_2V), .QC(_4V), .QD(_8V));

  SN7493 SN7493_E9(.CLK_DRV,
                   .CKA_N(_8V), .CKB_N(_16V),
                   .R0(VRESET), .R1(VRESET),
                   .QA(_16V), .QB(_32V), .QC(_64V), .QD(_128V));

  SN74107 SN74107_D9b(.CLK_DRV,
                      .CLK_N(_128V), .CLR_N(VRESET_N),
                      .J(1'b1), .K(1'b1),
                      .Q(_256V), .Q_N(_256V_N));

  logic D8c;
  assign D8c = ~(_1V & _4V & _256V);

  SN7474 SN7474_E7a(.CLK_DRV,
                    .CLK(CLK),
                    .PRE_N(1'b1), .CLR_N(1'b1),
                    .D(D8c),
                    .Q(VRESET_N), .Q_N(VRESET));
endmodule
