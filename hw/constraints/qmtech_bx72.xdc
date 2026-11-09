# Kompresja pliku bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Zegar systemowy 50 MHz (U4)
set_property PACKAGE_PIN Y18 [get_ports sys_clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_50m]
create_clock -period 20.000 -name sys_clk_50m [get_ports sys_clk_50m]

# Zegar odbiorczy RGMII 125 MHz z układu PHY YT8531C-CA (Pin V19)
set_property PACKAGE_PIN V19 [get_ports rgmii_rxc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk [get_ports rgmii_rxc]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rx_clk_local]

# Led'y do testów
set_property PACKAGE_PIN E16 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

# Sygnały sterujące i dane RGMII RX (Bank 14 - LVCMOS33)
set_property PACKAGE_PIN N15 [get_ports phy_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports phy_rst_n]

set_property PACKAGE_PIN R14 [get_ports rgmii_rx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rx_ctl]

set_property PACKAGE_PIN T18 [get_ports {rgmii_rxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]

set_property PACKAGE_PIN R18 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]

set_property PACKAGE_PIN R16 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]

set_property PACKAGE_PIN P14 [get_ports {rgmii_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
