# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports sys_clock];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports sys_clock]; 


# ----------------------------------------------------------------------------
# Reset Button (High-Active) BTNC
# ---------------------------------------------------------------------------- 
set_property -dict { PACKAGE_PIN P16    IOSTANDARD LVCMOS33 } [get_ports { reset_rtl }]; 


# ----------------------------------------------------------------------------
# JA Pmod UART
# ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN AA11   IOSTANDARD LVCMOS33 } [get_ports { tx }]; # JA2
set_property -dict { PACKAGE_PIN Y10    IOSTANDARD LVCMOS33 } [get_ports { rx }]; # JA3


# ----------------------------------------------------------------------------
# User LEDs
# ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN T22   IOSTANDARD LVCMOS33 } [get_ports {LED[0]}]
set_property -dict { PACKAGE_PIN T21   IOSTANDARD LVCMOS33 } [get_ports {LED[1]}]
set_property -dict { PACKAGE_PIN U22   IOSTANDARD LVCMOS33 } [get_ports {LED[2]}]
set_property -dict { PACKAGE_PIN U21   IOSTANDARD LVCMOS33 } [get_ports {LED[3]}]
set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports {LED[4]}]
set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports {LED[5]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {LED[6]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {LED[7]}]
