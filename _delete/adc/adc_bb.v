
module adc (
	clock_clk,
	reset_sink_reset_n,
	adc_pll_clock_clk,
	adc_pll_locked_export,
	response_valid,
	response_channel,
	response_data,
	response_startofpacket,
	response_endofpacket,
	response_2_valid,
	response_2_channel,
	response_2_data,
	response_2_startofpacket,
	response_2_endofpacket,
	command_valid,
	command_channel,
	command_startofpacket,
	command_endofpacket,
	command_ready,
	command_2_valid,
	command_2_channel,
	command_2_startofpacket,
	command_2_endofpacket,
	command_2_ready);	

	input		clock_clk;
	input		reset_sink_reset_n;
	input		adc_pll_clock_clk;
	input		adc_pll_locked_export;
	output		response_valid;
	output	[4:0]	response_channel;
	output	[11:0]	response_data;
	output		response_startofpacket;
	output		response_endofpacket;
	output		response_2_valid;
	output	[4:0]	response_2_channel;
	output	[11:0]	response_2_data;
	output		response_2_startofpacket;
	output		response_2_endofpacket;
	input		command_valid;
	input	[4:0]	command_channel;
	input		command_startofpacket;
	input		command_endofpacket;
	output		command_ready;
	input		command_2_valid;
	input	[4:0]	command_2_channel;
	input		command_2_startofpacket;
	input		command_2_endofpacket;
	output		command_2_ready;
endmodule
