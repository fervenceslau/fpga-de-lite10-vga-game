LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY display_char IS
	PORT 
	(	
		clk25			: IN	STD_LOGIC;								-- pixel clock
		pixel_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		pixel_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		char_x		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		char_y		: IN	STD_LOGIC_VECTOR (9  DOWNTO 0);
		char_code	: IN	STD_LOGIC_VECTOR (10 DOWNTO 0);
		char_on		: OUT STD_LOGIC
	);
END display_char;

ARCHITECTURE behave OF display_char IS

	SIGNAL font_address	:	std_logic_vector(10 downto 0);
	SIGNAL font_data		:	std_logic_vector(7 downto 0);
	
BEGIN


--	PROCESS (clk25, pixel_x, pixel_y, char_x, char_y, char_code)
--	BEGIN
--		IF (RISING_EDGE(CLK25)) THEN
--			font_address <= STD_LOGIC_VECTOR(UNSIGNED('0' & char_y) - UNSIGNED('0' & pixel_y) + UNSIGNED(char_code));
--		END IF;
--	END PROCESS;

	font_address <= STD_LOGIC_VECTOR(UNSIGNED("0000000" & pixel_y(3 DOWNTO 0)) - UNSIGNED("0000000" & char_y(3 DOWNTO 0)) + UNSIGNED(char_code));
	
	-- check if pixel is inside char region and rom memory
	char_on <=
		'1' WHEN	(char_x <= pixel_x) AND (pixel_x <= STD_LOGIC_VECTOR(UNSIGNED(char_x) + 7)) AND
					(char_y <= pixel_y) AND (pixel_y <= STD_LOGIC_VECTOR(UNSIGNED(char_y) + 15)) AND 
					(font_data(TO_INTEGER(UNSIGNED(pixel_x(2 DOWNTO 0)) - UNSIGNED(char_x(2 DOWNTO 0)))) = '1') ELSE
		'0'; 
		
	F : ENTITY work.font_rom 	PORT MAP (	clk25,
														font_address,
														font_data);
														

END behave;