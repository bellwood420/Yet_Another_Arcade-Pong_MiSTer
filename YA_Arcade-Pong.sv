//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
  //Master input clock
  input         CLK_50M,

  //Async reset from top-level module.
  //Can be used as initial reset.
  input         RESET,

  //Must be passed to hps_io module
  inout  [45:0] HPS_BUS,

  //Base video clock. Usually equals to CLK_SYS.
  output        CLK_VIDEO,

  //Multiple resolutions are supported using different CE_PIXEL rates.
  //Must be based on CLK_VIDEO
  output        CE_PIXEL,

  //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
  output [11:0] VIDEO_ARX,
  output [11:0] VIDEO_ARY,

  output  [7:0] VGA_R,
  output  [7:0] VGA_G,
  output  [7:0] VGA_B,
  output        VGA_HS,
  output        VGA_VS,
  output        VGA_DE,    // = ~(VBlank | HBlank)
  output        VGA_F1,
  output [1:0]  VGA_SL,
  output        VGA_SCALER, // Force VGA scaler

  /*
  // Use framebuffer from DDRAM (USE_FB=1 in qsf)
  // FB_FORMAT:
  //    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
  //    [3]   : 0=16bits 565 1=16bits 1555
  //    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
  //
  // FB_STRIDE either 0 (rounded to 256 bytes) or multiple of 16 bytes.
  output        FB_EN,
  output  [4:0] FB_FORMAT,
  output [11:0] FB_WIDTH,
  output [11:0] FB_HEIGHT,
  output [31:0] FB_BASE,
  output [13:0] FB_STRIDE,
  input         FB_VBL,
  input         FB_LL,
  output        FB_FORCE_BLANK,

  // Palette control for 8bit modes.
  // Ignored for other video modes.
  output        FB_PAL_CLK,
  output  [7:0] FB_PAL_ADDR,
  output [23:0] FB_PAL_DOUT,
  input  [23:0] FB_PAL_DIN,
  output        FB_PAL_WR,
  */

  output        LED_USER,  // 1 - ON, 0 - OFF.

  // b[1]: 0 - LED status is system status OR'd with b[0]
  //       1 - LED status is controled solely by b[0]
  // hint: supply 2'b00 to let the system control the LED.
  output  [1:0] LED_POWER,
  output  [1:0] LED_DISK,

  // I/O board button press simulation (active high)
  // b[1]: user button
  // b[0]: osd button
  output  [1:0] BUTTONS,

  input         CLK_AUDIO, // 24.576 MHz
  output [15:0] AUDIO_L,
  output [15:0] AUDIO_R,
  output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
  output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

  //ADC
  inout   [3:0] ADC_BUS,

  //SD-SPI
  output        SD_SCK,
  output        SD_MOSI,
  input         SD_MISO,
  output        SD_CS,
  input         SD_CD,

  //High latency DDR3 RAM interface
  //Use for non-critical time purposes
  output        DDRAM_CLK,
  input         DDRAM_BUSY,
  output  [7:0] DDRAM_BURSTCNT,
  output [28:0] DDRAM_ADDR,
  input  [63:0] DDRAM_DOUT,
  input         DDRAM_DOUT_READY,
  output        DDRAM_RD,
  output [63:0] DDRAM_DIN,
  output  [7:0] DDRAM_BE,
  output        DDRAM_WE,

  //SDRAM interface with lower latency
  output        SDRAM_CLK,
  output        SDRAM_CKE,
  output [12:0] SDRAM_A,
  output  [1:0] SDRAM_BA,
  inout  [15:0] SDRAM_DQ,
  output        SDRAM_DQML,
  output        SDRAM_DQMH,
  output        SDRAM_nCS,
  output        SDRAM_nCAS,
  output        SDRAM_nRAS,
  output        SDRAM_nWE,

  input         UART_CTS,
  output        UART_RTS,
  input         UART_RXD,
  output        UART_TXD,
  output        UART_DTR,
  input         UART_DSR,

  // Open-drain User port.
  // 0 - D+/RX
  // 1 - D-/TX
  // 2..6 - USR2..USR6
  // Set USER_OUT to 1 to read from USER_IN.
  input   [6:0] USER_IN,
  output  [6:0] USER_OUT,

  input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0; 

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

