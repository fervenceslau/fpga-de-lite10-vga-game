	adc u0 (
		.clock_clk                (<connected-to-clock_clk>),                //          clock.clk
		.reset_sink_reset_n       (<connected-to-reset_sink_reset_n>),       //     reset_sink.reset_n
		.adc_pll_clock_clk        (<connected-to-adc_pll_clock_clk>),        //  adc_pll_clock.clk
		.adc_pll_locked_export    (<connected-to-adc_pll_locked_export>),    // adc_pll_locked.export
		.response_valid           (<connected-to-response_valid>),           //       response.valid
		.response_channel         (<connected-to-response_channel>),         //               .channel
		.response_data            (<connected-to-response_data>),            //               .data
		.response_startofpacket   (<connected-to-response_startofpacket>),   //               .startofpacket
		.response_endofpacket     (<connected-to-response_endofpacket>),     //               .endofpacket
		.response_2_valid         (<connected-to-response_2_valid>),         //     response_2.valid
		.response_2_channel       (<connected-to-response_2_channel>),       //               .channel
		.response_2_data          (<connected-to-response_2_data>),          //               .data
		.response_2_startofpacket (<connected-to-response_2_startofpacket>), //               .startofpacket
		.response_2_endofpacket   (<connected-to-response_2_endofpacket>),   //               .endofpacket
		.command_valid            (<connected-to-command_valid>),            //        command.valid
		.command_channel          (<connected-to-command_channel>),          //               .channel
		.command_startofpacket    (<connected-to-command_startofpacket>),    //               .startofpacket
		.command_endofpacket      (<connected-to-command_endofpacket>),      //               .endofpacket
		.command_ready            (<connected-to-command_ready>),            //               .ready
		.command_2_valid          (<connected-to-command_2_valid>),          //      command_2.valid
		.command_2_channel        (<connected-to-command_2_channel>),        //               .channel
		.command_2_startofpacket  (<connected-to-command_2_startofpacket>),  //               .startofpacket
		.command_2_endofpacket    (<connected-to-command_2_endofpacket>),    //               .endofpacket
		.command_2_ready          (<connected-to-command_2_ready>)           //               .ready
	);

