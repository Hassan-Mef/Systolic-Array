
# System clock (100 MHz)
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]
# Send button (BTN0)
set_property PACKAGE_PIN E16 [get_ports send_btn]
set_property IOSTANDARD LVCMOS33 [get_ports send_btn]
# UART TX (FPGA -> PC)
set_property PACKAGE_PIN D4 [get_ports TxD]
set_property IOSTANDARD LVCMOS33 [get_ports TxD]
# UART RX (PC -> FPGA)
set_property PACKAGE_PIN C4 [get_ports RxD]
set_property IOSTANDARD LVCMOS33 [get_ports RxD]

# ===============================================================
