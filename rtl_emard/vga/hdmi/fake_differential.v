// File ../../../rtl_emard/vga/hdmi/fake_differential.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//
// AUTHOR=EMARD
// LICENSE=BSD
//
// VHDL Wrapper for verlog
// no timescale needed

module fake_differential(
input wire clk_shift,
input wire [1:0] in_clock,
input wire [1:0] in_red,
input wire [1:0] in_green,
input wire [1:0] in_blue,
output wire [3:0] out_p,
output wire [3:0] out_n
);

parameter [31:0] C_ddr=0;




  fake_differential_v #(
      .C_ddr(C_ddr))
  fake_differential_v_inst(
      .clk_shift(clk_shift),
    .in_clock(in_clock),
    .in_red(in_red),
    .in_green(in_green),
    .in_blue(in_blue),
    .out_p(out_p),
    .out_n(out_n));


endmodule
