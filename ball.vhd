LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY ball IS
	PORT 
	(	
		v_sync			: IN  STD_LOGIC;
		enable	  		: IN  STD_LOGIC;
		game_over		: IN 	STD_LOGIC;
		min_x				: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	-- minimum allowed positions
		max_x				: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	
		min_y				: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	-- maximum allowed positions
		max_y				: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);	
		pixel_x			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pixel_y			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		player_x			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		player_y			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		init_pos_x		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		init_pos_y		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		speed_mult		: IN	STD_LOGIC_VECTOR (2 DOWNTO 0);
		ball_on  		: OUT STD_LOGIC
	);
END ball;

ARCHITECTURE behave OF ball IS

	-- constants - player info
	CONSTANT	BALL_SIZE			:	UNSIGNED (15 DOWNTO 0) 				:= TO_UNSIGNED(8*64,  16);
	CONSTANT MAX_BOUNCE			:	INTEGER									:= 1;
	CONSTANT COLLISION_NONE		:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0000";
	CONSTANT COLLISION_LEFT		:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "1000";
	CONSTANT COLLISION_RIGHT	:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0100";
	CONSTANT COLLISION_TOP		:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0010";
	CONSTANT COLLISION_DOWN		:	STD_LOGIC_VECTOR (3 DOWNTO 0)		:= "0001";
	
	CONSTANT RESPAWN_RNG_VAL	:	STD_LOGIC_VECTOR (31 DOWNTO 0)	:= X"01000000";

	-- BALL position and velocity
	SIGNAL pixel_on				:	STD_LOGIC							:= '0';
	SIGNAL pos_x_l					:	UNSIGNED (15 DOWNTO 0);
	SIGNAL pos_y_t					:	UNSIGNED (15 DOWNTO 0);
	SIGNAL speed_x					:	UNSIGNED (15 DOWNTO 0);
	SIGNAL speed_y					:	UNSIGNED (15 DOWNTO 0);
	SIGNAL speed_dir_x			:	STD_LOGIC;
	SIGNAL speed_dir_y			:	STD_LOGIC;
	SIGNAL bounce_counter		:	INTEGER 								:= 0;
	SIGNAL ball_collision		:	STD_LOGIC_VECTOR (3 DOWNTO 0)	:= COLLISION_NONE;
	
	SIGNAL rom_addr_x				:	UNSIGNED (2 DOWNTO 0);
	SIGNAL rom_addr_y				:	UNSIGNED (2 DOWNTO 0);
	SIGNAL aux_speed_x			:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL aux_speed_y			:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	
	SIGNAL sel_x					:	STD_LOGIC;
	SIGNAL sel_y					:	STD_LOGIC;
	
	SIGNAL rng_val					:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	
BEGIN
	ball_on <=
		'1' WHEN ((enable = '1') AND (pixel_on = '1') AND (bounce_counter < MAX_BOUNCE)) ELSE
		'0';
		
	RNG : ENTITY work.xorshift32					PORT MAP	(	v_sync,
																			'0',
																			(init_pos_x & init_pos_y & X"000"), -- RNG seed, can be anything /= 0
																			rng_val);
	
	ball_graph : ENTITY WORK.disk_graph			PORT MAP (	pixel_x,
																			pixel_y,
																			STD_LOGIC_VECTOR(pos_x_l(15 DOWNTO 6)),
																			STD_LOGIC_VECTOR(pos_y_t(15 DOWNTO 6)),
																			pixel_on);
																		
	ball_speed : ENTITY WORK.ball_speed_rom	PORT MAP (	STD_LOGIC_VECTOR(rom_addr_x),
																			STD_LOGIC_VECTOR(rom_addr_y),
																			aux_speed_x,
																			aux_speed_y);
	sel_x <=  '1' WHEN (player_x >= init_pos_x) ELSE '0';
	WITH (sel_x) SELECT
	rom_addr_x <= 		(UNSIGNED(player_x(8 DOWNTO 6))   - UNSIGNED(init_pos_x(8 DOWNTO 6))) 	WHEN '1',
							(UNSIGNED(init_pos_x(8 DOWNTO 6)) - UNSIGNED(player_x(8 DOWNTO 6)))		WHEN '0',
							(OTHERS => '0') WHEN OTHERS;
	
	sel_y <=  '1' WHEN (player_y >= init_pos_y) ELSE '0';
	WITH (sel_y) SELECT
	rom_addr_y <= 		(UNSIGNED(player_y(8 DOWNTO 6))   - UNSIGNED(init_pos_y(8 DOWNTO 6))) 	WHEN '1',
							(UNSIGNED(init_pos_y(8 DOWNTO 6)) - UNSIGNED(player_y(8 DOWNTO 6)))		WHEN '0',
							(OTHERS => '0') WHEN OTHERS;
																		
																		
