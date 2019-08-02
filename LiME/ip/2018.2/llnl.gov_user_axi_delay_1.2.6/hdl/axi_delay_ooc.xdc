create_clock -name s_axi_lite_aclk -period 6 [get_ports s_axi_lite_aclk]
create_clock -name s_axi_aclk -period 5 [get_ports s_axi_aclk]
create_clock -name m_axi_aclk -period 5 [get_ports m_axi_aclk]
