#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports CLK_IN_50]
create_clock -period "50.0 MHz" [get_ports CLK_IN_50_vid]

create_clock -period "1.0 MHz"  [get_nets {I2C_HDMI_Config:u_I2C_HDMI_Config|mI2C_CTRL_CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty

#Specify the required tSU
set tSU 0.500
#Specify the required tH
set tH  2.000

#Specify the required tCO  9 96 = 7.5
#Use -7.5 for -6 Altera FPGA
#Use -8.0 for -7 Altera FPGA
#Use -8.5 for -8 Altera FPGA
set tCO  -7.500

#Specify the required tCOm
set tCOm -3.800


##**************************************************************
## Set Input Delay
##**************************************************************

set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[2]*}]             -max -add_delay $tSU [get_ports {DDR3_DQ*[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[2]*}]             -min -add_delay $tH  [get_ports {DDR3_DQ*[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[2]*}] -clock_fall -max -add_delay $tSU [get_ports {DDR3_DQ*[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[2]*}] -clock_fall -min -add_delay $tH  [get_ports {DDR3_DQ*[*]}]

set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tSU  [get_ports {GPIO*[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tH   [get_ports {GPIO*[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tSU  [get_ports {KEY[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tH   [get_ports {KEY[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tSU  [get_ports {SW[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tH   [get_ports {SW[*]}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tSU  [get_ports {HDMI_I2C_SDA}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tH   [get_ports {HDMI_I2C_SDA}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tSU  [get_ports {HDMI_TX_INT}]
set_input_delay  -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tH   [get_ports {HDMI_TX_INT}]


##**************************************************************
## Set Output Delay
##**************************************************************

set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[0]*}] -max $tCO              [get_ports {DDR3*}] -add_delay
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[0]*}] -max $tCO  -clock_fall [get_ports {DDR3*}] -add_delay
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[0]*}] -min $tCOm             [get_ports {DDR3*}] -add_delay
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[0]*}] -min $tCOm -clock_fall [get_ports {DDR3*}] -add_delay

set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tCO  [get_ports {GPIO*[*]}]
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tCOm [get_ports {GPIO*[*]}]
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -max $tCO  [get_ports {LED[*]}]
set_output_delay -clock [get_clocks {*DDR3_PLL5*counter[4]*}] -min $tCOm [get_ports {LED[*]}]

set_output_delay -clock [get_clocks {VGA_PLL|VGA_SW_216_297|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -max $tCO  [get_ports {HDMI*}]
set_output_delay -clock [get_clocks {VGA_PLL|VGA_SW_216_297|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] -min $tCOm [get_ports {HDMI*}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# Separate VGA output video pixel clock from the main system clock and CLK_In 50Mhz clock.
set_false_path -from [get_clocks {*DDR3_PLL5*}] -to [get_clocks {VGA_PLL*}]
set_false_path -from [get_clocks {VGA_PLL*}] -to [get_clocks {*DDR3_PLL5*}]
set_false_path -from [get_clocks {VGA_PLL*}] -to [get_clocks {CLK_IN_50}]
set_false_path -from [get_clocks {CLK_IN_50}] -to [get_clocks {VGA_PLL*}]
set_false_path -from [get_clocks {VGA_PLL*}] -to [get_clocks {CLK_IN_50_vid}]
set_false_path -from [get_clocks {CLK_IN_50_vid}] -to [get_clocks {VGA_PLL*}]

# Separate the fake generated I2C clock output from the CLK_IN 50 MHz source.
set_false_path -from [get_clocks {*}] -to [get_clocks {u_I2C_HDMI_Config|mI2C_CTRL_CLK|q}]
set_false_path -from [get_clocks {u_I2C_HDMI_Config|mI2C_CTRL_CLK|q}] -to [get_clocks {*}]

# Optional: Separate the reset and low frequency inputs on the CLK_IN 50Mhz from the core.
set_false_path -from [get_clocks {CLK_IN_50}] -to [get_clocks {*DDR3_PLL5*counter[4]*}]
set_false_path -from [get_clocks {*DDR3_PLL5*counter[4]*}] -to [get_clocks {CLK_IN_50}]


#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************


#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************
