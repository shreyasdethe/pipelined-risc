--160070042/45/50/53--
--SAAK RISC Microprocessor--
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all;

entity PriorityEncoder is
	port (x:in std_logic_vector(15 downto 0);
		s: out std_logic_vector(2 downto 0);
		d_out: out std_logic_vector(15 downto 0);
		zero_out: out std_logic := '1';
		CLK: in std_logic);
end PriorityEncoder;

architecture pencbehave of PriorityEncoder is

	signal dummyin: std_logic_vector(15 downto 0);
	signal dummyout: std_logic_vector(15 downto 0);

	begin

		dummyin <= x;

		process(CLK, dummyin)
		begin
			if(CLK'event and CLK = '1') then
				if(dummyin(0) = '1') then
					s <= "000";
					dummyout <= dummyin and "1111111111111110";
					zero_out <= '0';
				elsif(dummyin(1) = '1') then
					s <= "001";
					dummyout <= dummyin and "1111111111111100";
					zero_out <= '0';
				elsif(dummyin(2) = '1') then
					s <= "010";
					dummyout <= dummyin and "1111111111111000";
					zero_out <= '0';
				elsif(dummyin(3) = '1') then
					s <= "011";
					dummyout <= dummyin and "1111111111110000";
					zero_out <= '0';
				elsif(dummyin(4) = '1') then
					s <= "100";
					dummyout <= dummyin and "1111111111100000";
					zero_out <= '0';
				elsif(dummyin(5) = '1') then
					s <= "101";
					dummyout <= dummyin and "1111111111000000";
					zero_out <= '0';
				elsif(dummyin(6) = '1') then
					s <= "110";
					dummyout <= dummyin and "1111111110000000";
					zero_out <= '0';
				else
					dummyout <= "0000000000000000";
					zero_out <= '1';
				end if;
			end if;
		end process;

		d_out <= dummyout;

end pencbehave;