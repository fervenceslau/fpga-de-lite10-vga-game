LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY ball_generator IS
	PORT 
	(	
		clkrtc		: IN  STD_LOGIC;								-- real time clock (1 Hz)
		v_sync		: IN  STD_LOGIC;
		rst 		  	: IN  STD_LOGIC;
		game_over	: IN	STD_LOGIC;
		min_x			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	-- minimum allowed positions
		max_x			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	
		min_y			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	-- maximum allowed positions
		max_y			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	
		pixel_x		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pixel_y		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		player_x		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		player_y		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		ball_on  	: OUT STD_LOGIC;
		ball_color	: OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := X"F00"
	);
END ball_generator;

ARCHITECTURE arch OF ball_generator IS

	CONSTANT BALL_SIZE		:	UNSIGNED (9 DOWNTO 0)				:= TO_UNSIGNED(8, 10);

	CONSTANT STATE_BALL_1	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0000";
	CONSTANT STATE_BALL_2	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0001";
	CONSTANT STATE_BALL_3	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0010";
	CONSTANT STATE_BALL_4	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0011";
	CONSTANT STATE_BALL_5	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0100";
	CONSTANT STATE_BALL_6	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0101";
	CONSTANT STATE_BALL_7	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0110";
	CONSTANT STATE_BALL_8	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0111";
	CONSTANT STATE_BALL_9	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "1000";
	CONSTANT STATE_BALL_10	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "1001";
	
	SIGNAL state				:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= STATE_BALL_1;
	SIGNAL time_counter		:	INTEGER									:= 0;
	SIGNAL ball_enable_vec	:	STD_LOGIC_VECTOR (15 DOWNTO 0)	:= X"0000";
	SIGNAL ball_on_vec		:	STD_LOGIC_VECTOR (15 DOWNTO 0)	:= X"0000";
	
	SIGNAL step_x				:	UNSIGNED (9 DOWNTO 0);
	SIGNAL step_y				:  UNSIGNED (9 DOWNTO 0);
	
	SIGNAL x_pos_1				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL x_pos_2				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL x_pos_3				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL x_pos_4				:	UNSIGNED (19 DOWNTO 0);
	
	SIGNAL y_pos_1				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL y_pos_2				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL y_pos_3				:	UNSIGNED (19 DOWNTO 0);
	SIGNAL y_pos_4				:	UNSIGNED (19 DOWNTO 0);
	
	SIGNAL speed_mult			:	STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
	
