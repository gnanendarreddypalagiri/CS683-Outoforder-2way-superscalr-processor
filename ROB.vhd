library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 


entity rob is
			port(rst,clk,zero,carry,zero2,carry2 : in std_logic; --2(suffix) are used for lw instr type
	           exec_phy_reg,exec_phy_reg2 : in integer;	
				  data,data_2 : in  std_logic_vector(15 downto 0);
				  rwn_flag: in std_logic_vector(2 downto 0);-- read write nothin flag
				  loc_rwn : in  std_logic_vector(5 downto 0);--from where read write nothin 
			     output_reg1 : in std_logic_vector(2 downto 0); --where we need to write result(destination reg)
				  prf_output_reg1 :in integer; --the phy reg which contains value
				  output_reg2 : in std_logic_vector(2 downto 0); --where we need to write result(destination reg)
				  prf_output_reg2 :in integer; --the phy reg which contains value
				  pc_ins_1 : in std_logic_vector(5 downto 0); -- to keep track of instr order
		        pc_ins_2 : in std_logic_vector(5 downto 0) ; -- to keep track of instr order
				  spec_instr_pc: in std_logic_vector(5 downto 0); --speculated pc
				  speculation_not_valid : in std_logic; --flushes instrs if =1 from spec_instr_pc
				  --out
				  reg1,reg2 :out std_logic_vector(2 downto 0);
				  data1,data2 :out std_logic_vector(15 downto 0);
				  z1,z2,c1,c2 :out std_logic --z and c flags
				  
				  
			    );
end rob;

architecture rob of rob  is

 type rob_data is array(0 to 7) of  std_logic_vector(42 downto 0);--bit 0=busy, 1=execute, 2 to 7 pc,8 to 10 reg(dest),11 to 15(prf number) 16- zero flag 17 carry flag 18 to 33 is data to be read write; 34 to 39 are where from/to read/write 40 to 42 th bit is bits which say read /write  from memory or nothing
 shared variable rob :rob_data;
 signal commit:integer;
 signal temp :std_logic_vector(3 downto 0);
begin
  commit <= 0;
  process(output_reg1,prf_output_reg1,output_reg2,prf_output_reg2)
  begin
  if rst = '1' then
    for i in 0 to 7 loop
	 rob(i) := (others => '0');
	 end loop;
	 
	end if;
	 
  if speculation_not_valid = '1' then
      for i in 0 to 7 loop
		 if rob(i)(7 downto 2 ) = spec_instr_pc then
		    for j in i to 7 loop
			  rob(j) := (others => '0'); 
			  end loop;
			  end if;
			  end loop;
	else --storing in rob
	 for i in 0 to 6 loop 
	 if rob(i)(0) = '0' then -- not busy
	    rob(i)(0) :='1';
		 rob(i)(7 downto 2) := pc_ins_1;
		 rob(i)(10 downto 8) :=output_reg1;
		 rob(i)(15 downto 11) :=std_logic_vector(to_unsigned(prf_output_reg1, 5));
		 
		 rob(i+1)(0) :='1';
		 rob(i+1)(7 downto 2) := pc_ins_2;
		 rob(i+1)(10 downto 8) :=output_reg2;
		 rob(i+1)(15 downto 11) :=std_logic_vector(to_unsigned(prf_output_reg2, 5));
		 end if;
		 exit;
		 end loop;
		 		 end if;


 end process;
 
 process(clk)
  begin 
  for i in 0 to 7 loop
      if rob(i)(10 downto 8) = exec_phy_reg then --for alu operations
		rob(i)(1) := '1'; --setting execute bit as 1
		rob(i)(17) := carry;
		rob(i)(16) := zero;
		rob(i)(33 downto 18) := data;
		end if;
    exit;
	 end loop;
	end process;
	
	
 process(clk)
  begin 
  for i in 0 to 7 loop -- for lw operations
      if rob(i)(10 downto 8) = exec_phy_reg2 then
		rob(i)(1) := '1'; --setting execute bit as 1
		rob(i)(17) := carry2;
		rob(i)(16) := zero2;
		rob(i)(33 downto 18) := data_2;
		rob(i)(39 downto 34) := loc_rwn;
		rob(i)(42 downto 40) := rwn_flag;
		end if;
    exit;
	 end loop;
	end process;
	
 process (clk)
 begin 
  if rob(commit)(1) ='1'then
   if rob(commit+1)(1)='1' then --checking if data is available
	   rob((commit))(0) := '0';-- making busy 0
		rob((commit+1))(0) := '0';-- making busy 0
		
		reg1<=rob((commit))(10 downto 8);-- copying regs
		reg2<=rob((commit+1))(10 downto 8);
	  
	data1<=rob((commit))(33 downto 18);--copying data
   data2<=rob((commit+1))(10 downto 8);
	
	z1<=rob((commit))(17);--copying z
	z2<=rob((commit+1))(17);
	
	c1<=rob((commit))(18);--copying z
	c2<=rob((commit+1))(18);
	 commit<= commit+2;
	 temp <= std_logic_vector(to_unsigned(commit, 4));
	 if temp(3) = '1' then
	   if temp(2) = '0' then
		  if temp(1) = '0' then
		    if temp(0) = '0' then
	   commit <= 0;
		end if ;
	end if ;
 end if	;
 end if ;
	end if ;
 end if	;
  end process;
  end architecture;