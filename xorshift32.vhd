LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;


-- https://en.wikipedia.org/wiki/Xorshift
ENTITY xorshift32 IS
	PORT 
	(	
		clk 	  		: IN  	STD_LOGIC;
		rst			: IN		STD_LOGIC;
		seed			: IN		STD_LOGIC_VECTOR (31 DOWNTO 0);
		rng_state	: BUFFER STD_LOGIC_VECTOR (31 DOWNTO 0) := X"00000000"
	);
END xorshift32;

ARCHITECTURE behave OF xorshift32 IS

	SIGNAL aux1		: UNSIGNED (31 DOWNTO 0);
	SIGNAL aux2		: UNSIGNED (31 DOWNTO 0);
	SIGNAL aux3		: UNSIGNED (31 DOWNTO 0);

BEGIN

	aux1 <= (UNSIGNED(rng_state)) XOR (shift_left(UNSIGNED(rng_state), 13));
	aux2 <= (aux1) 					XOR (shift_right(aux1, 	  				 17));
	aux3 <= (aux2) 					XOR (shift_left(aux2,					 5));
	
	PROCESS(clk)
	BEGIN
		IF ((rst = '1') OR (rng_state = X"00000000")) THEN
			rng_state <= seed;
		ELSIF (RISING_EDGE(clk)) THEN
			rng_state <= STD_LOGIC_VECTOR (aux3);
		END IF;
	END PROCESS;

END behave;