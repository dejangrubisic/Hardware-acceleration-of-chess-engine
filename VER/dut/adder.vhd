----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2018 11:45:37 AM
-- Design Name: 
-- Module Name: adder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is
    Port ( clk_in : in std_logic;
           side_in : in std_logic;
           start_in : in std_logic;
           reset_in : in std_logic;
		   
           w_pawn_in : in signed(11 downto 0);
           w_pawn_finished_in : in std_logic;
           w_raw_material_in : in unsigned(13 downto 0);
           w_soft_material_in : in signed(8 downto 0);           
           w_material_finished_in : in std_logic;
           w_king_in : in signed(9 downto 0);
           w_king_finished_in : in std_logic;           
           
           b_pawn_in : in signed(11 downto 0);        
           b_pawn_finished_in : in std_logic;          
           b_raw_material_in : in unsigned(13 downto 0);
           b_soft_material_in : in signed(8 downto 0);      
           b_material_finished_in : in std_logic;      
           b_king_in : in signed(9 downto 0);          
           b_king_finished_in : in std_logic;          
           
           finished_out : out std_logic;
           result_out : out signed(14 downto 0)
           );
end adder;

architecture Behavioral of adder is
type state_type is (idle, active);
signal state_reg, state_next: state_type;

signal s_side : std_logic := '0';
signal s_side_next : std_logic := '0';

signal s_w_pawn : signed(11 downto 0) := (others => '0');              
signal s_w_raw_material : unsigned(13 downto 0) := (others => '0');
signal s_w_soft_material : signed(8 downto 0) := (others => '0');     
signal s_w_king : signed(9 downto 0) := (others => '0');        
        

signal s_b_pawn : signed(11 downto 0) := (others => '0');              
signal s_b_raw_material : unsigned(13 downto 0) := (others => '0'); 
signal s_b_soft_material : signed(8 downto 0) := (others => '0');        
signal s_b_king : signed(9 downto 0) := (others => '0');

signal s_pawn_difference : signed(11 downto 0) := (others => '0');
signal s_raw_difference : signed (14 downto 0) := (others => '0');              
signal s_soft_difference : signed (9 downto 0) := (others => '0');     
signal s_king_difference : signed(9 downto 0) := (others => '0');

signal s_temp_result : signed(14 downto 0) := (others => '0');


signal s_finished : std_logic := '0';
signal s_finished_next : std_logic := '0';
signal s_finished_delayed_1 : std_logic := '0';
signal s_finished_delayed_1_next : std_logic := '0';
 
signal s_finished_out : std_logic := '0';  
signal s_finished_out_next : std_logic := '0'; 


begin    

    finished_out <= s_finished_out;

    process(state_reg, start_in, s_finished, s_finished_out, s_finished_delayed_1, w_pawn_finished_in, w_material_finished_in, w_king_finished_in,
                                                                   b_pawn_finished_in, b_material_finished_in, b_king_finished_in)
    begin
        state_next <= state_reg;
        
        s_finished_next <= (w_pawn_finished_in and w_material_finished_in) and (w_king_finished_in and
                            b_pawn_finished_in) and (b_material_finished_in and b_king_finished_in) ;
        s_finished_delayed_1_next <= s_finished;
        s_finished_out_next <= s_finished_out;
		
		s_side_next <= s_side;
		
        case state_reg is
        
        when idle   =>  s_finished_next <= '1';
                        s_finished_delayed_1_next <= '0';
                        if(start_in = '1')then
                            state_next <= active;
							s_side_next <= side_in;
                            s_finished_next <= '0';
                            s_finished_delayed_1_next <= '0';
                        end if;
            
        when active =>  s_finished_out_next <= '0';
                        
                        if(s_finished_delayed_1 = '1')then
                            state_next <= idle;
                            s_finished_out_next <= '1';
                        end if;
        
        end case;
    end process;
    
    
    s_temp_result <= (RESIZE(s_pawn_difference,15) + RESIZE(s_king_difference, 15)) + 
                     (RESIZE(s_raw_difference, 15) + RESIZE(s_soft_difference, 15));
    
    process(clk_in) 
    begin
        if(rising_edge(clk_in)) then
            if(reset_in = '1')then
                state_reg <= idle;
                s_finished <= '0';                          
                s_finished_delayed_1 <= '0';
                s_finished_out <= '0';
                s_pawn_difference <= (others => '0');
                s_raw_difference  <= (others => '0');
                s_soft_difference <= (others => '0');
                s_king_difference <= (others => '0');
				
				s_side <= '0';
            else
            
                state_reg <= state_next;
                s_finished <= s_finished_next;                          
                s_finished_delayed_1 <= s_finished_delayed_1_next;
                s_finished_out <= s_finished_out_next;
                            
                -------------------------------------------------------------------------------------------
                s_pawn_difference <= s_w_pawn - s_b_pawn;
                s_raw_difference <= signed(RESIZE(s_w_raw_material,15)) - signed(RESIZE(s_b_raw_material, 15));
                s_soft_difference <= RESIZE(s_w_soft_material, 10) - RESIZE(s_b_soft_material, 10);
                s_king_difference <= s_w_king - s_b_king;
                
				s_side <= s_side_next;
				
                if(s_side = '0')then
                    result_out <= s_temp_result;   
                else
                    result_out <= - s_temp_result;
                end if;
                --------------------------------------------------------------------
                if(w_pawn_finished_in = '1') then
                    s_w_pawn <= w_pawn_in;
                else
                    s_w_pawn <= (others => '0');
                end if;
                --------------------------------------------------------------------
                if(w_material_finished_in = '1') then      
                    s_w_raw_material <= w_raw_material_in;
                    s_w_soft_material <= w_soft_material_in;             
                else                                   
                    s_w_raw_material <= (others => '0');  
                    s_w_soft_material <= (others => '0');       
                end if;                                            
                --------------------------------------------------------------------            
                if(w_king_finished_in = '1') then      
                    s_w_king <= w_king_in;             
                else                                   
                    s_w_king <= (others => '0');       
                end if;                                
    ----------------------------------------------------------------------------------------            
               if(b_pawn_finished_in = '1') then                                           
                   s_b_pawn <= b_pawn_in;                                                  
               else                                                                        
                   s_b_pawn <= (others => '0');                                            
               end if;                                                                     
               --------------------------------------------------------------------        
               if(b_material_finished_in = '1') then        
                   s_b_raw_material <= b_raw_material_in;   
                   s_b_soft_material <= b_soft_material_in; 
               else                                         
                   s_b_raw_material <= (others => '0');     
                   s_b_soft_material <= (others => '0');    
               end if;                                                                                                                           
               --------------------------------------------------------------------        
               if(b_king_finished_in = '1') then                                           
                   s_b_king <= b_king_in;                                                  
               else                                                                        
                   s_b_king <= (others => '0');                                            
               end if;                                                                     
    ----------------------------------------------------------------------------------------            
            end if;
        end if;
    end process;

end Behavioral;
