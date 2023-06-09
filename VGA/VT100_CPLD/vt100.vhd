----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:46:03 06/01/2023 
-- Design Name: 
-- Module Name:    vt100 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vt100 is
port(
		pclk		: in	std_logic;
		A15		: in	std_logic;
		WR			: in	std_logic;
		RD			: in	std_logic;
		DE			: in	std_logic;
		HS			: in	std_logic;
		VS			: in	std_logic;
		LOADSRIN	: in	std_logic;
		
		PIXCLKO	: out std_logic;
		HSYNC		: out std_logic;
		VSYNC		: out std_logic;

		LOADDAT	: out std_logic;
		LOADCOL	: out std_logic;
		LOADAD	: out std_logic;
		CCLK		: out std_logic;
		LOADSR	: out std_logic;		
		CRTCOE	: out std_logic;		
		GWE		: out std_logic;		
		LOADCHR	: out std_logic;		
		CHAROE	: out std_logic;		
		COLOR		: out std_logic;		
		LCHRLINE	: out std_logic
		
);
end vt100;

architecture Behavioral of vt100 is

signal clk : std_logic_vector (2 downto 0);

begin
	PIXCLKO	<= pclk;
	CCLK		<=	clk(2);
	
	VSYNC		<= not VS;
	HSYNC		<= not HS;
	
	LOADAD	<=  A15 and not (WR and RD);
	
	process (pclk)
	begin 
		if rising_edge(pclk) then	
			clk <= clk + 1;
		end if;
	end process;
	
end Behavioral;

