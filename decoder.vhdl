--160070042/45/50/53--
--SAAK RISC Microprocessor--
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all;

entity decoder is
	port(ins: 			in std_logic_vector(15 downto 0);
			cz: 			out std_logic_vector(1 downto 0);
			ra, rb, rc: out std_logic_vector(2 downto 0);
			opcode: 		out std_logic_vector(3 downto 0);
			im6: 			out std_logic_vector(5 downto 0);
			im9: 			out std_logic_vector(8 downto 0));
end entity;

architecture decoder_behave of decoder is
	begin
		ra	    <= ins(11 downto  9);
		rb	    <= ins(8  downto  6);
		rc	    <= ins(5  downto  3);
		cz	    <= ins(1  downto  0);
		im6    <= ins(5  downto  0);
		im9    <= ins(8  downto  0);
		opcode <= ins(15 downto 12);
end decoder_behave;