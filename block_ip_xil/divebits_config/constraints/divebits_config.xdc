## setting DiveBits clocks asynchronous from other clocks to relax timing requirements

#set_clock_groups -name async_divebits -asynchronous -group { sys_clock_in db_clock_in db_clock_out }
