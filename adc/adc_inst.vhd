	component adc is
		port (
			adc_command_valid          : in  std_logic                     := 'X';             -- valid
			adc_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			adc_command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			adc_command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			adc_command_ready          : out std_logic;                                        -- ready
			adc_response_valid         : out std_logic;                                        -- valid
			adc_response_channel       : out std_logic_vector(4 downto 0);                     -- channel
			adc_response_data          : out std_logic_vector(11 downto 0);                    -- data
			adc_response_startofpacket : out std_logic;                                        -- startofpacket
			adc_response_endofpacket   : out std_logic;                                        -- endofpacket
			clk_clk                    : in  std_logic                     := 'X';             -- clk
			clk_pll_clk                : out std_logic;                                        -- clk
			reset_reset_n              : in  std_logic                     := 'X'              -- reset_n
		);
	end component adc;

	u0 : component adc
		port map (
			adc_command_valid          => CONNECTED_TO_adc_command_valid,          --  adc_command.valid
			adc_command_channel        => CONNECTED_TO_adc_command_channel,        --             .channel
			adc_command_startofpacket  => CONNECTED_TO_adc_command_startofpacket,  --             .startofpacket
			adc_command_endofpacket    => CONNECTED_TO_adc_command_endofpacket,    --             .endofpacket
			adc_command_ready          => CONNECTED_TO_adc_command_ready,          --             .ready
			adc_response_valid         => CONNECTED_TO_adc_response_valid,         -- adc_response.valid
			adc_response_channel       => CONNECTED_TO_adc_response_channel,       --             .channel
			adc_response_data          => CONNECTED_TO_adc_response_data,          --             .data
			adc_response_startofpacket => CONNECTED_TO_adc_response_startofpacket, --             .startofpacket
			adc_response_endofpacket   => CONNECTED_TO_adc_response_endofpacket,   --             .endofpacket
			clk_clk                    => CONNECTED_TO_clk_clk,                    --          clk.clk
			clk_pll_clk                => CONNECTED_TO_clk_pll_clk,                --      clk_pll.clk
			reset_reset_n              => CONNECTED_TO_reset_reset_n               --        reset.reset_n
		);

