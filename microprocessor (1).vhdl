--160070042/45/50/53/48--
--SARK RISC Microprocessor--
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all;

entity microprocessor is
	port (CLK, RESET: in std_logic;
	r7: out std_logic_vector(15 downto 0));
end microprocessor;

architecture microprocessor_behave of microprocessor is
--------------------------------------------------------

component alu is
port(alu_in1, alu_in2, alu_en: in std_logic_vector(15 downto 0);
	alu_src: in std_logic_vector(1 downto 0);
	CLK: in std_logic;
	alu_out: out std_logic_vector(15 downto 0);
	C_out, Z_out: out std_logic);
end component;

component memory is
port(address: in std_logic_vector(15 downto 0);
	data_in: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(15 downto 0);
	CLK: in std_logic;
	memread, memwrite, init: in std_logic);
end component;

component registerfile is
	port(address1, address2, address3, address4: in std_logic_vector(2 downto 0);
		data_in1, data_in2: in std_logic_vector(15 downto 0);
		data_out1, data_out2, data_out3: out std_logic_vector(15 downto 0);
		r7: out std_logic_vector(15 downto 0);
		CLK, regwrite, regread, init: in std_logic);
end component;

component decoder is
	port(ins: in std_logic_vector(15 downto 0);
			cz: out std_logic_vector(1 downto 0);
			ra, rb, rc: out std_logic_vector(2 downto 0);
			opcode: out std_logic_vector(3 downto 0);
			im6: out std_logic_vector(5 downto 0);
			im9: out std_logic_vector(8 downto 0));
end component;

component PriorityEncoder is
port (x: in std_logic_vector(15 downto 0);
	s: out std_logic_vector(2 downto 0);
	d_out: out std_logic_vector(15 downto 0);
	zero_out: out std_logic;
	CLK: in std_logic);
end component;
-----------------------------------------------------------------------------------------------
signal pipe12, pipe23, pipe34, pipe45, pipe56: std_logic_vector(115 downto 0) := x"00000000000000000000000000000";

signal aluin1x, aluin2x, aluin2y,
		aluout1, aluout2,
		codeaddr, codedin, codedout, dataaddr, datadin, datadout,
		rfdout1, rfdout2, rfdout3, rfdin1, rfdin2,
		pein, pedum,
		PC:  std_logic_vector(15 downto 0) := x"0000";

signal alu_en1: std_logic_vector(15 downto 0) := x"FFFF";

signal alusrc2: std_logic_vector(1 downto 0) := "00";

signal peout, rfad1, rfad2, rfad3, rfadi: std_logic_vector(2 downto 0);-- := "000";

signal cout1, cout2, zout1, zout2,
	codemr, codemw, datamr, datamw, datai,
	regr, regwr,
	pezo: std_logic := '0';

signal codei, regi: std_logic := '1';

