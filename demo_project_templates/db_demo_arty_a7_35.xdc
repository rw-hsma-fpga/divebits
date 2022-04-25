# ----------------------------------------------------------------------------
# Clock Source
# ---------------------------------------------------------------------------- 
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { sys_clock }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { sys_clock }];

# ----------------------------------------------------------------------------
# Reset Button (LOW-ACTIVE!)
# ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { reset_rtl }]; 

# ----------------------------------------------------------------------------
# USB-UART
# ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { tx }]; 
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { rx }];


# ----------------------------------------------------------------------------
# User LEDs
# ----------------------------------------------------------------------------
# RGB Green
#set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; 
#set_property -dict { PACKAGE_PIN J4    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; 
#set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; 
#set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; 

# RGB Red
#set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; 
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; 
#set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; 
#set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; 

# RGB Blue
set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; 
set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; 
set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; 
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; 

# Normal
set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { LED[4] }]; 
set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { LED[5] }]; 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { LED[6] }]; 
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { LED[7] }]; 

