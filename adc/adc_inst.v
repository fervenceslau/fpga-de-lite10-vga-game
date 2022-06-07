	adc u0 (
		.adc_command_valid          (<connected-to-adc_command_valid>),          //  adc_command.valid
		.adc_command_channel        (<connected-to-adc_command_channel>),        //             .channel
		.adc_command_startofpacket  (<connected-to-adc_command_startofpacket>),  //             .startofpacket
		.adc_command_endofpacket    (<connected-to-adc_command_endofpacket>),    //             .endofpacket
		.adc_command_ready          (<connected-to-adc_command_ready>),          //             .ready
		.adc_response_valid         (<connected-to-adc_response_valid>),         // adc_response.valid
		.adc_response_channel       (<connected-to-adc_response_channel>),       //             .channel
		.adc_response_data          (<connected-to-adc_response_data>),          //             .data
		.adc_response_startofpacket (<connected-to-adc_response_startofpacket>), //             .startofpacket
		.adc_response_endofpacket   (<connected-to-adc_response_endofpacket>),   //             .endofpacket
		.clk_clk                    (<connected-to-clk_clk>),                    //          clk.clk
		.clk_pll_clk                (<connected-to-clk_pll_clk>),                //      clk_pll.clk
		.reset_reset_n              (<connected-to-reset_reset_n>)               //        reset.reset_n
	);

