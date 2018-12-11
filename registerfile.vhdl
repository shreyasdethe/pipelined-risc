--160070042/45/50/53--
--SAAK RISC Microprocessor--
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all;

entity registerfile is
	port(address1, address2, address3, address4: in std_logic_vector(2 downto 0);
		data_in1, data_in2: in std_logic_vector(15 downto 0);
		data_out1, data_out2, data_out3: out std_logic_vector(15 downto 0);
		r7: out std_logic_vector(15 downto 0);
		CLK, regwrite, regread, init: in std_logic);
end registerfile;

architecture mem_behave of registerfile is
	subtype word is std_logic_vector(15 downto 0);
	type ram is array(0 to 7) of word;
	signal fullram: ram := ((others => (others =>'0')));
	
begin

	process(CLK, regwrite)
		begin
			if (CLK'event and CLK = '1') then
				
				if (init = '1') then--				
				-------initialize some registers-----
				fullram(0) <= "0000000000000001"; -- R0 = 0x0000
				fullram(1) <= "0000001001010000"; -- R1 = 0d0000
--				fullram(2) <= "0000000000000000"; -- R2 = 0d0050
				fullram(3) <= "0000000001000011"; -- R3 = 0d67
				fullram(4) <= "0000000000000001"; -- R4 = 612d
--				fullram(5) <= "0000000000000000"; -- R5 = 0x0001
				fullram(6) <= "0000001111101000"; -- R6 = 1000d
				fullram(7) <= "0000000000000000"; -- R7 = 0x0001
				
				-------------------------------------
				--end if;


				elsif(regwrite = '1') then
					fullram(to_integer(unsigned(address3))) <= data_in1;
					fullram(7)    <= data_in2;
				end if;
				
				
				--else null;
			end if;
	end process;
	
	
	data_out1 <= fullram(to_integer(unsigned(address1)));
	data_out2 <= fullram(to_integer(unsigned(address2)));
	r7			 <= fullram(7);
end mem_behave;