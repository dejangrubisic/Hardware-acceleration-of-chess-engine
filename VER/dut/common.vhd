----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2018 09:11:35 PM
-- Design Name: 
-- Module Name: common - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

package common is
    type piece_8_3 is array (0 to 7) of std_logic_vector(2 downto 0);
    type piece_8_4 is array (0 to 7) of unsigned(3 downto 0);
    type type_coder is array(0 to 255) of unsigned(31 downto 0);
    type type_field_value is array (0 to 63) of signed(7 downto 0);
    type rank_buf is array (0 to 9) of unsigned(2 downto 0);

    constant pawn_pcsq : type_field_value;
    constant knight_pcsq : type_field_value;
    constant bishop_pcsq : type_field_value;
    constant king_pcsq : type_field_value;
    constant king_endgame_pcsq : type_field_value;    --simetrican pa ne mora oba
    
    constant reduction_coder_mem: type_coder;

end common;

package body common is


constant pawn_pcsq : type_field_value :=
(
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"05", X"0a", X"0f", X"14", X"14", X"0f", X"0a", X"05",
X"04", X"08", X"0c", X"10", X"10", X"0c", X"08", X"04",
X"03", X"06", X"09", X"0c", X"0c", X"09", X"06", X"03",
X"02", X"04", X"06", X"08", X"08", X"06", X"04", X"02",
X"01", X"02", X"03", X"f6", X"f6", X"03", X"02", X"01",
X"00", X"00", X"00", X"d8", X"d8", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
); 
 
constant knight_pcsq : type_field_value :=
(
X"f6", X"f6", X"f6", X"f6", X"f6", X"f6", X"f6", X"f6",
X"f6", X"00", X"00", X"00", X"00", X"00", X"00", X"f6",
X"f6", X"00", X"05", X"05", X"05", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"0a", X"0a", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"0a", X"0a", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"05", X"05", X"05", X"00", X"f6",
X"f6", X"00", X"00", X"00", X"00", X"00", X"00", X"f6",
X"f6", X"e2", X"f6", X"f6", X"f6", X"f6", X"e2", X"f6"
);

constant bishop_pcsq : type_field_value :=
(
X"f6", X"f6", X"f6", X"f6", X"f6", X"f6", X"f6", X"f6",
X"f6", X"00", X"00", X"00", X"00", X"00", X"00", X"f6",
X"f6", X"00", X"05", X"05", X"05", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"0a", X"0a", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"0a", X"0a", X"05", X"00", X"f6",
X"f6", X"00", X"05", X"05", X"05", X"05", X"00", X"f6",
X"f6", X"00", X"00", X"00", X"00", X"00", X"00", X"f6",
X"f6", X"f6", X"ec", X"f6", X"f6", X"ec", X"f6", X"f6"
);
 
constant king_pcsq : type_field_value :=
(
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8", X"d8",
X"ec", X"ec", X"ec", X"ec", X"ec", X"ec", X"ec", X"ec",
X"00", X"14", X"28", X"ec", X"00", X"ec", X"28", X"14"
);

constant king_endgame_pcsq : type_field_value :=    --simetrican pa ne mora oba
(
X"00", X"0a", X"14", X"1e", X"1e", X"14", X"0a", X"00",
X"0a", X"14", X"1e", X"28", X"28", X"1e", X"14", X"0a",
X"14", X"1e", X"28", X"32", X"32", X"28", X"1e", X"14",
X"1e", X"28", X"32", X"3c", X"3c", X"32", X"28", X"1e",
X"1e", X"28", X"32", X"3c", X"3c", X"32", X"28", X"1e",
X"14", X"1e", X"28", X"32", X"32", X"28", X"1e", X"14",
X"0a", X"14", X"1e", X"28", X"28", X"1e", X"14", X"0a",
X"00", X"0a", X"14", X"1e", X"1e", X"14", X"0a", X"00"
);


--Format: 8-does not exist + 3b-position(0 to 7)
constant reduction_coder_mem: type_coder :=
(
X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"8" & X"8" & X"8" & X"8" & X"8",
X"3" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"8" & X"8" & X"8" & X"8",
X"4" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"8" & X"8" & X"8" & X"8",
X"3" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8",
X"2" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"8" & X"8" & X"8",
X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"5" & X"8" & X"8" & X"8" & X"8",
X"3" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8",
X"2" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"5" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"5" & X"8" & X"8" & X"8",
X"4" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"2" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"5" & X"8" & X"8" & X"8",
X"3" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8",
X"2" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"5" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"5" & X"8" & X"8",
X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"6" & X"8" & X"8" & X"8" & X"8",
X"3" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8",
X"2" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"6" & X"8" & X"8" & X"8",
X"4" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"2" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"6" & X"8" & X"8" & X"8",
X"3" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8",
X"2" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"6" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"6" & X"8" & X"8",
X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"2" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"5" & X"6" & X"8" & X"8" & X"8",
X"3" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8",
X"2" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"5" & X"6" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"5" & X"6" & X"8" & X"8",
X"4" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"2" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"5" & X"6" & X"8" & X"8",
X"3" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8",
X"2" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"5" & X"6" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"5" & X"6" & X"8",
X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"2" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"7" & X"8" & X"8" & X"8" & X"8",
X"3" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8",
X"2" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"7" & X"8" & X"8" & X"8",
X"4" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"2" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"7" & X"8" & X"8" & X"8",
X"3" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8",
X"2" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"7" & X"8" & X"8",
X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"2" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"5" & X"7" & X"8" & X"8" & X"8",
X"3" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8",
X"2" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"5" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"5" & X"7" & X"8" & X"8",
X"4" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"2" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"5" & X"7" & X"8" & X"8",
X"3" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8",
X"2" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"5" & X"7" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"5" & X"7" & X"8",
X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"1" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"2" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"2" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"6" & X"7" & X"8" & X"8" & X"8",
X"3" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8",
X"2" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"3" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"6" & X"7" & X"8" & X"8",
X"4" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"2" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"6" & X"7" & X"8" & X"8",
X"3" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8",
X"2" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8",
X"1" & X"2" & X"3" & X"4" & X"6" & X"7" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"6" & X"7" & X"8",
X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8" & X"8",
X"0" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"1" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"1" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"2" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"2" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"2" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"2" & X"5" & X"6" & X"7" & X"8" & X"8",
X"3" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8",
X"2" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"2" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8",
X"1" & X"2" & X"3" & X"5" & X"6" & X"7" & X"8" & X"8",
X"0" & X"1" & X"2" & X"3" & X"5" & X"6" & X"7" & X"8",
X"4" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8" & X"8",
X"0" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"1" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"1" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"2" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"2" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"1" & X"2" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"0" & X"1" & X"2" & X"4" & X"5" & X"6" & X"7" & X"8",
X"3" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8" & X"8",
X"0" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"1" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"0" & X"1" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8",
X"2" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8" & X"8",
X"0" & X"2" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8",
X"1" & X"2" & X"3" & X"4" & X"5" & X"6" & X"7" & X"8",
X"0" & X"1" & X"2" & X"3" & X"4" & X"5" & X"6" & X"7");

end common;
