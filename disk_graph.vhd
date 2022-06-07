LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY disk_graph IS
	PORT 
	(	
		pixel_x		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pixel_y		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pos_x_l		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pos_y_t		: IN	STD_LOGIC_VECTOR (9 DOWNTO 0);
		disk_on  	: OUT STD_LOGIC
	);
END disk_graph;

ARCHITECTURE behave OF disk_graph IS

	CONSTANT DISK_SIZE	:	UNSIGNED (9 DOWNTO 0) := "0000001000"; -- 8

	TYPE rom_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (0 TO 7);
 
	 -- DISK ROM definition
	 CONSTANT ROM_DISK: rom_type :=
	 (
		 "00111100",
		 "01111110",
		 "11111111",
		 "11111111",
		 "11111111",
		 "11111111",
		 "01111110",
		 "00111100" 
	 ); 
	 
	SIGNAL rom_row    	:	UNSIGNED (2 DOWNTO 0); 
	SIGNAL rom_col    	:	UNSIGNED (2 DOWNTO 0); 
	SIGNAL rom_data   	:	STD_LOGIC_VECTOR (0 TO 7);
	SIGNAL rom_biT    	:	STD_LOGIC;
	
	SIGNAL pos_x_r			:	UNSIGNED (9 DOWNTO 0);
	SIGNAL pos_y_b			:	UNSIGNED (9 DOWNTO 0);

BEGIN
	-- ties right and bottom positions to left and top, respectively
	pos_x_r <= UNSIGNED(pos_x_l) + DISK_SIZE - 1;
	pos_y_b <= UNSIGNED(pos_y_t) + DISK_SIZE - 1;

	-- map current pixel location to ROM row/col = addr/bit
	rom_row  <= UNSIGNED(pixel_y(2 DOWNTO 0)) - UNSIGNED(pos_y_t(2 DOWNTO 0));	-- rom address
	rom_col  <= UNSIGNED(pixel_x(2 DOWNTO 0)) - UNSIGNED(pos_x_l(2 DOWNTO 0));	-- rom bit
	rom_data <= ROM_DISK(TO_INTEGER(rom_row));
	rom_biT  <= rom_data(TO_INTEGER(rom_col));
	
	-- check if pixel is inside disk region and rom memory
	disk_on <=
		'1' WHEN	(pos_x_l <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(pos_x_r)) AND
					(pos_y_t <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(pos_y_b)) AND (rom_biT = '1') ELSE
		'0'; 

END behave;