--	ball_collision <=
--		COLLISION_LEFT 	WHEN ((enable = '1') AND (speed_dir_x = '0') AND (pos_x_l(15 DOWNTO 6) <= (UNSIGNED(min_x) + speed_x(15 DOWNTO 6)))) 						ELSE
--		COLLISION_RIGHT	WHEN ((enable = '1') AND (speed_dir_x = '1') AND (pos_x_l(15 DOWNTO 6) >= (UNSIGNED(max_x) - speed_x(15 DOWNTO 6) - BALL_SIZE + 1))) 	ELSE
--		COLLISION_TOP 		WHEN ((enable = '1') AND (speed_dir_y = '0') AND (pos_y_t(15 DOWNTO 6) <= (UNSIGNED(min_y) + speed_y(15 DOWNTO 6))))							ELSE
--		COLLISION_DOWN		WHEN ((enable = '1') AND (speed_dir_y = '1') AND (pos_y_t(15 DOWNTO 6) >= (UNSIGNED(max_y) - speed_y(15 DOWNTO 6) - BALL_SIZE + 1))) 	ELSE
--		COLLISION_NONE;
--																		
	-- 
	PROCESS (v_sync, enable)
	BEGIN
		IF (RISING_EDGE(v_sync)) THEN
			IF (game_over = '0') THEN
				IF ((enable = '0') OR ((bounce_counter >= MAX_BOUNCE) AND (rng_val <= RESPAWN_RNG_VAL))) THEN
					pos_x_l			<= UNSIGNED(init_pos_x) & "000000";
					pos_y_t			<= UNSIGNED(init_pos_y) & "000000";
					bounce_counter <= 0;
					CASE speed_mult IS
						WHEN "000" => 
							speed_x <= UNSIGNED("000000000"  & aux_speed_x & '0');
							speed_y <= UNSIGNED("000000000"  & aux_speed_y & '0');
						WHEN "001" =>
							speed_x <= UNSIGNED("00000000"   & aux_speed_x & "00");
							speed_y <= UNSIGNED("00000000"   & aux_speed_y & "00");
						WHEN "010" =>
							speed_x <= UNSIGNED("0000000"   	& aux_speed_x & "000");
							speed_y <= UNSIGNED("0000000"    & aux_speed_y & "000");
						WHEN "011" =>
							speed_x <= UNSIGNED("000000"   	& aux_speed_x & "0000");
							speed_y <= UNSIGNED("000000"   	& aux_speed_y & "0000");
						WHEN OTHERS => NULL;
					END CASE;
					IF (player_x >= init_pos_x) THEN
						--rom_addr_x 	<= UNSIGNED(player_x(8 DOWNTO 6))   - UNSIGNED(init_pos_x(8 DOWNTO 6));
						speed_dir_x <= '1';
					ELSE
						--rom_addr_x 	<= UNSIGNED(init_pos_x(8 DOWNTO 6)) - UNSIGNED(player_x(8 DOWNTO 6));	-- rom address vel x
						speed_dir_x <= '0';
					END IF;
					IF (player_y >= init_pos_y) THEN
						--rom_addr_y 	<= UNSIGNED(player_y(8 DOWNTO 6))   - UNSIGNED(init_pos_y(8 DOWNTO 6));
						speed_dir_y <= '1';
					ELSE
						--rom_addr_y 	<= UNSIGNED(init_pos_y(8 DOWNTO 6)) - UNSIGNED(player_y(8 DOWNTO 6));	-- rom address vel x
						speed_dir_y <= '0';
					END IF;
				ELSE
					IF ((pos_x_l <= (UNSIGNED(min_x & "000000") + speed_x)) AND (speed_dir_x = '0')) THEN
						pos_x_l 		<= UNSIGNED(min_x & "000000") + UNSIGNED(min_x & "000000") - pos_x_l + speed_x;
						speed_dir_x <= '1';
						bounce_counter <= bounce_counter + 1;
					ELSIF ((pos_x_l >= (UNSIGNED(max_x & "000000") - speed_x - BALL_SIZE + 1*64)) AND (speed_dir_x = '1')) THEN
						pos_x_l 		<= UNSIGNED(max_x & "000000") + UNSIGNED(max_x & "000000") - pos_x_l - speed_x - BALL_SIZE - BALL_SIZE + 2*64;
						speed_dir_x <= '0';
						bounce_counter <= bounce_counter + 1;
					ELSE
						IF (speed_dir_x = '1') THEN
							pos_x_l <= pos_x_l + speed_x;
						ELSE
							pos_x_l <= pos_x_l - speed_x;
						END IF;
					END IF;
					IF ((pos_y_t <= (UNSIGNED(min_y & "000000") + speed_y)) AND (speed_dir_y = '0')) THEN
						pos_y_t 		<= UNSIGNED(min_y(8 DOWNTO 0) & "0000000") - pos_y_t + speed_y;
						speed_dir_y <= '1';
						bounce_counter <= bounce_counter + 1;
					ELSIF ((pos_y_t >= (UNSIGNED(max_y & "000000") - speed_y - BALL_SIZE + 1)) AND (speed_dir_y = '1')) THEN
						pos_y_t 		<= (UNSIGNED(max_y(8 DOWNTO 0) & "0000000")) - pos_y_t - speed_y - BALL_SIZE - BALL_SIZE + 2;
						speed_dir_y <= '0';
						bounce_counter <= bounce_counter + 1;
					ELSE
						IF (speed_dir_y = '1') THEN
							pos_y_t <= pos_y_t + speed_y;
						ELSE
							pos_y_t <= pos_y_t - speed_y;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END behave;
