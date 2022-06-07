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

module altera_modular_adc_response_merge (
    input               clk,
    input               rst_n,
    input               rsp_in_1_valid,
    input [4:0]         rsp_in_1_channel,
    input [11:0]        rsp_in_1_data,
    input               rsp_in_1_sop,
    input               rsp_in_1_eop,
    input               rsp_in_2_valid,
    input [4:0]         rsp_in_2_channel,
    input [11:0]        rsp_in_2_data,
    input               rsp_in_2_sop,
    input               rsp_in_2_eop,

    output              rsp_out_valid,
    output [4:0]        rsp_out_channel,
    output [23:0]       rsp_out_data,
    output              rsp_out_sop,
    output              rsp_out_eop
);

//--------------------------------------------------------------------------------------------------//
// rsp_in_1_valid and rsp_in_2_valid is guaranteed to be assert/de-assert at the same time (design
// requirement) of the dual adc synchronization in the control core
// Except data, other signal roles of response 1 and 2 is same
//--------------------------------------------------------------------------------------------------//
assign rsp_out_valid        = rsp_in_1_valid;
assign rsp_out_channel      = rsp_in_1_channel;
assign rsp_out_data         = {rsp_in_2_data, rsp_in_1_data};
assign rsp_out_sop          = rsp_in_1_sop;
assign rsp_out_eop          = rsp_in_1_eop;


endmodule
