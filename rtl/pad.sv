/*
 * Paddle
 */
module pad(
  input   logic   CLK_DRV,
  input   logic   PAD1_OUT, PAD2_OUT,
  input   logic   _4H, _128H, _256H, _256H_N, HSYNC_N, ATTRACT_N,
  output  logic   PAD1, PAD2,
  output  logic   B1, C1, D1, B2, C2, D2
);
  //
  // PAD1 vertical visibility and position control
  //
  logic C9b, B7b, VPAD1_N, A7b, A7b_q;
  logic QA_B8, QB_B8, QC_B8, QD_B8;

  assign C9b = ~PAD1_OUT;
  assign B7b = ~(A7b_q & HSYNC_N);
  assign VPAD1_N = ~(C9b & A7b_q);
  assign A7b = ~(QA_B8 & QB_B8 & QC_B8 & QD_B8);
  // Break combinatioanl loop
  always_ff @(posedge CLK_DRV) begin
    A7b_q <= A7b;
  end

  SN7493 SN7493_B8(.CLK_DRV,
                   .CKA_N(B7b), .CKB_N(QA_B8),
                   .R0(PAD1_OUT), .R1(PAD1_OUT),
                   .QA(QA_B8), .QB(QB_B8), .QC(QC_B8), .QD(QD_B8));

  //
  // PAD2 vertical visibility and position control
  //
  logic C9a, B7c, VPAD2_N, A7a, A7a_q;
  logic QA_A8, QB_A8, QC_A8, QD_A8;

  assign C9a = ~PAD2_OUT;
  assign B7c = ~(A7a_q & HSYNC_N);
  assign VPAD2_N = ~(C9a & A7a_q);
  assign A7a = ~(QA_A8 & QB_A8 & QC_A8 & QD_A8);
  // Break combinatioanl loop
  always_ff @(posedge CLK_DRV) begin
    A7a_q <= A7a;
  end

  SN7493 SN7493_A8(.CLK_DRV,
                   .CKA_N(B7c), .CKB_N(QA_A8),
                   .R0(PAD2_OUT), .R1(PAD2_OUT),
                   .QA(QA_A8), .QB(QB_A8), .QC(QC_A8), .QD(QD_A8));

  /*
   * NOTE:
   *
   * Two registers (A7b_q and A7a_q) are not in the original circuit.
   * They are inserted to break combinational loop and stop oscillation.
   * In the original circuit, outputs of A7b and A7a are used to gating SN7493 clock input,
   * not causing combinational loop.
   * But in this project, the original clock is treated as data path for edge detection
   * driven by faster clock, causing combinational loop in data path.
   * The delay of these registers does not affect the original timing.
   */

  //
  // PAD1 & PAD2 horizontal visibility control
  //
  logic H3a_Q_N, G3c;
  SN7474 SN7474_H3a(.CLK_DRV, .CLK(_4H),
                    .PRE_N(ATTRACT_N), .CLR_N(1'b1),
                    .D(_128H), .Q(), .Q_N(H3a_Q_N));
  assign G3c = ~(_128H & H3a_Q_N); // pad visible when G3c is low

  //
  // PAD1 & PAD2 visibility control mix
  //
  assign PAD1 = ~(VPAD1_N | _256H | G3c);
  assign PAD2 = ~(VPAD2_N | _256H_N | G3c);

  //
  // Paddle drawing position output
  //
  assign {B1, C1, D1} = {QB_B8, QC_B8, QD_B8};
  assign {B2, C2, D2} = {QB_A8, QC_A8, QD_A8};

endmodule
