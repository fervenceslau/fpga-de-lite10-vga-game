LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY display_score IS
	PORT 
	(	
		clk25			: IN  STD_LOGIC;								-- pixel clk
		clkrtc		: IN  STD_LOGIC;								-- real time clock (1 Hz)
		rst 		  	: IN  STD_LOGIC;
		game_over	: IN	STD_LOGIC;
		min_x			: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	-- minimum allowed positions
		max_x			: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	
		min_y			: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	-- maximum allowed positions
		max_y			: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	
		pixel_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		pixel_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		score_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		score_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		score_color : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		score_on		: OUT STD_LOGIC
	);
END display_score;

ARCHITECTURE behave OF display_score IS	
	CONSTANT STR_COLOR	: STD_LOGIC_VECTOR(11 DOWNTO 0)		:=	X"FF0";
	
	CONSTANT CHAR_WIDTH	: INTEGER									:= 8;
	CONSTANT CHAR_HEIGHT	: INTEGER									:= 16;
	CONSTANT STR_NUM		: INTEGER									:= 14;
	
	TYPE rom_str IS ARRAY (0 TO (STR_NUM-1)) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
 
	 -- DISK ROM definition
	 CONSTANT ROM_TIMER: rom_str :=
	 (
		 "10100110000",	-- S
		 "11000110000",	-- c
		 "11011110000",	-- o
		 "11100100000",	-- r
		 "11001010000",	-- e
		 "01110100000",	-- :
		 "00000000000",	-- 
		 "00000000000",	-- empty score space 1
		 "00000000000",	-- empty score space 2
		 "00000000000",	-- empty score space 3
		 "00000000000",	-- empty score space 4
		 "00000000000",	-- empty score space 5
		 "00000000000",	-- empty score space 6
		 "01100000000"		-- 0 -- rightmost (the last is always 0)
	 ); 
	
	SIGNAL char_code			: STD_LOGIC_VECTOR(10 DOWNTO 0);	
	SIGNAL font_address		: STD_LOGIC_VECTOR(10 downto 0);
	SIGNAL font_data			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL font_bit			: STD_LOGIC;
	
	SIGNAL pos_diff_x			: UNSIGNED(9 downto 0);
	SIGNAL pos_diff_y			: UNSIGNED(9 downto 0);
	
	SIGNAL score_seg_1		: UNSIGNED(3 DOWNTO 0);				-- Leftmost
	SIGNAL score_seg_2		: UNSIGNED(3 DOWNTO 0);
	SIGNAL score_seg_3		: UNSIGNED(3 DOWNTO 0);
	SIGNAL score_seg_4		: UNSIGNED(3 DOWNTO 0);
	SIGNAL score_seg_5		: UNSIGNED(3 DOWNTO 0);
	SIGNAL score_seg_6		: UNSIGNED(3 DOWNTO 0);				-- rightmost (the last is always 0)
	SIGNAL score_seg_code	: UNSIGNED(10 downto 0);
	
	SIGNAL score_counter		: INTEGER 								:= 0;
	
BEGIN

	score_color <= STR_COLOR;

	-- process that update timer display segments (somewhat BCD coded) with each clkrtl (real time clock)
	PROCESS (clkrtc, rst)
	BEGIN
		IF (rst = '1') THEN
			score_seg_1   <= "0000";
			score_seg_2   <= "0000";
			score_seg_3   <= "0000";
			score_seg_4   <= "0000";
			score_seg_5   <= "0000";
			score_seg_6   <= "0000";
			score_counter <= 0;
		ELSIF (RISING_EDGE(clkrtc)) THEN
			IF (game_over = '0') THEN
				IF (score_seg_6 = "1001") THEN
					score_seg_6 <= "0000";				
					IF (score_seg_5 = "1001") THEN
						score_seg_5 <= "0000";
						IF (score_seg_4 = "1001") THEN
							score_seg_4 <= "0000";
								IF (score_seg_3 = "1001") THEN
									score_seg_3 <= "0000";
									IF (score_seg_2 = "1001") THEN
										score_seg_2 <= "0000";
										IF (score_seg_1 = "1001") THEN
											score_seg_1 <= "0000";
										ELSE
											score_seg_1 <= score_seg_1 + 1;
										END IF;
									ELSE
										score_seg_2 <= score_seg_2 + 1;
									END IF;
								ELSE
									score_seg_3 <= score_seg_3 + 1;
								END IF;
						ELSE
							score_seg_4 <= score_seg_4 + 1;
						END IF;
					ELSE
						score_seg_5 <= score_seg_5 + 1;
					END IF;
				ELSE
					score_seg_6 <= score_seg_6 + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- variables necessary to prevent under / overflow
	pos_diff_x <= UNSIGNED(pixel_x) - UNSIGNED(score_x);
	pos_diff_y <= UNSIGNED(pixel_y) - UNSIGNED(score_y);
	
	-- code offset due to numbering of the display
	PROCESS (pos_diff_x)
	BEGIN
		CASE pos_diff_x(6 DOWNTO 3) IS
			WHEN "0111" => score_seg_code <= ("000" & score_seg_1 & "0000") + "01100000000"; -- 16 x value on seg register
			WHEN "1000" => score_seg_code <= ("000" & score_seg_2 & "0000") + "01100000000";
			WHEN "1001" => score_seg_code <= ("000" & score_seg_3 & "0000") + "01100000000";
			WHEN "1010" => score_seg_code <= ("000" & score_seg_4 & "0000") + "01100000000";
			WHEN "1011" => score_seg_code <= ("000" & score_seg_5 & "0000") + "01100000000";
			WHEN "1100" => score_seg_code <= ("000" & score_seg_6 & "0000") + "01100000000";
			WHEN OTHERS => score_seg_code <= (OTHERS => '0');
		END CASE;
	END PROCESS;

	-- reads character code from ROM_TIMER every 8 pixels
	char_code	 <= ROM_TIMER(TO_INTEGER(pos_diff_x(6 DOWNTO 3)));
	font_address <= STD_LOGIC_VECTOR(('0' & pos_diff_y(3 DOWNTO 0)) + UNSIGNED(char_code) + score_seg_code);
	font_bit		 <= font_data(7 - TO_INTEGER(pos_diff_x(2 DOWNTO 0)));
	
	F : ENTITY work.font_rom 	PORT MAP (	clk25,
														font_address,
														font_data);
																
	score_on <=
		'1' WHEN	(score_x <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(UNSIGNED(score_x) + STR_NUM*CHAR_WIDTH - 1)) AND
					(score_y <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(UNSIGNED(score_y) + CHAR_HEIGHT - 1)) AND 
					(font_bit = '1') ELSE
		'0';

END behave;