// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altera_modular_adc_conduit_splitter (
    input               clk,
    input               rst_n,
    input               clk_in_pll_locked,
    output              clk_in_pll_locked_out_1,
    output              clk_in_pll_locked_out_2
);


//-----------------------------------------------------------------------------//
// This core is specifically for splitter adc pll locked signal from export 
// to 2 ADC's pll lock input
//-----------------------------------------------------------------------------//
assign clk_in_pll_locked_out_1 = clk_in_pll_locked; 
assign clk_in_pll_locked_out_2 = clk_in_pll_locked; 

endmodule