begin

	alu1: alu port map(alu_in1 => pipe12(15 downto 0), alu_in2 => "0000000000000001", alu_src => "00", C_out => cout1, Z_out => zout1, CLK => CLK, alu_out => aluout1, alu_en => alu_en1);
	alu2: alu port map(alu_in1 => aluin2x, alu_in2 => aluin2y, alu_src => alusrc2, C_out => cout2, Z_out => zout2, CLK => CLK, alu_out => pipe45(31 downto 16), alu_en => x"FFFF");

	code: memory port map(address => pipe12(15 downto 0), data_in => codedin, data_out => pipe12(31 downto 16), memread => '1', memwrite => codemw, init => codei, CLK => CLK);
	data: memory port map(address => dataaddr, data_in => datadin, data_out => datadout, memread => datamr, memwrite => datamw, init => datai, CLK => CLK);

	regf: registerfile port map(address1 => pipe23(11 downto 9), address2 => pipe23(8 downto 6), address3 => pipe56(5 downto 3), address4 => rfadi, data_out1 => pipe34(94 downto 79), data_out2 => pipe34(78 downto 63), data_out3 => pipe34(110 downto 95), data_in1 => rfdin1, data_in2 => rfdin2, regread => regr, regwrite => regwr, init => regi, CLK => CLK, r7 => r7);
	pen1: PriorityEncoder port map(x => pein, s => peout, d_out => pedum, zero_out => pezo, CLK => CLK);

	deco1: decoder port map(ins => pipe12(31 downto 16), ra => pipe23(11 downto 9), rb => pipe23(8 downto 6), rc => pipe23(5 downto 3), cz => pipe23(48 downto 47), opcode => pipe23(15 downto 12), im6 => pipe23(21 downto 16), im9 => pipe23(30 downto 22));


	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			codei <= '0';
			regi  <= '0';
		
		-------register file stage------------
			if(pipe23(15 downto 12) = "0000") then
				regwr <= '0';

			elsif(pipe23(15 downto 12) = "0001" or pipe23(15 downto 12) = "0100" or pipe23(15 downto 12) = "0101") then
				regwr <= '0';
				if(pipe23(21) = '1') then
					pipe34(52 downto 47) <= pipe23(21 downto 16);
					pipe34(62 downto 53) <= "1111111111";
				else 
					pipe34(52 downto 47) <= pipe23(21 downto 16);
					pipe34(62 downto 53) <= "0000000000";
				end if;
				
			elsif(pipe23(15 downto 12) = "0011") then
				regwr <= '0';
				pipe34(30 downto 22) <= pipe23(30 downto 22);

			elsif(pipe23(15 downto 12) = "1000" or pipe23(15 downto 12) = "1100") then
				regwr <= '0';
				if(pipe23(30) = '1') then
					pipe34(55 downto 47) <= pipe23(30 downto 22);
					pipe34(62 downto 56) <= "1111111";
				else
					pipe34(55 downto 47) <= pipe23(30 downto 22);
					pipe34(62 downto 56) <= "0000000";
				end if;

			elsif(pipe23(15 downto 12) = "1001" or pipe23(15 downto 12) = "1100") then
				regwr <= '0';

			elsif(pipe23(15 downto 12) = "0110") then
				regwr <= '0';
				pipe34(30 downto 22) <= pipe23(30 downto 22);
				alu_en1 <= x"0000";
				pipe45(115 downto 32) <= x"000000000000000000000";
				pipe45(15 downto   0) <= x"0000";

			elsif(pipe23(15 downto 12) = "0111") then
				regwr <= '0';
				pipe34(30 downto 22) <= pipe23(30 downto 22);								
 
			end if;

		------executional stage----------------
			-- add, adc, adz instructions
			if(pipe34(15 downto 12) = "0000") then
			
				if(pipe34(112 downto 111) = "00") then
					alusrc2 <= "00";
					aluin2x <= pipe34(94 downto 79);
					aluin2y <= pipe34(78 downto 63);
					--pipe45t1 <= aluout2; -- this is alu --> t1 part
				elsif(pipe34(112 downto 111) = "10") then
					if(pipe34(113) = '1') then
						alusrc2 <= "00";
						aluin2x <= pipe34(94 downto 79);
						aluin2y <= pipe34(78 downto 63);
						--pipe45t1 <= aluout2;
					
					end if;
				elsif(pipe34(112 downto 111) = "01") then
					if(pipe34(114) = '1') then
						alusrc2 <= "00";
						aluin2x <= pipe34(94 downto 79);
						aluin2y <= pipe34(78 downto 63);
						--pipe45t1 <= aluout2;
					
					end if;
				
				end if;	
			
			-- ndu, ndc, ndz instructions
			elsif(pipe34(15 downto 12) = "0010") then
			
				if(pipe34(112 downto 111) = "00") then
					alusrc2 <= "01";
					aluin2x <= pipe34(94 downto 79);
					aluin2y <= pipe34(78 downto 63);
					--pipe45t1 <= aluout2;
				elsif(pipe34(112 downto 111) = "10") then
					if(pipe34(113) = '1') then
						alusrc2 <= "01";
						aluin2x <= pipe34(94 downto 79);
						aluin2y <= pipe34(78 downto 63);
						--pipe45t1 <= aluout2;
					
					end if;
				elsif(pipe34(112 downto 111) = "01") then
					if(pipe34(114) = '1') then
						alusrc2 <= "01";
						aluin2x <= pipe34(94 downto 79);
						aluin2y <= pipe34(78 downto 63);
						--pipe45t1 <= aluout2;
					
					end if;
				
				end if;	

			-- adi instruction
			elsif(pipe34(15 downto 12) = "0001") then
				alusrc2 <= "00";
				aluin2x <= pipe34(94 downto 79);
				aluin2y <= pipe34(62 downto 47);
				--pipe45t1 <= aluout2;
				
			-- lhi instruction doubt
			elsif(pipe34(15 downto 12) = "0011") then
				-- pipe45t1 <= pipe34(30 downto 22);
				alusrc2 <= "00";
				aluin2x(6 downto 0) <= "0000000";
				aluin2x(15 downto 7) <= pipe34(30 downto 22);

			-- lw and sw instruction
			elsif(pipe34(15 downto 12) = "0100" or pipe34(15 downto 12) = "0101") then
				alusrc2 <= "00";
				aluin2x <= pipe34(94 downto 79);
				aluin2y <= pipe34(62 downto 47);
				--pipe45t1 <= aluout2;
			
			-- jal instruction
			elsif(pipe34(15 downto 12) = "1000") then
				alusrc2 <= "00";
				aluin2x <= pipe34(46 downto 31);
				aluin2y <= pipe34(62 downto 47);
				--pipe45t1 <= aluout2;
				-- pc <= pc;
			
			-- jlr instruction
			elsif(pipe34(15 downto 12) = "1001" or pipe34(15 downto 12) = "1100") then
				alusrc2 <= "00";
				aluin2x <= pipe34(94 downto 79);
				aluin2y <= x"0000";
				--pipe45t1 <= aluout2;

			 -- lm instruction
			elsif(pipe34(15 downto 12) = "0110") then
				alusrc2 <= "00";
			 	aluin2x <= pipe34(94 downto 79);
			 	aluin2y <= x"0000";
			 	pein <= pipe34(62 downto 47);
			 	pipe45(5 downto 3) <= peout;
			 	pipe45(62 downto 47) <= pedum;
			 	--pipe45t1 <= aluout2;
			
			 -- sm instruction
			elsif(pipe34(15 downto 12) = "0111") then
				alusrc2 <= "00";
			 	aluin2x <= pipe34(94 downto 79);
			 	aluin2y <= x"0000";
			 	pein <= pipe34(62 downto 47);
			 	pipe45(5 downto 3) <= peout;
			 	pipe45(62 downto 47) <= pedum;
			 	--pipe45t1 <= aluout2;
			
			end if;

			---memory stage-------------
			if(pipe45(15 downto 12) = "0000" or pipe45(15 downto 12) = "0001" or pipe45(15 downto 12) = "0011" or pipe45(15 downto 12) = "0101") then
				datamw <= '0';
				pipe56(31 downto 16) <= pipe45(31 downto 16);

			elsif(pipe45(15 downto 12) = "0100") then	--lw
				datamw <= '0';
				dataaddr <= pipe45(31 downto 16);
				pipe56(31 downto 16) <= datadout;

			elsif(pipe45(15 downto 12) = "1000" or pipe45(15 downto 12) = "1001") then	--jal/jlr
				datamw <= '0';
				pipe56(47 downto 32) <= pipe45(31 downto 16);
				pipe12(15 downto 0)  <= pipe45(31 downto 16);

			elsif(pipe45(15 downto 12) = "1100") then				--beq
				if(pipe45(115) = '1') then
					datamw <= '0';
					pipe56(47 downto 32) <= pipe45(31 downto 16);
					pipe12(15 downto  0) <= pipe45(31 downto 16);
					pipe45(115 downto 32) <= x"000000000000000000000";
					pipe45(15 downto   0) <= x"0000";
				else
					null;
				end if;
			elsif(pipe45(15 downto 12) = "0111") then
				datamw <= '0';
				dataaddr <= pipe45(31 downto 16);
				pipe56(31 downto 16) <= datadout;
				if(pezo = '1') then
					alu_en1 <= x"FFFF";
				else null;
				end if;

			elsif(pipe45(15 downto 12) = "0110") then
				datamw <= '0';
				pipe56(31 downto 16) <= pipe45(31 downto 16);
				if(pezo = '1') then
					alu_en1 <= x"FFFF";
				else null;
				end if;
			end if;

			--write back stage--------------
			if(pipe56(15 downto 12) = "0000") then				--add/adc/adz
				if(pipe56(113 downto 112) = "00") then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
				elsif(pipe56(113 downto 112) = "01") then
					if(pipe56(115) = '1') then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
					else null;
				end if;
				elsif(pipe56(113 downto 112) = "10") then
					if(pipe56(114) = '1') then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
					else null;
				end if;
				else null;	
				end if;

			elsif(pipe56(15 downto 12) = "0010") then			--ndu/ndc/ndz
				if(pipe56(113 downto 112) = "00") then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
				elsif(pipe56(113 downto 112) = "01") then
					if(pipe56(115) = '1') then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
					else null;
				end if;
				elsif(pipe56(113 downto 112) = "10") then
					if(pipe56(114) = '1') then
						regwr <= '1';
						rfadi  <= pipe56(5 downto 3);
						rfdin1 <= pipe56(31 downto 16);
						rfdin2 <= pipe56(47 downto 32);
					else null;
				end if;
				else null;	
				end if;

			elsif (pipe56(15 downto 12) = "0100" or pipe56(15 downto 12) = "0110") then 	--lw/lm
				regwr <= '1';
				rfadi  <= pipe56(5 downto 3);		--Rc
				rfdin1 <= pipe56(31 downto 16);		--t1
				rfdin2 <= pipe56(47 downto 32);

			elsif(pipe56(15 downto 12) = "0101" or pipe56(15 downto 12) = "0111") then		--sw
				datamw <= '1';
				dataaddr <= pipe56(31 downto 16);	--t1
				datadin  <= pipe56(79 downto 64);	--rfd2
				rfdin2 <= pipe56(47 downto 32);

			elsif(pipe56(15 downto 12) = "1001"  or pipe56(15 downto 12) = "1000") then	 	--jlr/jal
				regwr <= '1';
				rfadi  <= pipe56(5 downto 3);	--Rc
				rfdin1 <= pipe56(47 downto 32); --PC
				rfdin2 <= pipe56(47 downto 32);

			elsif(pipe56(15 downto 12) = "0001") then										--adi
				regwr <= '1';
				rfadi  <= pipe56(8 downto 6);	--Rb
				rfdin1 <= pipe56(31 downto 16);
				rfdin2 <= pipe56(47 downto 32);

			elsif(pipe56(15 downto 12) = "0011") then										--lhi
				regwr <= '1';
				rfadi  <= pipe56(11 downto 9);	--Ra
				rfdin1 <= pipe56(31 downto 16);
				rfdin2 <= pipe56(47 downto 32);

			end if;
			---------
			if(pipe34(15 downto 12) = "1000" or pipe34(15 downto 12) = "1001" or pipe34(15 downto 12) = "1100") then
				--pipe12(15 downto 0) <= pipe45(31 downto 16);
				null;
			else
				pipe12(15 downto 0) <= aluout1;
			end if;
			--assign to 56
			pipe56(115 downto 0)   <= pipe45(115 downto 0);
			--assign to 45
			pipe45(15 downto 0)    <= pipe34(15 downto 0);
			pipe45(47 downto 32)   <= pipe34(46 downto 31);
			pipe45(63 downto 48)   <= pipe34(62 downto 47);
			pipe45(79 downto 64)   <= pipe34(78 downto 63);
			pipe45(95 downto 80)   <= pipe34(94 downto 79);
			pipe45(111 downto 96)  <= pipe34(110 downto 95);
			pipe45(113 downto 112) <= pipe34(112 downto 111);
			pipe45(115 downto 114) <= pipe34(114 downto 113);
			--assign to 34
			pipe34(46 downto  0)   <= pipe23(46 downto  0);
			pipe34(112 downto 111) <= pipe23(48 downto 47);
			--assign to 23
			pipe23(46 downto 31)   <= pipe12(15 downto  0);
			--
			--regwr <= '0';
			--pipe12(15 downto 0)    <= pipe56(47 downto 32);
			---end carrying----
		end if;
	end process;
end microprocessor_behave;