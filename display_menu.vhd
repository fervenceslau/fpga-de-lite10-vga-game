LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY display_menu IS
	PORT 
	(	
		clk25				: IN  STD_LOGIC;								-- pixel clk
		clkrtc			: IN  STD_LOGIC;								-- real time clock (1 Hz)
		v_sync			: IN  STD_LOGIC;
		rst 		  		: IN  STD_LOGIC;
		enable			: IN	STD_LOGIC;
		joystick_data	: IN	STD_LOGIC_VECTOR (4  DOWNTO 0);	-- mov_x & mov_y & btn_press
		pixel_x			: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		pixel_y			: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		menu_min_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		menu_max_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		menu_min_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		menu_max_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		menu_lock		: OUT	STD_LOGIC								:= '1';
		menu_color 		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		menu_on			: OUT STD_LOGIC
	);
END display_menu;

ARCHITECTURE behave OF display_menu IS
	CONSTANT STATE_MENU		: STD_LOGIC_VECTOR (2  DOWNTO 0) := "000";
	CONSTANT STATE_RUN		: STD_LOGIC_VECTOR (2  DOWNTO 0) := "000";

	CONSTANT COLOR				: STD_LOGIC_VECTOR (11 DOWNTO 0)	:= X"FFF";
	CONSTANT MENU_THICKNESS	: UNSIGNED(9 DOWNTO 0)				:= TO_UNSIGNED(2, 10);
	
	CONSTANT MOV_UP			: STD_LOGIC_VECTOR (1 DOWNTO 0) 	:= "10";
	CONSTANT MOV_DOWN			: STD_LOGIC_VECTOR (1 DOWNTO 0) 	:= "01";
	
	CONSTANT OPTION_START	: STD_LOGIC_VECTOR (1 DOWNTO 0) 	:= "00";
	CONSTANT OPTION_INFO		: STD_LOGIC_VECTOR (1 DOWNTO 0) 	:= "01";

	SIGNAL menu_option		: STD_LOGIC_VECTOR (1 DOWNTO 0) 	:= OPTION_START;
	
	SIGNAL outer_menu_on		: STD_LOGIC;
	SIGNAL inner_menu_on		: STD_LOGIC;
	
	
	
	
	CONSTANT CHAR_WIDTH		: INTEGER								:= 8;
	CONSTANT CHAR_HEIGHT		: INTEGER								:= 16;
	CONSTANT STR_NUM			: INTEGER								:= 23;
	CONSTANT STR_NUM_TITLE	: INTEGER								:= 9;
	CONSTANT STR_NUM_OPT_1	: INTEGER								:= 7;
	CONSTANT STR_NUM_OPT_2	: INTEGER								:= 7;
	CONSTANT FSIZE_TITLE		: INTEGER								:= 2;
	
	TYPE rom_str 		IS ARRAY (0 TO (STR_NUM-1)) 	OF STD_LOGIC_VECTOR(10 DOWNTO 0);
	TYPE rom_str_pos 	IS ARRAY (0 TO 5) 				OF UNSIGNED(9 DOWNTO 0);
 
	 -- ROM of chars definition
	 CONSTANT ROM_MENU: rom_str :=
	 (
		 "10101000000",	-- T
		 "11010000000",	-- h
		 "11001010000",	-- e
		 "00000000000",	-- 
		 "01101010000",	-- 5
		 "00000000000",	-- 
		 "10001000000",	-- D
		 "01001110000",	-- '
		 "11100110000",	-- s
		 ----------------------
		 "00000000000",   -- (arrow, select option)
		 "00000000000",
		 "10100110000",	-- S
		 "11101000000",	-- t
		 "11000010000",	-- a
		 "11100100000",	-- r
		 "11101000000",   -- t
		 ----------------------
		 "00000000000",   -- (arrow, select option) -- 100000000
		 "00000000000",
		 "00000000000",
		 "10010010000",	-- I
		 "11011100000",	-- n
		 "11001100000",	-- f
		 "11011110000" 	-- o
		 ----------------------
	 );
	
	--SIGNAL char_counter		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0000";
	SIGNAL char_code			: STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL code_offset		: STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL font_address		: STD_LOGIC_VECTOR(10 downto 0);
	SIGNAL font_data			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL font_bit			: STD_LOGIC;
	
	SIGNAL pos_diff_x			: UNSIGNED(9 downto 0);
	SIGNAL pos_diff_y			: UNSIGNED(9 downto 0);
	
	SIGNAL title_on			: STD_LOGIC;
	SIGNAL opt_1_on			: STD_LOGIC;
	SIGNAL opt_2_on			: STD_LOGIC;
	SIGNAL sel_on				: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL menu_center_x		: UNSIGNED(9 DOWNTO 0);
	SIGNAL title_x				: UNSIGNED(9 DOWNTO 0);
	SIGNAL title_y				: UNSIGNED(9 DOWNTO 0);
	SIGNAL opt_1_x				: UNSIGNED(9 DOWNTO 0);
	SIGNAL opt_1_y				: UNSIGNED(9 DOWNTO 0);
	SIGNAL opt_2_x				: UNSIGNED(9 DOWNTO 0);
	SIGNAL opt_2_y				: UNSIGNED(9 DOWNTO 0);
	
	
