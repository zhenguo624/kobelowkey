library verilog;
use verilog.vl_types.all;
entity data_handling is
    port(
        dat             : in     vl_logic_vector(15 downto 0);
        k_dat           : out    vl_logic_vector(3 downto 0);
        h_dat           : out    vl_logic_vector(3 downto 0);
        d_dat           : out    vl_logic_vector(3 downto 0);
        u_dat           : out    vl_logic_vector(3 downto 0)
    );
end data_handling;
