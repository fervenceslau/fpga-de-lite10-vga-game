LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY vga_dodge_game IS
	PORT 
	(	
		clk50 	: IN  STD_LOGIC; 	-- 50 MHZ
		rst_main : IN  STD_LOGIC;
		h_sync	: OUT STD_LOGIC;
		v_sync	: OUT STD_LOGIC;
		rgb		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		d_sw 		: IN	STD_LOGIC_VECTOR (2 DOWNTO 0);
		d_led		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
END vga_dodge_game;

ARCHITECTURE behave OF vga_dodge_game IS

	-- constants - screen information
	CONSTANT SCREEN_OFFSET	:	UNSIGNED (9 DOWNTO 0)				:=	TO_UNSIGNED(8,   10);	-- offset used to make screen smaller and not interfere with vga drive
	CONSTANT SCREEN_MAX_X	: 	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(640, 10);
	CONSTANT SCREEN_MAX_Y	: 	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(480, 10);
	CONSTANT BORDER_SIZE		:	UNSIGNED (9 DOWNTO 0)				:=	TO_UNSIGNED(8,   10);
	
	-- constants - game states
	CONSTANT STATE_MENU		:	STD_LOGIC_VECTOR (2 DOWNTO 0)		:=	"000";
	CONSTANT STATE_RUN		:	STD_LOGIC_VECTOR (2 DOWNTO 0)		:=	"001";
	CONSTANT STATE_END		:	STD_LOGIC_VECTOR (2 DOWNTO 0)		:=	"010";
	
	-- constants - playable area will be (500 x 420), not counting the border sizes
	CONSTANT PLAY_SIZE_X		:	UNSIGNED (9 DOWNTO 0)				:=	TO_UNSIGNED(500,   10);
	CONSTANT PLAY_SIZE_Y		:	UNSIGNED (9 DOWNTO 0)				:=	TO_UNSIGNED(420,   10);
	CONSTANT PLAY_MIN_X		:	UNSIGNED (9 DOWNTO 0)				:=	(SCREEN_MAX_X - PLAY_SIZE_X)/2;
	CONSTANT PLAY_MIN_Y		:	UNSIGNED (9 DOWNTO 0)				:=	(SCREEN_MAX_Y - PLAY_SIZE_Y - SCREEN_OFFSET);
	CONSTANT PLAY_MAX_X		:	UNSIGNED (9 DOWNTO 0)				:=	PLAY_MIN_X + PLAY_SIZE_X - 1;
	CONSTANT PLAY_MAX_Y		:	UNSIGNED (9 DOWNTO 0)				:=	PLAY_MIN_Y + PLAY_SIZE_Y - 1;
	
	-- constants - colors
	CONSTANT COLOR_BORDER	:	STD_LOGIC_VECTOR (11 DOWNTO 0)	:=	"111111111111";
	CONSTANT COLOR_PLAYER	:	STD_LOGIC_VECTOR (11 DOWNTO 0)	:=	"111111111111";
	CONSTANT COLOR_BALL_1	:	STD_LOGIC_VECTOR (11 DOWNTO 0)	:=	"111100000000";
	
	-- constants - HUD positions
	CONSTANT MENU_MIN_X		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(220, 10);
	CONSTANT MENU_MAX_X		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(420, 10);
	CONSTANT MENU_MIN_Y		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(162, 10);
	CONSTANT MENU_MAX_Y		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(362, 10);
	CONSTANT	TIMER_MIN_x		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(264, 10);
	CONSTANT	TIMER_MIN_Y		:	UNSIGNED(9 DOWNTO 0)					:=	PLAY_MIN_Y - 16;
	CONSTANT	SCORE_MIN_x		:	UNSIGNED(9 DOWNTO 0)					:=	TO_UNSIGNED(450, 10);
	CONSTANT	SCORE_MIN_Y		:	UNSIGNED(9 DOWNTO 0)					:=	TIMER_MIN_Y;
	
	-- constant - RTC max
	CONSTANT	RTC_MAX_COUNT	:	INTEGER									:= 25000000;
	
	SIGNAL clk_counter		:	INTEGER									:= 0;
	SIGNAL clkrtc				:	STD_LOGIC								:= '0';
	SIGNAL clk25				:	STD_LOGIC								:= '0';

	SIGNAL game_state			:  STD_LOGIC_VECTOR (2 DOWNTO 0)		:= STATE_MENU;
	SIGNAL rst_game			:	STD_LOGIC								:= '0';
	
	SIGNAL enable_menu		:	STD_LOGIC								:= '1';
	SIGNAL menu_lock			:	STD_LOGIC								:= '1';
	SIGNAL menu_on				:	STD_LOGIC;
	SIGNAL menu_color			:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	
	SIGNAL joystick_data		:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	
	SIGNAL pixel_x				:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL pixel_y				:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL player_x			:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL player_y			:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	
	SIGNAL v_sync_buffer		:	STD_LOGIC;
	SIGNAL player_on			:	STD_LOGIC;
	SIGNAL player_color		:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	
	SIGNAL timer_on			:	STD_LOGIC;
	SIGNAL timer_color		:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	SIGNAL score_on			:	STD_LOGIC;
	SIGNAL score_color		:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	
	SIGNAL ball_on				:	STD_LOGIC;
	SIGNAL ball_color			:	STD_LOGIC_VECTOR (11 DOWNTO 0);
	
	SIGNAL screen_on			:	STD_LOGIC;
	SIGNAL border_on			:	STD_LOGIC;
	
	SIGNAL game_over			:	STD_LOGIC := '0';
	
BEGIN
	v_sync <= v_sync_buffer;
	
	-- process that generates RTC and 25 MHz clocks
	clk_div : PROCESS (clk50)
	BEGIN
		IF (RISING_EDGE(clk50)) THEN
			clk25 <= NOT clk25;
			IF (clk_counter < RTC_MAX_COUNT) THEN
				clk_counter <= clk_counter + 1;
			ELSE
				clk_counter <= 0;
				clkrtc 		<= NOT clkrtc;
			END IF;
		END IF;
	END PROCESS;

	-- instantiate vga driver
	vga : ENTITY work.vga_driver			PORT MAP (	clk25,
																	rst_main,
																	h_sync,
																	v_sync_buffer,
																	pixel_x,
																	pixel_y);

	menu : ENTITY work.display_menu 		PORT MAP (	clk25,
																	clkrtc,
																	v_sync_buffer,
																	rst_game,
																	enable_menu,
																	joystick_data,
																	pixel_x,
																	pixel_y,
																	STD_LOGIC_VECTOR(MENU_MIN_X),
																	STD_LOGIC_VECTOR(MENU_MAX_X),
																	STD_LOGIC_VECTOR(MENU_MIN_Y),
																	STD_LOGIC_VECTOR(MENU_MAX_Y),
																	menu_lock,
																	menu_color,
																	menu_on);
															
	timer : ENTITY work.display_timer 	PORT MAP (	clk25,
																	clkrtc,
																	rst_game,
																	game_over,
																	STD_LOGIC_VECTOR(PLAY_MIN_X + BORDER_SIZE), -- min_x
																	STD_LOGIC_VECTOR(PLAY_MAX_X - BORDER_SIZE), -- min_y
																	STD_LOGIC_VECTOR(PLAY_MIN_Y + BORDER_SIZE), -- max_x
																	STD_LOGIC_VECTOR(PLAY_MAX_Y - BORDER_SIZE), -- max_y
																	pixel_x,
																	pixel_y,
																	STD_LOGIC_VECTOR(TIMER_MIN_x),
																	STD_LOGIC_VECTOR(TIMER_MIN_Y),
																	timer_color,
																	timer_on);
																
	score : ENTITY work.display_score	PORT MAP (	clk25,
																	clkrtc,
																	rst_game,
																	game_over,
																	STD_LOGIC_VECTOR(PLAY_MIN_X + BORDER_SIZE), -- min_x
																	STD_LOGIC_VECTOR(PLAY_MAX_X - BORDER_SIZE), -- min_y
																	STD_LOGIC_VECTOR(PLAY_MIN_Y + BORDER_SIZE), -- max_x
																	STD_LOGIC_VECTOR(PLAY_MAX_Y - BORDER_SIZE), -- max_y
																	pixel_x,
																	pixel_y,
																	STD_LOGIC_VECTOR(SCORE_MIN_x),
																	STD_LOGIC_VECTOR(SCORE_MIN_Y),
																	score_color,
																	score_on);
	
	-- instantiate joystick
	joy : ENTITY WORK.joystick 			PORT MAP (	clk50,
																	joystick_data);

	-- instantiate player one
	P1 : ENTITY work.player 				PORT MAP	(	rst_game, 
																	v_sync_buffer,
																	game_over,
																	STD_LOGIC_VECTOR(PLAY_MIN_X + BORDER_SIZE), -- min_x
																	STD_LOGIC_VECTOR(PLAY_MAX_X - BORDER_SIZE), -- max_x
																	STD_LOGIC_VECTOR(PLAY_MIN_Y + BORDER_SIZE), -- min_y
																	STD_LOGIC_VECTOR(PLAY_MAX_Y - BORDER_SIZE), -- max_y
																	pixel_x,
																	pixel_y,
																	joystick_data,
																	player_x,
																	player_y,
																	player_on,
																	player_color);

	B : ENTITY work.ball_generator		PORT MAP	(	clkrtc,
																	v_sync_buffer,
																	rst_game,
																	game_over,
																	STD_LOGIC_VECTOR(PLAY_MIN_X + BORDER_SIZE), -- min_x
																	STD_LOGIC_VECTOR(PLAY_MAX_X - BORDER_SIZE), -- max_x
																	STD_LOGIC_VECTOR(PLAY_MIN_Y + BORDER_SIZE), -- min_y
																	STD_LOGIC_VECTOR(PLAY_MAX_Y - BORDER_SIZE), -- max_y
																	pixel_x,
																	pixel_y,
																	player_x,
																	player_y,
																	ball_on,
																	ball_color);
	
	screen_on <= 
		'1' WHEN (STD_LOGIC_VECTOR(PLAY_MIN_X) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(PLAY_MAX_X)) AND
					(STD_LOGIC_VECTOR(PLAY_MIN_Y) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(PLAY_MAX_Y)) ELSE
		'0';
		
	border_on <= 
		'1' WHEN (screen_on = '1') AND 
					NOT ((STD_LOGIC_VECTOR(PLAY_MIN_X + BORDER_SIZE) <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(PLAY_MAX_X - BORDER_SIZE)) AND
						  (STD_LOGIC_VECTOR(PLAY_MIN_Y + BORDER_SIZE) <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(PLAY_MAX_Y - BORDER_SIZE))) ELSE
		'0';
				
	PROCESS (clk25, rst_main)
	BEGIN
		IF (RISING_EDGE(clk25)) THEN
			IF (rst_main = '1') THEN
				rst_game    <= '1';
				enable_menu <= '1';
				game_over	<= '0';
				game_state  <= STATE_MENU;
			ELSE
				IF 	(border_on 	= '1') THEN		rgb <= COLOR_BORDER;
				ELSIF (timer_on 	= '1') THEN		rgb <= timer_color;
				ELSIF (score_on 	= '1') THEN		rgb <= score_color;
				ELSIF (menu_on 	= '1') THEN		rgb <= menu_color;
				ELSIF (player_on 	= '1') THEN		rgb <= player_color;
				ELSIF (ball_on 	= '1') THEN		rgb <= ball_color;
				ELSE										rgb <= (OTHERS => '0');
				END IF;
			
				CASE game_state IS
					WHEN STATE_MENU =>
						IF (menu_lock = '0') THEN
							rst_game 	<= '0';
							enable_menu <= '0';
							game_state 	<= STATE_RUN;
						ELSE
							rst_game <= '1';
						END IF;
						
					WHEN STATE_RUN =>
							rst_game   <= '0';
						IF ((player_on = '1') AND (ball_on = '1')) THEN
							game_over  <= '1';
							game_state <= STATE_END;
						END IF;
					WHEN STATE_END => 
						IF (joystick_data(0) = '1') THEN
							rst_game   <= '1';
							game_over  <= '0';
							game_state <= STATE_RUN;
						END IF;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
									
--	-- draw objects on the screen
--	PROCESS(game_state, pixel_x, pixel_y, border_on, timer_on, player_on)
--	BEGIN
--		IF (game_state = STATE_MENU) THEN
--			rst_game <= '1';
--			IF 	(border_on 	= '1') THEN		rgb <= COLOR_BORDER;
--			ELSIF (timer_on 	= '1') THEN		rgb <= timer_color;
--			ELSIF (score_on 	= '1') THEN		rgb <= score_color;
--			ELSIF (menu_on 	= '1') THEN		rgb <= menu_color;
--			END IF;
--		ELSE
--			
--		END IF;
--	
----		IF (border_on = '1') THEN
----			rgb <= COLOR_BORDER;
----		ELSIF (timer_on = '1') THEN
----			rgb <= timer_color;
----		ELSIF (score_on = '1') THEN
----			rgb <= score_color;
----		ELSIF (player_on = '1') THEN
----			rgb <= player_color;
----		ELSIF (ball_on = '1' OR ball_on_2 = '1' OR ball_on_3 = '1' OR ball_on_4 = '1') THEN
----			rgb <= COLOR_BALL_1;
----		ELSE
----			rgb <= (OTHERS => '0');
----		END IF;
--	END PROCESS;

END behave;


 