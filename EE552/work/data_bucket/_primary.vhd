library verilog;
use verilog.vl_types.all;
entity data_bucket is
    generic(
        WIDTH           : integer := 8;
        BL              : integer := 0;
        MYID            : integer := 0
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of BL : constant is 1;
    attribute mti_svvh_generic_type of MYID : constant is 1;
end data_bucket;
