library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
	generic(delay		: integer;
			layer_delay	: integer);
	port(	clk			: in  std_logic;
			reset			: in  std_logic;
			neuron_reset: in  std_logic;
			vs_in			: in  std_logic;
			hs_in			: in  std_logic;
			de_in			: in  std_logic;
			res_ly_1		: out std_logic;
			res_ly_2		: out std_logic;
			vs_out		: out std_logic;
			hs_out		: out std_logic;
			de_out		: out std_logic);
end control;

architecture behave of control is

	type delay_array	   is array (1 to delay) 			of std_logic;
	type ly1_delay_array	is array (1 to layer_delay) 	of std_logic;
	type ly2_delay_array	is array (1 to layer_delay*2) of std_logic;
	signal vs_delay		: delay_array;
	signal hs_delay		: delay_array;
	signal de_delay		: delay_array;
	signal ly1_delay	   : ly1_delay_array;
	signal ly2_delay	   : ly2_delay_array;

begin

	process
	begin
	wait until rising_edge(clk);

	-- first value of array is current input
	vs_delay(1) <= vs_in;
	hs_delay(1) <= hs_in;
	de_delay(1) <= de_in;
	
	ly1_delay(1) <= neuron_reset;
	ly2_delay(1) <= neuron_reset;

	-- delay video signals according to generic
	for i in 2 to delay loop
		vs_delay(i) <= vs_delay(i-1);
		hs_delay(i) <= hs_delay(i-1);
		de_delay(i) <= de_delay(i-1);
	end loop;

	-- delay reset signal for layer 1
	for j in 2 to layer_delay loop
		ly1_delay(j) <= ly1_delay(j-1);
	end loop;

	-- delay reset signal for layer 2
	for k in 2 to layer_delay*2 loop
		ly2_delay(k) <= ly2_delay(k-1);
	end loop;

	end process;

	-- last value of array is output
	vs_out <= vs_delay(delay);
	hs_out <= hs_delay(delay);
	de_out <= de_delay(delay);

	res_ly_1 <= ly1_delay(layer_delay);
	res_ly_2 <= ly2_delay(layer_delay*2);

end behave;