///////////////////////   CONF STR  ///////////////////////////////

`include "build_id.v"
localparam CONF_STR = {
  "YA.A.PONG;;",
  "-;",
  "O23,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
  "O46,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
  "-;",
  "O7,Max Points,11,15;",
  "O8A,Control P1,Digital,Y,Y-Inv,X,X-Inv,Paddle,Paddle-Inv;",
  "OBD,Control P2,Digital,Y,Y-Inv,X,X-Inv,Paddle,Paddle-Inv;",
  "-;",
  "OE,Paddle Speed,Slow,Fast;",
  "-;",
  "R0,Reset;",
  "J1,Start;",
  "V,v",`BUILD_DATE
};

///////////////////////   CLOCKS   ///////////////////////////////

// System clock - 53.272 MHz
wire clk_sys;
pll pll
(
  .refclk(CLK_50M),
  .rst(0),
  .outclk_0(clk_sys),
);

reg [2:0] clk_cnt;

always_ff @(posedge clk_sys, posedge reset) begin
  if (reset) begin
    clk_cnt = 1'b0;
  end else begin
    clk_cnt <= clk_cnt + 1;
  end
end

// Drive clock 14.318 Mhz - for synchronous driving PONG circuit
wire clk_drv = clk_cnt[1];

// Pixel clock 7.159 Mhz  - for PONG main clock as pixel clock
wire clk_pck = clk_cnt[2];

// Reset Signal
wire reset = RESET | status[0] | buttons[1];

///////////////////////   HPS IO   ///////////////////////////////
wire [31:0] joystick_0, joystick_1;
wire [15:0] joystick_analog_0, joystick_analog_1;
wire  [7:0] paddle_0, paddle_1;
wire  [1:0] buttons;
wire [63:0] status;
wire [10:0] ps2_key;
wire [21:0] gamma_bus;
wire        forced_scandoubler;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
  .clk_sys,
  .HPS_BUS(HPS_BUS),
  .EXT_BUS(),
  .gamma_bus,

  .conf_str(CONF_STR),
  .forced_scandoubler,

  .joystick_0,
  .joystick_1,
  .joystick_analog_0,
  .joystick_analog_1,
  .paddle_0,
  .paddle_1,

  .buttons,
  .status,

  .ps2_key(ps2_key)
);

///////////////////////    VIDEO    ///////////////////////////////
wire [1:0] ar = status[3:2];
assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

wire hblank, vblank;
wire hsync, vsync;
wire video, score;

wire [3:0]  brightness = video ? 4'hF : score ? 4'hE : 4'd0;
wire [11:0] rgb = {3{brightness}};

arcade_video #(.WIDTH(375), .DW(12)) arcade_video
(
  .*,

  .clk_video(clk_sys),
  .ce_pix(clk_pck),

  .RGB_in(rgb),
  .HBlank(hblank),
  .VBlank(vblank),
  .HSync(hsync),
  .VSync(vsync),

  .fx(status[6:4]),
  .forced_scandoubler,
  .gamma_bus,
);

reg  hsync_old, vsync_old;
wire hsync_posedge = hsync & ~hsync_old;
wire vsync_posedge = vsync & ~vsync_old;

always_ff @(posedge clk_sys) begin
  hsync_old <= hsync;
  vsync_old <= vsync;
end

///////////////////////    SOUND    ///////////////////////////////
wire sound;
assign AUDIO_L = {1'b0, ~sound, 14'b0};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0;
assign AUDIO_MIX = 'd3;

///////////////////////   KEYBOARD  ///////////////////////////////
wire [7:0]  key_scancode = ps2_key[7:0];
wire        key_pressed  = ps2_key[9];
wire        key_state    = ps2_key[10];

reg  key_state_old;
wire key_state_changed = key_state ^ key_state_old;

