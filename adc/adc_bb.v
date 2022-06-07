
module adc (
	adc_command_valid,
	adc_command_channel,
	adc_command_startofpacket,
	adc_command_endofpacket,
	adc_command_ready,
	adc_response_valid,
	adc_response_channel,
	adc_response_data,
	adc_response_startofpacket,
	adc_response_endofpacket,
	clk_clk,
	clk_pll_clk,
	reset_reset_n);	

	input		adc_command_valid;
	input	[4:0]	adc_command_channel;
	input		adc_command_startofpacket;
	input		adc_command_endofpacket;
	output		adc_command_ready;
	output		adc_response_valid;
	output	[4:0]	adc_response_channel;
	output	[11:0]	adc_response_data;
	output		adc_response_startofpacket;
	output		adc_response_endofpacket;
	input		clk_clk;
	output		clk_pll_clk;
	input		reset_reset_n;
endmodule
