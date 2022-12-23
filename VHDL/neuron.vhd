-- neuron.vhd
-- Neuron for Spiking Neural Network
--
-- Author: Klaus Niederberger
-- Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 22.12.2022
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neuron is
	generic(w_0		: integer:= 0;
			w_1		: integer:= 0;
			w_2		: integer:= 0;
			w_3		: integer:= 0;
			w_4		: integer:= 0;
			w_5		: integer:= 0;
			w_6		: integer:= 0;
			bias		: integer:= 0;
			v_th		: integer:= 0);

	port(	clk			: in  std_logic := '0';
			reset			: in  std_logic := '0';
			sp_0			: in  std_logic := '0';
			sp_1			: in  std_logic := '0';
			sp_2			: in  std_logic := '0';
			sp_3			: in  std_logic := '0';
			sp_4			: in  std_logic := '0';
			sp_5			: in  std_logic := '0';
			sp_6			: in  std_logic := '0';
			neuron_reset: in  std_logic := '0';
			spike_out	: out std_logic := '0');
end neuron;

architecture behave of neuron is

	-- sum signals for inputs
	signal tmp_sum_0			: integer:= 0;
	signal tmp_sum_1			: integer:= 0;
	signal tmp_sum_2			: integer:= 0;
	signal tmp_sum_3			: integer:= 0;
	signal tmp_sum_4			: integer:= 0;
	signal tmp_sum_5			: integer:= 0;
	signal tmp_sum_6			: integer:= 0;
	-- adder tree sums
	signal tmp_sum_b_0	   : integer:= 0;
	signal tmp_sum_1_2	   : integer:= 0;
	signal tmp_sum_3_4	   : integer:= 0;
	signal tmp_sum_5_6	   : integer:= 0;
	signal tmp_sum_b_0_1_2	: integer:= 0;
	signal tmp_sum_3_4_5_6	: integer:= 0;
	signal sum	            : integer:= 0;


begin


process

	 variable voltage			: integer := 0;	

begin
	wait until rising_edge(clk);
	

		-- add corresponding weight if there is a spike	
		if sp_0 = '1' then
			tmp_sum_0 <= w_0;
		else
			tmp_sum_0 <= 0;
		end if;

		if sp_1 = '1' then
			tmp_sum_1 <= w_1;
		else
			tmp_sum_1 <= 0;
		end if;

		if sp_2 = '1' then
			tmp_sum_2 <=  w_2;
		else
			tmp_sum_2 <= 0;
		end if;
		 
		if sp_3 = '1' then
			tmp_sum_3 <=  w_3;
		else
			tmp_sum_3 <= 0;
		end if;
		 
		if sp_4 = '1' then
			tmp_sum_4 <=  w_4;
		else
			tmp_sum_4 <= 0;
		end if;
		 
		if sp_5 = '1' then
			tmp_sum_5 <=  w_5;
		else
			tmp_sum_5 <= 0;
		end if;
		 
		if sp_6 = '1' then
			tmp_sum_6 <=  w_6;
		else
			tmp_sum_6 <= 0;
		end if;

		-- adder tree, add sums pairwise 
		tmp_sum_b_0     <= bias            + tmp_sum_0;
		tmp_sum_1_2     <= tmp_sum_1       + tmp_sum_2;
		tmp_sum_3_4     <= tmp_sum_3       + tmp_sum_4;
		tmp_sum_5_6     <= tmp_sum_5       + tmp_sum_6;
		
		tmp_sum_b_0_1_2 <= tmp_sum_b_0     + tmp_sum_1_2;
		tmp_sum_3_4_5_6 <= tmp_sum_3_4     + tmp_sum_5_6;
		
		sum             <= tmp_sum_b_0_1_2 + tmp_sum_3_4_5_6;
		
		
		voltage := voltage + sum;

		-- create spikes and reset voltage by subtraction
		if voltage > v_th then
			voltage := voltage - v_th;
			spike_out <= '1';
		else
			spike_out <= '0';
		end if;
		
		if neuron_reset = '1' then
			voltage := 0;
		end if;

end process;

end behave;