reg  btn_coin   = 1'b0;
reg  btn_P1Up   = 1'b0;
reg  btn_P1Down = 1'b0;
reg  btn_P2Up   = 1'b0;
reg  btn_P2Down = 1'b0;

always_ff @(posedge clk_sys) begin
  key_state_old <= key_state;

  if (key_state_changed) begin
    case (key_scancode)
      'h05: btn_coin   <= key_pressed; // F1
      'h06: btn_coin   <= key_pressed; // F2
      'h16: btn_coin   <= key_pressed; // 1
      'h1E: btn_coin   <= key_pressed; // 2
      'h2E: btn_coin   <= key_pressed; // 5
      'h36: btn_coin   <= key_pressed; // 6
      'h1D: btn_P1Up   <= key_pressed; // W
      'h1B: btn_P1Down <= key_pressed; // S
      'h75: btn_P2Up   <= key_pressed; // up
      'h72: btn_P2Down <= key_pressed; // down
      default: ;
    endcase
  end
end

///////////////////////   CONTROL   ///////////////////////////////
wire coin_sw;
wire pad_trg_n;
wire pad1_out, pad2_out;

//
// Paddle positioning for digital input
//
localparam ugap = 23;
localparam lgap = 13;

wire       speed = status[14];
wire [3:0] delta = speed ? 4'd8 : 4'd4;

reg  [8:0] p1pos_d = 8'd114;
reg  [8:0] p2pos_d = 8'd114;

wire p1Up   = btn_P1Up   | joystick_0[3];
wire p1Dpwn = btn_P1Down | joystick_0[2];
wire p2Up   = btn_P2Up   | joystick_1[3];
wire p2Down = btn_P2Down | joystick_1[2];

always_ff @(posedge clk_sys) begin
  if (vsync_posedge) begin
    if (p1Up)   p1pos_d <= ((p1pos_d - delta - ugap) > 255) ? 9'd0   + ugap : (p1pos_d - delta);
    if (p1Dpwn) p1pos_d <= ((p1pos_d + delta + lgap) > 255) ? 9'd255 - lgap : (p1pos_d + delta);
    if (p2Up)   p2pos_d <= ((p2pos_d - delta - ugap) > 255) ? 9'd0   + ugap : (p2pos_d - delta);
    if (p2Down) p2pos_d <= ((p2pos_d + delta + lgap) > 255) ? 9'd255 - lgap : (p2pos_d + delta);
  end
end

//
// Paddle positioning for analog input
//
wire [7:0] p1joy_sx = joystick_analog_0[7:0];
wire [7:0] p1joy_sy = joystick_analog_0[15:8];
wire [7:0] p2joy_sx = joystick_analog_1[7:0];
wire [7:0] p2joy_sy = joystick_analog_1[15:8];

wire [7:0] p1pos_ax = {~p1joy_sx[7], p1joy_sx[6:0]};
wire [7:0] p1pos_ay = {~p1joy_sy[7], p1joy_sy[6:0]};
wire [7:0] p2pos_ax = {~p2joy_sx[7], p2joy_sx[6:0]};
wire [7:0] p2pos_ay = {~p2joy_sy[7], p2joy_sy[6:0]};

//
// Count horizontol line
//
reg [7:0] p1cnt = 8'd0;
reg [7:0] p2cnt = 8'd0;

always_ff @(posedge clk_sys) begin
  if (!pad_trg_n) begin
    p1cnt <= 8'd0;
    p2cnt <= 8'd0;
  end else if (hsync_posedge) begin
    p1cnt <= p1cnt + 'd1;
    p2cnt <= p2cnt + 'd1;
  end
end

//
// Mix Inputs
//
wire [2:0] p1cntl = status[10:8];
wire [2:0] p2cntl = status[13:11];

wire [7:0] p1pos;
wire [7:0] p2pos;

