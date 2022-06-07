LIBRARY 	IEEE;
USE 		IEEE.STD_LOGIC_1164.ALL;
USE 		IEEE.NUMERIC_STD.all;

ENTITY vga_driver IS
	PORT 
	(	
		clk25 	: IN  STD_LOGIC; 	-- 50 MHZ
		rst 		: IN  STD_LOGIC;
		h_sync	: OUT STD_LOGIC;
		v_sync	: OUT STD_LOGIC;
		pixel_x	: OUT	STD_LOGIC_VECTOR (9 DOWNTO 0);
		pixel_y	: OUT	STD_LOGIC_VECTOR (9 DOWNTO 0)
		--video_on : OUT STD_LOGIC;
	);
END vga_driver;

ARCHITECTURE arch OF vga_driver IS

	-- Constants of VGA sync and count generation
	CONSTANT HD 		:	INTEGER 		:= 640;	-- HORIZONTAL DISPLAY SIZE
	CONSTANT HFP 		:	INTEGER 		:= 16;	-- HORIZONTAL FRONT PORCH SIZE
	CONSTANT HSP		:	INTEGER 		:= 96;	-- HORIZONTAL SYNC PULSE SIZE
	CONSTANT HBP 		:	INTEGER 		:= 48;	-- HORIZONTAL BACK PORCH SIZE
	CONSTANT VD 		:	INTEGER 		:= 480;	-- VERTICAL DISPLAY SIZE
	CONSTANT VFP 		:	INTEGER 		:= 10;	-- VERTICAL FRONT PORCH SIZE
	CONSTANT VSP		:	INTEGER 		:= 2;		-- VERTICAL SYNC PULSE SIZE
	CONSTANT VBP 		:	INTEGER 		:= 33;	-- VERTICAL BACK PORCH SIZE
	
	SIGNAL	count_x	:	INTEGER 		:= 0;
	SIGNAL	count_y	:	INTEGER 		:= 0;
	
	SIGNAL 	video_on		: STD_LOGIC;

BEGIN
	-- converts pixels to std_logic_vector from int
	pixel_x <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_x, pixel_x'length));
	pixel_y <= STD_LOGIC_VECTOR(TO_UNSIGNED(count_y, pixel_y'length));

	-- process used to generate 25 MHz clock by dividing the input clock by 2


	-- process used to increment count_x and count_y
	hv_cont : PROCESS (clk25, rst)
	BEGIN
		IF (rst = '1') THEN
			count_x <= 0;
			count_y <= 0;
		ELSIF (RISING_EDGE(clk25)) THEN
			IF (count_x = (HD + HFP + HSP + HBP - 1)) THEN
				count_x <= 0;
				IF (count_y = (VD + VFP + VSP + VBP - 1)) THEN
					count_y <= 0;
				ELSE
					count_y <= count_y + 1;
				END IF;
			ELSE
				count_x <= count_x + 1;
			END IF;
		END IF;
	END PROCESS;
	
	-- process used to generate h_sync and v_sync with count_x and count_y
	hv_sync : PROCESS(clk25, rst, count_x, count_y)
	BEGIN
		IF (rst = '1') THEN
			h_sync <= '0';
			v_sync <= '0';
		ELSIF (RISING_EDGE(clk25)) THEN
			IF ((count_x <= (HD + HFP - 1)) OR (count_x > (HD + HFP + HSP - 1))) THEN
				h_sync <= '1';
			ELSE
				h_sync <= '0';
			END IF;
			IF ((count_y <= (VD + VFP - 1)) OR (count_y > (VD + VFP + VSP - 1))) THEN
				v_sync <= '1';
			ELSE
				v_sync <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	-- process used to generate VIDEO_ON signal with count_x and count_y
	vid_on : PROCESS(clk25, rst, count_x, count_y)
	BEGIN
		IF (rst = '1') THEN
			video_on <= '0';
		ELSIF (RISING_EDGE(clk25)) THEN
			IF ((count_x <= HD) AND (count_y <= VD)) THEN
				video_on <= '1';
			END IF;
		END IF;
	END PROCESS;
END arch;
