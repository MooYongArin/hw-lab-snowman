set_property PACKAGE_PIN W5 [get_ports clk_100MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100MHz]
create_clock -add -name sys_clk_pin -period 40.00 -waveform {0 20} [get_ports clk_100MHz]

set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

set_property PACKAGE_PIN M18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN G19 [get_ports {vga_r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[3]}]
set_property PACKAGE_PIN H19 [get_ports {vga_r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[2]}]
set_property PACKAGE_PIN J19 [get_ports {vga_r[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[1]}]
set_property PACKAGE_PIN N19 [get_ports {vga_r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[0]}]

set_property PACKAGE_PIN N18 [get_ports {vga_g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[3]}]
set_property PACKAGE_PIN L18 [get_ports {vga_g[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[2]}]
set_property PACKAGE_PIN K18 [get_ports {vga_g[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[1]}]
set_property PACKAGE_PIN J18 [get_ports {vga_g[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[0]}]

set_property PACKAGE_PIN J17 [get_ports {vga_b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[3]}]
set_property PACKAGE_PIN H17 [get_ports {vga_b[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[2]}]
set_property PACKAGE_PIN G17 [get_ports {vga_b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[1]}]
set_property PACKAGE_PIN D17 [get_ports {vga_b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[0]}]

set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]

set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

# image_select[1:0] ← Use SW0 and SW1

set_property PACKAGE_PIN V17 [get_ports {image_select[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {image_select[0]}]

set_property PACKAGE_PIN V16 [get_ports {image_select[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {image_select[1]}]

# sd_data_in[7:0] ← SW2-SW9
set_property PACKAGE_PIN U14 [get_ports {sd_data_in[0]}]
set_property PACKAGE_PIN T16 [get_ports {sd_data_in[1]}]
set_property PACKAGE_PIN V13 [get_ports {sd_data_in[2]}]
set_property PACKAGE_PIN V14 [get_ports {sd_data_in[3]}]
set_property PACKAGE_PIN V15 [get_ports {sd_data_in[4]}]
set_property PACKAGE_PIN W13 [get_ports {sd_data_in[5]}]
set_property PACKAGE_PIN W14 [get_ports {sd_data_in[6]}]
set_property PACKAGE_PIN W15 [get_ports {sd_data_in[7]}]

# sd_data_valid ← SW10
set_property PACKAGE_PIN W16 [get_ports sd_data_valid]

# All switch signals use LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports {sd_data_in[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports sd_data_valid]
