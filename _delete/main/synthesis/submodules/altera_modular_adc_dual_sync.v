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

module altera_modular_adc_dual_sync (
    input               clk,
    input               rst_n,
    input               sync_1_valid,
    input               sync_2_valid,
    output              sync_1_ready,
    output              sync_2_ready

);

wire    sync_ready;

assign sync_ready   = sync_1_valid & sync_2_valid;
assign sync_1_ready = sync_ready;
assign sync_2_ready = sync_ready;


endmodule
