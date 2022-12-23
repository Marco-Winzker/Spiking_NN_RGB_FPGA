-- gen_input.vhd
-- Create Pseudo Random Number for Spiking Neural Network
--
-- Author: Klaus Niederberger
-- Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 22.12.2022
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gen_input is
	port(clk		: in std_logic;
		reset			: in std_logic;
		r_st				: in  integer;
		g_st				: in  integer;
		b_st				: in  integer;
		r_sp				: out std_logic;
		g_sp				: out std_logic;
		b_sp				: out std_logic);
end gen_input;

architecture behave of gen_input is

	-- pseudo random number between 1 and 255
	signal random		: std_logic_vector(7 downto 0):= "00000001";			

begin

process

begin

	wait until rising_edge(clk);

		-- create pseudo random number
		
		-- initialization after reset
		if(reset='1') then
			random			<= "00000001";
			
		-- lsfr of 8th order	
		else																				
			random(0)					<= random(7) xor random(5) xor random(4) xor random(3);
			random(7 downto 1)		<= random(6 downto 0); 
		end if;
		
		
		-- initiate spikes for R, G and B
		if (to_integer(unsigned(random)) < r_st) then		
			r_sp <= '1';
		else
			r_sp <= '0';
		end if;
		
		if (to_integer(unsigned(random)) < g_st) then
			g_sp <= '1';
		else
			g_sp <= '0';
		end if;
		
		if (to_integer(unsigned(random)) < b_st) then
			b_sp <= '1';
		else
			b_sp <= '0';
		end if;
		
end process;

end behave;