wire [7:0] range_map [0:255] = '{
  23,  24,  25,  26,  26,  27,  28,  29,  30,  31,  32,  32,  33,  34,  35,  36,
  37,  38,  38,  39,  40,  41,  42,  43,  44,  44,  45,  46,  47,  48,  49,  50,
  50,  51,  52,  53,  54,  55,  56,  56,  57,  58,  59,  60,  61,  62,  63,  63,
  64,  65,  66,  67,  68,  69,  69,  70,  71,  72,  73,  74,  75,  75,  76,  77,
  78,  79,  80,  81,  81,  82,  83,  84,  85,  86,  87,  87,  88,  89,  90,  91,
  92,  93,  93,  94,  95,  96,  97,  98,  99,  99,  100, 101, 102, 103, 104, 105,
  105, 106, 107, 108, 109, 110, 111, 111, 112, 113, 114, 115, 116, 117, 117, 118,
  119, 120, 121, 122, 123, 123, 124, 125, 126, 127, 128, 129, 129, 130, 131, 132,
  133, 134, 135, 136, 136, 137, 138, 139, 140, 141, 142, 142, 143, 144, 145, 146,
  147, 148, 148, 149, 150, 151, 152, 153, 154, 154, 155, 156, 157, 158, 159, 160,
  160, 161, 162, 163, 164, 165, 166, 166, 167, 168, 169, 170, 171, 172, 172, 173,
  174, 175, 176, 177, 178, 178, 179, 180, 181, 182, 183, 184, 184, 185, 186, 187,
  188, 189, 190, 190, 191, 192, 193, 194, 195, 196, 196, 197, 198, 199, 200, 201,
  202, 202, 203, 204, 205, 206, 207, 208, 209, 209, 210, 211, 212, 213, 214, 215,
  215, 216, 217, 218, 219, 220, 221, 221, 222, 223, 224, 225, 226, 227, 227, 228,
  229, 230, 231, 232, 233, 233, 234, 235, 236, 237, 238, 239, 239, 240, 241, 242};

always_comb begin
  case (p1cntl)
    3'd0:    p1pos = p1pos_d[7:0];             // Digital
    3'd1:    p1pos = range_map[p1pos_ay];      // Y
    3'd2:    p1pos = range_map[~p1pos_ay];     // Y-Inv
    3'd3:    p1pos = range_map[p1pos_ax];      // X
    3'd4:    p1pos = range_map[~p1pos_ax];     // X-Inv
    3'd5:    p1pos = range_map[paddle_0];      // Paddle
    3'd6:    p1pos = range_map[~paddle_0];     // Paddle-Inv
    default: p1pos = 8'd114;
  endcase
  case (p2cntl)
    3'd0:    p2pos = p2pos_d[7:0];             // Digital
    3'd1:    p2pos = range_map[p2pos_ay];      // Y
    3'd2:    p2pos = range_map[~p2pos_ay];     // Y-Inv
    3'd3:    p2pos = range_map[p2pos_ax];      // X
    3'd4:    p2pos = range_map[~p2pos_ax];     // X-Inv
    3'd5:    p2pos = range_map[paddle_1];      // Paddle
    3'd6:    p2pos = range_map[~paddle_1];     // Paddle-Inv
    default: p2pos = 8'd114;
  endcase
end

assign coin_sw = btn_coin | buttons[0] | joystick_0[4] | joystick_1[4];
assign pad1_out = p1cnt < p1pos;
assign pad2_out = p2cnt < p2pos;

///////////////////////     PONG    ///////////////////////////////

pongtop pongtop(
  .CLK_DRV(clk_drv),
  .CLK(clk_pck),
  .FPGA_RESET(reset),
  .COIN_SW(coin_sw),
  .SW1A(status[7]),
  .SW1B(status[7]),
  .PAD_TRG_N(pad_trg_n),
  .PAD1_OUT(pad1_out),
  .PAD2_OUT(pad2_out),
  .HBLANK(hblank),
  .VBLANK(vblank),
  .HSYNC(hsync),
  .VSYNC(vsync),
  .VIDEO(video),
  .SCORE(score),
  .SOUND(sound)
);

endmodule
