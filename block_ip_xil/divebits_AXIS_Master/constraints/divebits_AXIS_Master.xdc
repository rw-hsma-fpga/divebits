## setting DiveBits clocks asynchronous from other clocks to relax timing requirements

#set_clock_groups -name async_divebits -asynchronous -group { db_clock_in db_clock_out } -group { m00_axis_aclk }
