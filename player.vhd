LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY player IS
	PORT 
	(	
		rst 		  		: IN  STD_LOGIC;
		v_sync			: IN  STD_LOGIC;
		game_over		: IN	STD_LOGIC;
		min_x				: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	-- minimum allowed player positions
		max_x				: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	
		min_y				: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	-- maximum allowed player positions
		max_y				: IN  STD_LOGIC_VECTOR (9  DOWNTO 0);	
		pixel_x			: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		pixel_y			: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		joystick_data	: IN	STD_LOGIC_VECTOR (4  DOWNTO 0);	-- mov_x & mov_y & btn_press
		player_x			: OUT	STD_LOGIC_VECTOR (9  DOWNTO 0);
		player_y			: OUT	STD_LOGIC_VECTOR (9  DOWNTO 0);
		player_on  		: OUT STD_LOGIC;
		player_color	: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
END player;

ARCHITECTURE behave OF player IS

	-- constants - player info
	CONSTANT COLOR				:	STD_LOGIC_VECTOR (11 DOWNTO 0) 	:= "111111111111";
	CONSTANT	PLAYER_SIZE		:	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(16, 10);
	CONSTANT MOV_SPEED		:	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(4, 10);
	CONSTANT MOV_DEC			:	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(1, 10);
	
	-- constants - movement combinations (joystick positions)
	CONSTANT MOV_LEFT			:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "1000";
	CONSTANT MOV_RIGHT		:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "0100";
	CONSTANT MOV_UP			:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "0010";
	CONSTANT MOV_DOWN			:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "0001";
	CONSTANT MOV_LEFT_UP		:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "1010";
	CONSTANT MOV_LEFT_DOWN	:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "1001";
	CONSTANT MOV_RIGHT_UP	:	STD_LOGIC_VECTOR (3 DOWNTO 0) 	:= "0110";
	CONSTANT MOV_RIGHT_DOWN	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0101";
	
	
	-- player position and limits
	SIGNAL 	pos_x_l			:	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(316, 10);
	SIGNAL 	pos_y_t			:	UNSIGNED (9 DOWNTO 0) 				:= TO_UNSIGNED(258, 10);
	SIGNAL 	pos_min_x		:	UNSIGNED (9 DOWNTO 0);
	SIGNAL 	pos_max_x		:	UNSIGNED (9 DOWNTO 0);
	SIGNAL 	pos_min_y		:	UNSIGNED (9 DOWNTO 0);
	SIGNAL 	pos_max_y		:	UNSIGNED (9 DOWNTO 0);

	-- player states
	SIGNAL 	movement			:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL	mov_x 	  		:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL	mov_y 	  		:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL	btn_press		:	STD_LOGIC;
	SIGNAL	graph_on			:	STD_LOGIC;

BEGIN
	-- assing color to player
	player_color <= COLOR;

	-- converts input limits to unsigned
	pos_min_x <= UNSIGNED(min_x);
	pos_max_x <= UNSIGNED(max_x) - PLAYER_SIZE + 1;
	pos_min_y <= UNSIGNED(min_y);
	pos_max_y <= UNSIGNED(max_y) - PLAYER_SIZE + 1;

	-- outputs player positions as std_logic_vector
	player_x <= STD_LOGIC_VECTOR(pos_x_l);
	player_y <= STD_LOGIC_VECTOR(pos_y_t);

	-- read movement from joystick
	movement <= joystick_data(4 DOWNTO 1);
																		
	-- instantiate player's disk graph
	player_graph : ENTITY WORK.disk_graph	PORT MAP (	'0' & pixel_x(9 DOWNTO 1),
																		'0' & pixel_y(9 DOWNTO 1),
																		STD_LOGIC_VECTOR('0' & pos_x_l(9 DOWNTO 1)),
																		STD_LOGIC_VECTOR('0' & pos_y_t(9 DOWNTO 1)),
																		graph_on);
																		
	player_on <= 
		'1' WHEN ((graph_on = '1') AND (rst = '0')) ELSE
		'0';
	
	-- process movement and update position according to movement vector
	PROCESS(v_sync, rst)
	BEGIN
		IF (rst = '1') THEN
				pos_x_l <= TO_UNSIGNED(316, 10);
				pos_y_t <= TO_UNSIGNED(258, 10);
		ELSIF (RISING_EDGE(v_sync)) THEN
			IF (game_over = '0') THEN
				CASE movement IS
					WHEN MOV_LEFT =>
						IF (pos_x_l <= (pos_min_x + MOV_SPEED)) THEN
							pos_x_l <= pos_min_x; 
						ELSE
							pos_x_l <= pos_x_l - MOV_SPEED;
						END IF;
					WHEN MOV_RIGHT =>
						IF (pos_x_l >= (pos_max_x - MOV_SPEED)) THEN
							pos_x_l <= pos_max_x;
						ELSE
							pos_x_l <= pos_x_l + MOV_SPEED;
						END IF;				
					WHEN MOV_UP =>
						IF (pos_y_t <= (pos_min_y + MOV_SPEED)) THEN
							pos_y_t <= pos_min_y; 
						ELSE
							pos_y_t <= pos_y_t - MOV_SPEED;
						END IF;
					WHEN MOV_DOWN =>
						IF (pos_y_t >= (pos_max_y - MOV_SPEED)) THEN
							pos_y_t <= pos_max_y;
						ELSE
							pos_y_t <= pos_y_t + MOV_SPEED;
						END IF;
					WHEN MOV_LEFT_UP =>
						IF (pos_x_l <= (pos_min_x + MOV_SPEED - MOV_DEC)) THEN
							pos_x_l <= pos_min_x; 
						ELSE
							pos_x_l <= pos_x_l - MOV_SPEED + MOV_DEC;
						END IF;
						IF (pos_y_t <= (pos_min_y + MOV_SPEED - MOV_DEC)) THEN
							pos_y_t <= pos_min_y; 
						ELSE
							pos_y_t <= pos_y_t - MOV_SPEED + MOV_DEC;
						END IF;
					WHEN MOV_LEFT_DOWN =>
						IF (pos_x_l <= (pos_min_x + MOV_SPEED - MOV_DEC)) THEN
							pos_x_l <= pos_min_x; 
						ELSE
							pos_x_l <= pos_x_l - MOV_SPEED + MOV_DEC;
						END IF;
						IF (pos_y_t >= (pos_max_y  - MOV_SPEED + MOV_DEC)) THEN
							pos_y_t <= pos_max_y;
						ELSE
							pos_y_t <= pos_y_t + MOV_SPEED - MOV_DEC;
						END IF;
					WHEN MOV_RIGHT_UP =>
						IF (pos_x_l >= (pos_max_x - MOV_SPEED + MOV_DEC)) THEN
							pos_x_l <= pos_max_x;
						ELSE
							pos_x_l <= pos_x_l + MOV_SPEED - MOV_DEC;
						END IF;
						IF (pos_y_t <= (pos_min_y + MOV_SPEED - MOV_DEC)) THEN
							pos_y_t <= pos_min_y; 
						ELSE
							pos_y_t <= pos_y_t - MOV_SPEED + MOV_DEC;
						END IF;
					WHEN MOV_RIGHT_DOWN =>
						IF (pos_x_l >= (pos_max_x - MOV_SPEED + MOV_DEC)) THEN
							pos_x_l <= pos_max_x;
						ELSE
							pos_x_l <= pos_x_l + MOV_SPEED - MOV_DEC;
						END IF;
						IF (pos_y_t >= (pos_max_y - MOV_SPEED + MOV_DEC)) THEN
							pos_y_t <= pos_max_y;
						ELSE
							pos_y_t <= pos_y_t + MOV_SPEED - MOV_DEC;
						END IF;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
		
END behave;