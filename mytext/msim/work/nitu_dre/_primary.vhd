library verilog;
use verilog.vl_types.all;
entity nitu_dre is
    generic(
        Cut_1ms_Max     : integer := 24
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        k_num           : in     vl_logic_vector(7 downto 0);
        h_num           : in     vl_logic_vector(7 downto 0);
        d_num           : in     vl_logic_vector(7 downto 0);
        u_num           : in     vl_logic_vector(7 downto 0);
        seg             : out    vl_logic_vector(7 downto 0);
        sel             : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Cut_1ms_Max : constant is 1;
end nitu_dre;