BEGIN

	step_x  <= (UNSIGNED(max_x) - UNSIGNED(min_x))/8;
	step_y  <= (UNSIGNED(max_y) - UNSIGNED(min_y))/8;
	x_pos_1 <= UNSIGNED(min_x) + 1*step_x;
	x_pos_2 <= UNSIGNED(min_x) + 3*step_x;
	x_pos_3 <= UNSIGNED(min_x) + 5*step_x;
	x_pos_4 <= UNSIGNED(min_x) + 7*step_x;
	y_pos_1 <= UNSIGNED(min_y) + 1*step_y;
	y_pos_2 <= UNSIGNED(min_y) + 3*step_y;
	y_pos_3 <= UNSIGNED(min_y) + 5*step_y;
	y_pos_4 <= UNSIGNED(min_y) + 7*step_y;

	PROCESS(clkrtc)
	BEGIN
		IF (rst = '1') THEN
			time_counter <= 0;
			speed_mult	 <= "000";
		ELSIF (RISING_EDGE(clkrtc)) THEN
			IF (game_over = '0') THEN
				time_counter <= time_counter + 1;
				IF (time_counter < 6) THEN
					speed_mult <= "000";
				ELSIF (time_counter < 22) THEN
					speed_mult <= "001";
				ELSIF (time_counter < 78) THEN
					speed_mult <= "010";
				ELSE
					speed_mult <= "011";
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	ball_enable_vec(0)  <= '1' WHEN (time_counter >= 1) ELSE '0';
	ball_enable_vec(1)  <= '1' WHEN (time_counter >= 3) ELSE '0';
	ball_enable_vec(2)  <= '1' WHEN (time_counter >= 5) ELSE '0';
	ball_enable_vec(3)  <= '1' WHEN (time_counter >= 7) ELSE '0';
	
	ball_enable_vec(4)  <= '1' WHEN (time_counter >= 11) ELSE '0';
	ball_enable_vec(5)  <= '1' WHEN (time_counter >= 15) ELSE '0';
	ball_enable_vec(6)  <= '1' WHEN (time_counter >= 19) ELSE '0';
	ball_enable_vec(7)  <= '1' WHEN (time_counter >= 23) ELSE '0';
	
	ball_enable_vec(8)  <= '1' WHEN (time_counter >= 29) ELSE '0';
	ball_enable_vec(9)  <= '1' WHEN (time_counter >= 35) ELSE '0';
	ball_enable_vec(10) <= '1' WHEN (time_counter >= 41) ELSE '0';
	ball_enable_vec(11) <= '1' WHEN (time_counter >= 47) ELSE '0';
	
	ball_enable_vec(12) <= '1' WHEN (time_counter >= 55) ELSE '0';
	ball_enable_vec(13) <= '1' WHEN (time_counter >= 63) ELSE '0';
	ball_enable_vec(14) <= '1' WHEN (time_counter >= 71) ELSE '0';
	ball_enable_vec(15) <= '1' WHEN (time_counter >= 79) ELSE '0';
		
	ball_on <=
		'0' WHEN ((ball_on_vec = X"0000") OR (rst = '1')) ELSE
		'1';
	
	-- TOP BALLS
	B0 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(0),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_1(9 DOWNTO 0)),
													min_y,
													speed_mult,
													ball_on_vec(0));

	B1 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(1),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_2(9 DOWNTO 0)),
													min_y,
													speed_mult,
													ball_on_vec(1));

	B2 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(2),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_3(9 DOWNTO 0)),
													min_y,
													speed_mult,
													ball_on_vec(2));
													
	B3 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(3),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_4(9 DOWNTO 0)),
													min_y,
													speed_mult,
													ball_on_vec(3));
													
	-- RIGHT BALLS
	B4 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(4),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(UNSIGNED(max_x) - BALL_SIZE + 1),
													STD_LOGIC_VECTOR(y_pos_1(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(4));

	B5 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(5),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(UNSIGNED(max_x) - BALL_SIZE + 1),
													STD_LOGIC_VECTOR(y_pos_2(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(5));

	B6 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(6),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(UNSIGNED(max_x) - BALL_SIZE + 1),
													STD_LOGIC_VECTOR(y_pos_3(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(6));
													
	B7 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(7),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(UNSIGNED(max_x) - BALL_SIZE + 1),
													STD_LOGIC_VECTOR(y_pos_4(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(7));

	-- BOTTOM BALLS
	B8 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(8),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_1(9 DOWNTO 0)),
													STD_LOGIC_VECTOR(UNSIGNED(max_y) - BALL_SIZE + 1),
													speed_mult,
													ball_on_vec(8));

	B9 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(9),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_2(9 DOWNTO 0)),
													STD_LOGIC_VECTOR(UNSIGNED(max_y) - BALL_SIZE + 1),
													speed_mult,
													ball_on_vec(9));

	B10 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(10),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_3(9 DOWNTO 0)),
													STD_LOGIC_VECTOR(UNSIGNED(max_y) - BALL_SIZE + 1),
													speed_mult,
													ball_on_vec(10));
													
	B11 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(11),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													STD_LOGIC_VECTOR(x_pos_4(9 DOWNTO 0)),
													STD_LOGIC_VECTOR(UNSIGNED(max_y) - BALL_SIZE + 1),
													speed_mult,
													ball_on_vec(11));
													
	-- LEFT BALLS
	B12 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(12),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													min_x,
													STD_LOGIC_VECTOR(y_pos_1(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(12));

	B13 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(13),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													min_x,
													STD_LOGIC_VECTOR(y_pos_2(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(13));

	B14 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(14),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													min_x,
													STD_LOGIC_VECTOR(y_pos_3(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(14));
													
	B15 : ENTITY work.ball	PORT MAP	(	v_sync,
													ball_enable_vec(15),
													game_over,
													min_x,
													max_x,
													min_y,
													max_y,
													pixel_x,
													pixel_y,
													player_x,
													player_y,
													min_x,
													STD_LOGIC_VECTOR(y_pos_4(9 DOWNTO 0)),
													speed_mult,
													ball_on_vec(15));

END arch;