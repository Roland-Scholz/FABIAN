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
--		T0			: in  std_logic;

		PIXCLKO	: out std_logic;
		HSYNC		: out std_logic;
		VSYNC		: out std_logic;

		LOADDAT	: out std_logic;
		LOADCOL	: out std_logic;
		LOADCOLB	: out std_logic;
		LOADAD	: inout std_logic;
		CCLK		: out std_logic;
		LOADSR	: out std_logic;		
		CRTCOE	: out std_logic;		
		WE_RAM	: out std_logic;		
		OE_DAT	: out std_logic;		
		LOADCHR	: out std_logic;		
		CHAROE	: out std_logic;		
		DISPEN	: out std_logic;	
		LCHRLINE	: out std_logic;
		OE_RAM	: out std_logic;
		OE_ADR	: out std_logic
--		CE_RAM	: out std_logic
		
);
end vt100;

--
--
--	clk(0) = 12,5  Mhz	 80ns
-- clk(1) = 6,25  Mhz	160ns
-- clk(2) = 3,125 Mhz	320ns
--


architecture Behavioral of vt100 is

signal clk : std_logic_vector (3 downto 0);
signal ramacc : std_logic := '0';
signal rw : std_logic;
signal ramstart : std_logic := '0';
signal ramwait : std_logic_vector (1 downto 0);
signal mode : std_logic_vector (1 downto 0) := "00";

signal I_OE_DAT : std_logic;
signal I_OE_ADR : std_logic;
signal I_OE_RAM : std_logic;
signal I_CRTCOE : std_logic;
signal I_CHAROE : std_logic;
signal I_WE_RAM : std_logic;
signal I_DE : std_logic;
signal I_WR : std_logic;

--signal I_LOADAD : std_logic;

begin
	PIXCLKO	<= pclk;
	CCLK		<=	clk(2) when mode(0) = '0' else clk(3);
		
	--LOADAD	<=  A15 and not (RD and WR);
	
	OE_DAT	<= '0' when mode(1) = '1' else I_OE_DAT;
	OE_ADR	<= '0' when mode(1) = '1' else I_OE_ADR;
	
	OE_RAM	<= '1' when mode(1) = '1' else I_OE_RAM;
	CRTCOE	<= '1' when mode(1) = '1' else I_CRTCOE;
	CHAROE	<= '1' when mode(1) = '1' else I_CHAROE;
	WE_RAM	<= '1' when mode(1) = '1' else I_WE_RAM;

	process (RD)
	begin
		if rising_edge(RD) then
			if A15 = '0' then
				mode <= mode + 1;
			end if;
		end if;
	end process;
	
	process (pclk)
	begin
		
		if rising_edge(pclk) then	
			clk <= clk + 1;
			
			if ramstart = '0' and ramacc = '0' and A15 = '1' and (RD = '0' or WR = '0') then
				ramstart <= '1';
				LOADAD <= '1';
				ramwait <= "00";
			end if;
				
			if LOADAD = '1' then
				ramwait <= ramwait + 1;
			end if;
			
			if ramwait = "10" then
				LOADAD <= '0';
				rw <= WR;
			end if;
			
			if ramstart = '1' and ramacc = '0' and RD = '1' and WR = '1' then
				ramacc <= '1';
			end if;

			
			-- 1-3 : RAM
			-- 3-5 : load char
			-- 5-7 : load color
			-- 7-1 : load charline			

			case clk is

				when "-001" =>	
					I_CHAROE <= '1';
					LCHRLINE <= '0';
					
					if ramacc = '1' and ramstart = '1' then
						I_OE_ADR <= '0';
						I_OE_DAT <= rw;	
						I_OE_RAM <= '1';
						ramstart <= '0';						
					end if;
					
				when "-010" =>
					if ramacc = '1' and ramstart = '0' then
						I_OE_RAM <= not rw;
						I_WE_RAM <= rw;
						LOADDAT <= '1';
						ramacc <= '0';
					end if;
					
				when "-011" =>
								
					LOADSR <= '1';					-- load shift register at next clock
					
					LOADDAT <= '0';
					I_WE_RAM <= '1';
					I_OE_ADR <= '1';
					I_OE_DAT <= '1';
					I_OE_RAM <= '0';
					
					I_CRTCOE <= '0';
					LOADCHR <= '1';			

	
				when "-100" =>
					VSYNC		<= VS;
					HSYNC		<= not HS;
					
					DISPEN	<= I_DE;
					I_DE		<= not DE;

					LOADCOL <= '1';
					LOADSR <= '0';	
					
				when "-101" =>
					LOADCOL <= '0';
				
					LOADCHR <= '0';	
					LOADCOLB <= '1';
									
				when "-111" =>
					
					I_CRTCOE <= '1';	
					LOADCOLB <= '0';
								
					I_CHAROE <= '0';
					LCHRLINE <= '1';
	
				when others =>
					null;
					
			end case;
			
		end if;
	end process;
	
	
end Behavioral;

