library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package divebits is

-- included public entities:
-- 

	component divebits_config is
		Generic ( DB_RELEASE_HIGH_ACTIVE : boolean := true;
				  DB_DAISY_CHAIN_CRC_CHECK : boolean := false;
				  DB_RELEASE_DELAY_CYCLES: natural range 20 to 259:= 20;
				  -- hidden parametres
				  DB_ADDRESS : natural range 16#000# to 16#000# := 16#000#; -- special config block address
				  DB_TYPE : natural range 1000 to 1000 := 1000; -- special config block type
				  DB_NUM_OF_32K_ROMS: natural range 1 to 8 := 1
				  );			  
		Port  ( -- system ports
				sys_clock_in : in STD_LOGIC;
				sys_release_in : in STD_LOGIC;
				sys_release_out : out STD_LOGIC;
				
				-- DiveBits Master
				db_clock_out : out STD_LOGIC;			
				db_data_out : out STD_LOGIC;
				
				-- DiveBits Slave - for data feedback, optional error checking
				db_clock_in : in STD_LOGIC; -- unused, just for Master-Slave bus compatibility		
				db_data_in : in STD_LOGIC := '0'   -- feedback input
				);
	end component divebits_config;


	component divebits_constant_vector is
		Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
					 DB_TYPE : natural range 1001 to 1001 := 1001; -- must be unique to IP
				  DB_VECTOR_WIDTH: positive range 1 to 64 := 32;
				  DB_DEFAULT_VALUE: integer := 0;
				  DB_LOCAL_RELEASE : boolean := false;
				  DB_RELEASE_HIGH_ACTIVE : boolean := true;
				  DB_RELEASE_DELAY_CYCLES : natural range 1 to 255 := 15;
				  DB_DAISY_CHAIN: boolean := true );
		Port  ( -- DiveBits Slave 
				db_clock_in : in STD_LOGIC;
				db_data_in : in STD_LOGIC;
				
				-- DiveBits Master - only required for daisy chaining
				db_clock_out : out STD_LOGIC;
				db_data_out : out STD_LOGIC;
	
				-- local release signal
				local_release_out : out STD_LOGIC := '1';
				
				--
				Vector_out : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0)
				);
	end component divebits_constant_vector;


	component divebits_4_constant_vectors is
		Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
					 DB_TYPE : natural range 1003 to 1003 := 1003; -- must be unique to IP
	
				  DB_VECTOR_WIDTH: natural range 0 to 64 := 32;
				  DB_DEFAULT_VALUE_ALL: integer := 0;
	
				  DB_DEFAULT_VALUE_00: integer := 0;
				  DB_DEFAULT_VALUE_01: integer := 0;
				  DB_DEFAULT_VALUE_02: integer := 0;
				  DB_DEFAULT_VALUE_03: integer := 0;
	
				  DB_LOCAL_RELEASE : boolean := false;
				  DB_RELEASE_HIGH_ACTIVE : boolean := true;
				  DB_RELEASE_DELAY_CYCLES : natural range 1 to 255 := 15;
	
				  DB_DAISY_CHAIN: boolean := true );
		Port  ( -- DiveBits Slave 
				db_clock_in : in STD_LOGIC;
				db_data_in : in STD_LOGIC;
				
				-- DiveBits Master - only required for daisy chaining
				db_clock_out : out STD_LOGIC;
				db_data_out : out STD_LOGIC;
	
				-- local release signal
				local_release_out : out STD_LOGIC := '1';
				
				--
				Vector_00 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_01 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_02 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_03 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0)
				);
	end component divebits_4_constant_vectors;


	component divebits_16_constant_vectors is
		Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
					 DB_TYPE : natural range 1005 to 1005 := 1005; -- must be unique to IP
	
				  DB_VECTOR_WIDTH: natural range 0 to 64 := 32;
				  DB_DEFAULT_VALUE_ALL: integer := 0;
	
				  DB_DEFAULT_VALUE_00: integer := 0;
				  DB_DEFAULT_VALUE_01: integer := 0;
				  DB_DEFAULT_VALUE_02: integer := 0;
				  DB_DEFAULT_VALUE_03: integer := 0;
				  DB_DEFAULT_VALUE_04: integer := 0;
				  DB_DEFAULT_VALUE_05: integer := 0;
				  DB_DEFAULT_VALUE_06: integer := 0;
				  DB_DEFAULT_VALUE_07: integer := 0;
				  DB_DEFAULT_VALUE_08: integer := 0;
				  DB_DEFAULT_VALUE_09: integer := 0;
				  DB_DEFAULT_VALUE_10: integer := 0;
				  DB_DEFAULT_VALUE_11: integer := 0;
				  DB_DEFAULT_VALUE_12: integer := 0;
				  DB_DEFAULT_VALUE_13: integer := 0;
				  DB_DEFAULT_VALUE_14: integer := 0;
				  DB_DEFAULT_VALUE_15: integer := 0;
				  
				  DB_LOCAL_RELEASE : boolean := false;
				  DB_RELEASE_HIGH_ACTIVE : boolean := true;
				  DB_RELEASE_DELAY_CYCLES : natural range 1 to 255 := 15;
	
				  DB_DAISY_CHAIN: boolean := true );
		Port  ( -- DiveBits Slave 
				db_clock_in : in STD_LOGIC;
				db_data_in : in STD_LOGIC;
				
				-- DiveBits Master - only required for daisy chaining
				db_clock_out : out STD_LOGIC;
				db_data_out : out STD_LOGIC;
	
				-- local release signal
				local_release_out : out STD_LOGIC := '1';
				
				--
				Vector_00 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_01 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_02 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_03 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_04 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_05 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_06 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_07 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_08 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_09 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_10 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_11 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_12 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_13 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_14 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
				Vector_15 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0)
				);
	end component divebits_16_constant_vectors;


	component divebits_BlockRAM_init is
		Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
					 DB_TYPE : natural range 3000 to 3000 := 3000; -- must be unique to IP
	
				  DB_BRAM_DATA_WIDTH: natural range 1 to 64 := 32;
				  DB_BRAM_ADDR_WIDTH: natural range 1 to 16 := 10; -- choice somewhat arbitrarily
				  DB_BRAMCTRL_MODE: boolean := false; -- extends address to 32 bit, data width to next power of 2
	
				  -- computed by block diagram interface
				  FULL_ADDR_WIDTH: natural range 1 to 32 := 32;
				  FULL_DATA_WIDTH: natural range 1 to 64 := 32;
				  FULL_WEN_WIDTH: natural range 1 to 8 := 1;
	
				  DB_LOCAL_RELEASE : boolean := false;
				  DB_RELEASE_HIGH_ACTIVE : boolean := true;
				  DB_RELEASE_DELAY_CYCLES : natural range 1 to 255 := 15;
	
				  DB_DAISY_CHAIN: boolean := true );
		Port  ( -- DiveBits Slave 
				db_clock_in : in STD_LOGIC;
				db_data_in : in STD_LOGIC;
				
				-- DiveBits Master - only required for daisy chaining
				db_clock_out : out STD_LOGIC;
				db_data_out : out STD_LOGIC;
	
				-- local release signal
				local_release_out : out STD_LOGIC := '1';
	
				-- BRAM interface
				CLK : out STD_LOGIC;
				ADDR : out std_logic_vector(FULL_ADDR_WIDTH-1 downto 0);
				DOUT : out std_logic_vector(FULL_DATA_WIDTH-1 downto 0);
				WEN : out std_logic_vector(FULL_WEN_WIDTH-1 downto 0);
				EN: out std_logic;
				RST: out std_logic
				);
	end component divebits_BlockRAM_init;

end package;

package body divebits is
end divebits;
