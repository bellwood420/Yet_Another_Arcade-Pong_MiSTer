/*
 * Net generation
 */
module net(
  input   logic   CLK_DRV, CLK,
  input   logic   _256H, _256H_N, _4V, VBLANK,
  output  logic   NET
);
  logic F3b_Q_N;

  SN74107 SN74107_F3b(.CLK_DRV, .CLK_N(CLK), .CLR_N(1'b1),
                      .J(_256H), .K(_256H_N),
                      .Q(), .Q_N(F3b_Q_N));

  logic G3b, G2b;
  assign G3b = ~(_256H & F3b_Q_N);
  assign G2b = ~(_4V | VBLANK | G3b);
  assign NET = G2b;

endmodule
