/*
 * Video sync generation
 */
`define CENTER_MOD
module sync(
  input   logic   CLK_DRV,
  input   logic   _16H, _32H, _64H, HRESET_N,
  input   logic   _4V, _8V, _16V, VRESET,
  output  logic   HBLANK, HBLANK_N, HSYNC_N,
  output  logic   VBLANK, VBLANK_N, VSYNC_N
);
  //
  // HBLANK
  //
  logic G5b, HBLANK_D, HBLANK_D_N;
  assign G5b = ~(_16H & _64H);

  nand_rsff nand_rsff(.CLK_DRV,
                      .S_N(G5b), .R_N(HRESET_N),
                      .Q(HBLANK_D_N), .Q_N(HBLANK_D));

  /*
   * NOTE:
   *
   * Add delay to HBLANK signal in order to count horizontal ball counter correctly.
   * Without this delay, horizontal ball counter counts up at rising edge of CLK
   * while horizontal counter value is in 80, leading to over counting.
   * This delay is unintentionally caused by ripple counters in original circuit.
   * In this whole synchrous version project, a delay of D-FF is used instead of it.
   * The delay is similar to the original one.
   */
  always @(posedge CLK_DRV) begin
    HBLANK <= HBLANK_D;
    HBLANK_N <= HBLANK_D_N;
  end

  //
  // HSYNC
  //
  `ifndef CENTER_MOD
    // Original HSYNC: the center of the picture is off to the left
    assign HSYNC_N = ~(HBLANK & _32H);

  `else
    // Modded HSYNC: PONG doubles version
    logic D, CLR_N;
    assign D = ~(~_64H & _32H);
    assign CLR_N = ~(_64H | HBLANK_N);
    SN7474 SN7474(.CLK_DRV,
                  .CLK(_16H),
                  .PRE_N(1'b1), .CLR_N,
                  .D,
                  .Q(), .Q_N(HSYNC_N));
  `endif

  //
  // VBLANK
  //
  nor_rsff nor_rsff(.CLK_DRV,
                    .R(VRESET), .S(_16V),
                    .Q(VBLANK_N), .Q_N(VBLANK));

  //
  // VSYNC
  //
  logic H5a;
  assign H5a = ~_8V;

  assign VSYNC_N = ~(VBLANK & _4V & H5a);

endmodule
