LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY joystick IS
	PORT 
	(	
		clk50		  		: IN  STD_LOGIC; 							-- 50 MHZ
		joystick_data	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)	-- mov_x & mov_y & btn_press
	);
END joystick;

ARCHITECTURE behave OF joystick IS

	COMPONENT adc is
		port (
			adc_command_valid          : in  std_logic                     := '0';             --  adc_command.valid
			adc_command_channel        : in  std_logic_vector(4 downto 0)  := (others => '0'); --             .channel
			adc_command_startofpacket  : in  std_logic                     := '0';             --             .startofpacket
			adc_command_endofpacket    : in  std_logic                     := '0';             --             .endofpacket
			adc_command_ready          : out std_logic;                                        --             .ready
			adc_response_valid         : out std_logic;                                        -- adc_response.valid
			adc_response_channel       : out std_logic_vector(4 downto 0);                     --             .channel
			adc_response_data          : out std_logic_vector(11 downto 0);                    --             .data
			adc_response_startofpacket : out std_logic;                                        --             .startofpacket
			adc_response_endofpacket   : out std_logic;                                        --             .endofpacket
			clk_clk                    : in  std_logic                     := '0';             --          clk.clk
			clk_pll_clk                : out std_logic;                                        --      clk_pll.clk
			reset_reset_n              : in  std_logic                     := '0'              --        reset.reset_n
		);
	END COMPONENT;

	-- constants - sensibility to active movements (adc of 12 bits)
	CONSTANT MOV_SENS_H				:	STD_LOGIC_VECTOR (11 DOWNTO 0) 	:= "101000000000";
	CONSTANT MOV_SENS_L				:	STD_LOGIC_VECTOR (11 DOWNTO 0) 	:= "011000000000";
	
	-- constants - difinition of positive / negative / no movement
	CONSTANT MOV_POS					:	STD_LOGIC_VECTOR (1 DOWNTO 0)		:=	"01";
	CONSTANT MOV_NEG					:	STD_LOGIC_VECTOR (1 DOWNTO 0)		:=	"10";
	CONSTANT MOV_NONE					:	STD_LOGIC_VECTOR (1 DOWNTO 0)		:=	"00";
	
	-- constants - adc channels to sample for xy movement or btn press
	CONSTANT CHANNEL_X_MOV			:	STD_LOGIC_VECTOR (4 DOWNTO 0)		:=	"00001";
	CONSTANT CHANNEL_Y_MOV			:	STD_LOGIC_VECTOR (4 DOWNTO 0)		:=	"00010";
	CONSTANT CHANNEL_BTN				:	STD_LOGIC_VECTOR (4 DOWNTO 0)		:=	"00011";

	-- signals - adc data
	SIGNAL adc_reset_n				:	STD_LOGIC								:= '1';
	SIGNAL command_valid				:	STD_LOGIC								:= '1';
	SIGNAL command_channel			:	STD_LOGIC_VECTOR (4 DOWNTO 0)		:= CHANNEL_X_MOV;
	SIGNAL command_startofpacket	:	STD_LOGIC								:= '1';	-- altera_adc_control ignores => passes to output
	SIGNAL command_endofpacket		:	STD_LOGIC								:= '1';	-- altera_adc_control ignores => passes to output
	SIGNAL command_ready				:	STD_LOGIC;
	SIGNAL response_valid			:	STD_LOGIC;
	SIGNAL response_channel			:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL response_data				:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	SIGNAL response_startofpacket	:	STD_LOGIC;
	SIGNAL response_endofpacket	:	STD_LOGIC;
	SIGNAL clk_pll						:	STD_LOGIC;
		
BEGIN
	adc_reset_n 			 <= '1';
	command_valid 			 <= '1';
	command_startofpacket <= '1';
	command_endofpacket	 <= '1';

	-- instantiate adc (created with Platform Designer)
	joystick_adc : adc PORT MAP(	adc_command_valid				=> command_valid,
											adc_command_channel			=> command_channel,
											adc_command_startofpacket	=> command_startofpacket,
											adc_command_endofpacket		=> command_endofpacket,
											adc_command_ready				=> command_ready,
											adc_response_valid			=> response_valid,
											adc_response_channel			=> response_channel,
											adc_response_data				=> response_data,
											adc_response_startofpacket	=> response_startofpacket,
											adc_response_endofpacket	=> response_endofpacket,
											clk_clk 							=> clk50,
											reset_reset_n					=> adc_reset_n,
											clk_pll_clk						=> clk_pll);

	-- process that keeps reading the three sensors sequentially when data is available
	PROCESS (clk_pll)
	BEGIN
		IF (RISING_EDGE(clk_pll)) THEN
			CASE command_channel IS
				WHEN CHANNEL_X_MOV =>
					IF ((response_valid = '1') AND (response_channel = CHANNEL_X_MOV)) THEN
						IF (response_data >= MOV_SENS_H) THEN
							joystick_data(4 DOWNTO 3) <= MOV_POS;
						ELSIF (response_data <= MOV_SENS_L) THEN
							joystick_data(4 DOWNTO 3) <= MOV_NEG;
						ELSE
							joystick_data(4 DOWNTO 3) <= MOV_NONE;
						END IF;
						command_channel <= CHANNEL_Y_MOV;
					END IF;
				WHEN CHANNEL_Y_MOV =>
					IF ((response_valid = '1') AND (response_channel = CHANNEL_Y_MOV)) THEN
						IF (response_data >= MOV_SENS_H) THEN
							joystick_data(2 DOWNTO 1) <= MOV_NEG;
						ELSIF (response_data <= MOV_SENS_L) THEN
							joystick_data(2 DOWNTO 1) <= MOV_POS;
						ELSE
							joystick_data(2 DOWNTO 1) <= MOV_NONE;
						END IF;
						command_channel <= CHANNEL_BTN;
					END IF;
				WHEN CHANNEL_BTN =>
					IF ((response_valid = '1') AND (response_channel = CHANNEL_BTN)) THEN
						IF (response_data <= MOV_SENS_L) THEN
							joystick_data(0) <= '1';
						ELSE
							joystick_data(0) <= '0';
						END IF;
						command_channel <= CHANNEL_X_MOV;
					END IF;
				WHEN OTHERS => NULL;
			END CASE;
		END IF;
	END PROCESS;

END behave;