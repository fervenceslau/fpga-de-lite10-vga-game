// adc.v

// Generated using ACDS version 17.1 590

`timescale 1 ps / 1 ps
module adc (
		input  wire        adc_pll_clock_clk,        //  adc_pll_clock.clk
		input  wire        adc_pll_locked_export,    // adc_pll_locked.export
		input  wire        clock_clk,                //          clock.clk
		input  wire        command_valid,            //        command.valid
		input  wire [4:0]  command_channel,          //               .channel
		input  wire        command_startofpacket,    //               .startofpacket
		input  wire        command_endofpacket,      //               .endofpacket
		output wire        command_ready,            //               .ready
		input  wire        command_2_valid,          //      command_2.valid
		input  wire [4:0]  command_2_channel,        //               .channel
		input  wire        command_2_startofpacket,  //               .startofpacket
		input  wire        command_2_endofpacket,    //               .endofpacket
		output wire        command_2_ready,          //               .ready
		input  wire        reset_sink_reset_n,       //     reset_sink.reset_n
		output wire        response_valid,           //       response.valid
		output wire [4:0]  response_channel,         //               .channel
		output wire [11:0] response_data,            //               .data
		output wire        response_startofpacket,   //               .startofpacket
		output wire        response_endofpacket,     //               .endofpacket
		output wire        response_2_valid,         //     response_2.valid
		output wire [4:0]  response_2_channel,       //               .channel
		output wire [11:0] response_2_data,          //               .data
		output wire        response_2_startofpacket, //               .startofpacket
		output wire        response_2_endofpacket    //               .endofpacket
	);

	adc_modular_dual_adc_0 modular_dual_adc_0 (
		.clock_clk                (clock_clk),                //          clock.clk
		.reset_sink_reset_n       (reset_sink_reset_n),       //     reset_sink.reset_n
		.adc_pll_clock_clk        (adc_pll_clock_clk),        //  adc_pll_clock.clk
		.adc_pll_locked_export    (adc_pll_locked_export),    // adc_pll_locked.export
		.command_valid            (command_valid),            //        command.valid
		.command_channel          (command_channel),          //               .channel
		.command_startofpacket    (command_startofpacket),    //               .startofpacket
		.command_endofpacket      (command_endofpacket),      //               .endofpacket
		.command_ready            (command_ready),            //               .ready
		.command_2_valid          (command_2_valid),          //      command_2.valid
		.command_2_channel        (command_2_channel),        //               .channel
		.command_2_startofpacket  (command_2_startofpacket),  //               .startofpacket
		.command_2_endofpacket    (command_2_endofpacket),    //               .endofpacket
		.command_2_ready          (command_2_ready),          //               .ready
		.response_valid           (response_valid),           //       response.valid
		.response_channel         (response_channel),         //               .channel
		.response_data            (response_data),            //               .data
		.response_startofpacket   (response_startofpacket),   //               .startofpacket
		.response_endofpacket     (response_endofpacket),     //               .endofpacket
		.response_2_valid         (response_2_valid),         //     response_2.valid
		.response_2_channel       (response_2_channel),       //               .channel
		.response_2_data          (response_2_data),          //               .data
		.response_2_startofpacket (response_2_startofpacket), //               .startofpacket
		.response_2_endofpacket   (response_2_endofpacket)    //               .endofpacket
	);

endmodule
