library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library work;
use work.Gates.all;

entity excecute is

port(
      ins_alu,ins_mem              :in integer;
      clk,rst                      :in std_logic;
      r1_alu                       :in std_logic_vector(2 downto 0); --destination reg
      r2_alu,r3_alu,r2_mem,r3_mem  :in std_logic_vector(15 downto 0);
      imm6_alu,imm6_mem            :in std_logic_vector(15 downto 0);
      imm9_alu,imm9_mem            :in std_logic_vector(15 downto 0);
      imm8_alu,imm8_mem            :in std_logic_vector(7 downto 0);
      pc_alu,pc_mem                :in std_logic_vector(5 downto 0);
      c1,z1,c2,z2                  :in std_logic;
      sel1,sel2                    :in std_logic_vector(1 downto 0);

     c_out1,z_out1,c_out2,z_out2 :out std_logic;
     aluc,memc                   :out std_logic_vector(15 downto 0);  --data1,data2
     rwn_flag1,rwn_flag2         :out std_logic_vector(2 downto 0);   --read write nothin flag
     output_reg1                 :out std_logic_vector(2 downto 0);   --destination reg
     pc_out_alu,pc_out_mem       :out std_logic_vector(5 downto 0)
         
    );
end excecute;

architecture exec of execute is 
component ALU is
   port(alu_a,alu_b: in std_logic_vector(15 downto 0);
		  sel: in std_logic_vector(1 downto 0);
		alu_c: out std_logic_vector(15 downto 0);
      c_flag, z_flag: out std_logic);
end component;
signal alu_a,alu_b,alu_c : std_logic_vector(15 downto 0);

alu: ALU
	port map(alu_a,alu_b,sel1,aluc,c_out1,z_out1);

begin

   process(clk)
   begin
       if rising_edge(clk) then
        if rst='0' then 
           if ins_alu=0 then    --ADD/NDU
               pc_out_alu<=pc_alu+"000001";
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
               alu1: ALU
                  port map(r2_alu,r3_alu,sel1,aluc,c_out1,z_out1);
              

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu2: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu3: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;






           elsif ins_alu=1 then  -- ADC /NDC
               pc_out_alu<=pc_alu+"000001";
               if c_in="1" then
                rwn_flag<="01";
                output_reg1<=r1_alu;
               endif;
               alu4: ALU
                  port map(r2_alu,r3_alu,sel1,aluc,c_out1,z_out1); 

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu5: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu6: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;


           





            
           elsif ins_alu=2 then  -- ADZ /NDZ
               pc_out_alu<=pc_alu+"000001";
               if z_in="1" then
                rwn_flag<="01";
                output_reg1<=r1_alu;
               endif;
               alu7: ALU
                  port map(r2_alu,r3_alu,sel1,raluc,c_out1,z_out1);

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu8: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu9: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;





                          
           elsif ins_alu=3 then --ADL
               pc_out_alu<=pc_alu+"000001";
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
               alu10:ALU
                 port map(r2_alu,(shift_left(signed(r3_alu),1)),sel1,raluc,c_out1,z_out1);

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu11: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu12: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;





            elsif ins_alu=4 then --ADI
               pc_out_alu<=pc_alu+"000001";
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
               alu13: ALU
                  port map(r2_alu,imm6_alu,sel,raluc,c_out,z_out);


              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu14: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu15: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;



           elsif ins_alu=5 then --BEQ
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
              if r2_alu=r3_alu then
               pc_out_alu<=pc_alu+imm9_alu;
              else 
               pc_out_alu<=pc_alu+"000001";
              end if;

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu8: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu9: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;




           elsif ins_alu=6 then --JAL
              pc_out<=pc_alu+6imm9_alu;
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
              
              alu11: ALU
                  port map("0000000000"&pc_alu,"0000000000000001",sel,raluc,c_out,z_out);

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu8: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu9: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;





           elsif ins_alu=13 then --JLR
              pc_out<=r3_alu;
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
              alu12: ALU
                  port map("0000000000"&pc_alu,"0000000000000001",sel,raluc,c_out,z_out);

              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu8: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu9: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;



           elsif ins_alu=14 then--JRI
               rwn_flag1<="01";              --write
               output_reg1<=r1_alu;
              alu12: ALU
                  port map(r2_alu,imm9_alu,sel,pc_out,c_out,z_out);


              if ins_mem=0 then --LW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="00";
               alu8: ALU
                 port map(r3_mem,imm6_mem,sel,memc,c_out2,z_out2);
              else              --SW
               pc_out_mem<=pc_mem+"000001";
               rwn_flag2<="01";
               alu9: ALU
                 port map(r3_mem,imm6_mem,sel2,memc,c_out2,z_out2); 
              end if;

end if;

end if;

end architecture exec;