BEGIN
	menu_color <= COLOR;

	-- process that polls joystick configuration to select menu options
	PROCESS (v_sync, enable)
	BEGIN
		IF (enable = '0') THEN
			menu_lock <= '1';
		ELSE
			IF (RISING_EDGE(v_sync)) THEN
				IF ((joystick_data(0) = '1') AND (menu_option = OPTION_START)) THEN -- buttom press (select menu option)
					menu_lock <= '0';
				ELSIF ((joystick_data(2 DOWNTO 1) = MOV_UP) and (menu_option = OPTION_INFO)) THEN
					menu_option <= OPTION_START;
				ELSIF ((joystick_data(2 DOWNTO 1) = MOV_DOWN) and (menu_option = OPTION_START)) THEN
					menu_option <= OPTION_INFO;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	-- 
	menu_center_x <= (UNSIGNED(menu_max_x) + UNSIGNED(menu_min_x))/2;
	title_y		  <= UNSIGNED(menu_min_y)  + TO_UNSIGNED(20, 10);
	opt_1_y		  <= UNSIGNED(menu_min_y)  + TO_UNSIGNED(120, 10);
	opt_2_y		  <= opt_1_y + CHAR_HEIGHT + TO_UNSIGNED(8, 10);
	title_x		  <= menu_center_x - STR_NUM_TITLE*CHAR_WIDTH*FSIZE_TITLE/2;
	opt_1_x		  <= menu_center_x - STR_NUM_OPT_1*CHAR_WIDTH/2;
	opt_2_x		  <= menu_center_x - STR_NUM_OPT_1*CHAR_WIDTH/2;
	
	title_on <=
		'1' WHEN	(STD_LOGIC_VECTOR(menu_center_x - STR_NUM_TITLE*CHAR_WIDTH*FSIZE_TITLE/2) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(menu_center_x + STR_NUM_TITLE*CHAR_WIDTH*FSIZE_TITLE/2 - 1)) AND
					(STD_LOGIC_VECTOR(title_y) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(title_y + CHAR_HEIGHT*FSIZE_TITLE - 1)) ELSE
		'0';
		
	opt_1_on <=
		'1' WHEN	(STD_LOGIC_VECTOR(menu_center_x - STR_NUM_OPT_1*CHAR_WIDTH/2) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(menu_center_x + STR_NUM_OPT_1*CHAR_WIDTH/2 - 1)) AND
					(STD_LOGIC_VECTOR(opt_1_y) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(opt_1_y + CHAR_HEIGHT - 1)) ELSE
		'0';
		
	opt_2_on <=
		'1' WHEN	(STD_LOGIC_VECTOR(menu_center_x - STR_NUM_OPT_2*CHAR_WIDTH/2) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(menu_center_x + STR_NUM_OPT_2*CHAR_WIDTH/2 - 1)) AND
					(STD_LOGIC_VECTOR(opt_2_y) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(opt_2_y + CHAR_HEIGHT - 1)) ELSE
		'0';
			
	-- combinational mux of pos_diff_x, pos_diff_y, char_code and font_address
	sel_on <= title_on & opt_1_on & opt_2_on; 
	
	WITH (sel_on) SELECT
		pos_diff_x <= 		(UNSIGNED(pixel_x) - title_x) WHEN "100",
								(UNSIGNED(pixel_x) - opt_1_x) WHEN "010",
								(UNSIGNED(pixel_x) - opt_2_x)	WHEN "001",
								(OTHERS => '0') WHEN OTHERS;
							
	WITH (sel_on) SELECT
		pos_diff_y <= 		(UNSIGNED(pixel_y) - title_y) WHEN "100",
								(UNSIGNED(pixel_y) - opt_1_y) WHEN "010",
								(UNSIGNED(pixel_y) - opt_2_y)	WHEN "001",
								(OTHERS => '0') WHEN OTHERS;
							
	WITH (sel_on) SELECT
		char_code <= 		ROM_MENU(TO_INTEGER(pos_diff_x(8 DOWNTO 4))) 											WHEN "100",
								ROM_MENU(TO_INTEGER(pos_diff_x(7 DOWNTO 3) + STR_NUM_TITLE)) 						WHEN "010",
								ROM_MENU(TO_INTEGER(pos_diff_x(7 DOWNTO 3) + STR_NUM_TITLE + STR_NUM_OPT_1)) 	WHEN "001",
								(OTHERS => '0') WHEN OTHERS;
								
	code_offset <= "00100000000" WHEN ((pos_diff_x(7 DOWNTO 3) = "00000") AND 
												 (	((sel_on = "010") AND (menu_option = OPTION_START)) OR
													((sel_on = "001") AND (menu_option = OPTION_INFO)))) ELSE
						"00000000000";

	WITH (sel_on) SELECT
		font_address <=	STD_LOGIC_VECTOR(('0' & pos_diff_y(4 DOWNTO 1)) + UNSIGNED(char_code))					 				WHEN "100",
								STD_LOGIC_VECTOR(('0' & pos_diff_y(3 DOWNTO 0)) + UNSIGNED(char_code) + UNSIGNED(code_offset)) 	WHEN "010",
								STD_LOGIC_VECTOR(('0' & pos_diff_y(3 DOWNTO 0)) + UNSIGNED(char_code) + UNSIGNED(code_offset)) 	WHEN "001",
								(OTHERS => '0') WHEN OTHERS;
								
	WITH (sel_on) SELECT
		font_bit <= 		font_data(7 - TO_INTEGER(pos_diff_x(3 DOWNTO 1))) WHEN "100",
								font_data(7 - TO_INTEGER(pos_diff_x(2 DOWNTO 0))) WHEN "010",
								font_data(7 - TO_INTEGER(pos_diff_x(2 DOWNTO 0))) WHEN "001",
								'0' WHEN OTHERS;
	
	-- create font entity
	F : ENTITY work.font_rom 	PORT MAP (	clk25,
														font_address,
														font_data);

	-- reads the pixel value based on the current position / char to use

	

	-- menu border definition
	outer_menu_on <= 
		'1' WHEN (menu_min_x <= pixel_x) AND (pixel_x <= menu_max_x) AND
					(menu_min_y <= pixel_y) AND (pixel_y <= menu_max_y) ELSE
		'0';
		
	inner_menu_on <= 
		'1' WHEN NOT ((STD_LOGIC_VECTOR(UNSIGNED(menu_min_x) + MENU_THICKNESS) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(UNSIGNED(menu_max_x) - MENU_THICKNESS)) AND
						  (STD_LOGIC_VECTOR(UNSIGNED(menu_min_y) + MENU_THICKNESS) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(UNSIGNED(menu_max_y) - MENU_THICKNESS))) ELSE
		'0';
		
	-- bit that turns on every menu character and border
	menu_on <= 
		'1' WHEN ((enable = '1') AND 
					(	((outer_menu_on = '1') AND (inner_menu_on = '1')) OR 
						(	(font_bit = '1') AND 
							((title_on = '1') OR (opt_1_on = '1') OR (opt_2_on = '1'))))) ELSE -- AND (font_bit = '1')) ELSE
		'0';
--	menu_on <= 
--		'1' WHEN ((enable = '1') AND (((outer_menu_on = '1') AND (inner_menu_on = '1')) OR (title_on = '1') OR (opt_1_on = '1') OR (opt_2_on = '1'))) ELSE -- AND (font_bit = '1')) ELSE
--		'0';
	
END behave;