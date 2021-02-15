set fpga_part xczu7ev-ffvc1156-2-e
set project_name ips_$fpga_part
set project_path ./$project_name
set src_path $project_path/$project_name.srcs
set ip_path $src_path/sources_1/ip
create_project $project_name $project_path -part $fpga_part

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name ddr_write_fifo
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Builtin_FIFO} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {544} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {512} CONFIG.Read_Clock_Frequency {250} CONFIG.Write_Clock_Frequency {250} CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} CONFIG.Full_Threshold_Assert_Value {480}] [get_ips ddr_write_fifo]
generate_target all [get_files  $ip_path/ddr_write_fifo/ddr_write_fifo.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/ddr_write_fifo/ddr_write_fifo.xci]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name ddr_read_info_fifo
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Builtin_FIFO} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {17} CONFIG.Input_Depth {1024} CONFIG.Output_Data_Width {17} CONFIG.Output_Depth {1024}] [get_ips ddr_read_info_fifo]
generate_target all [get_files  $ip_path/ddr_read_info_fifo/ddr_read_info_fifo.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/ddr_read_info_fifo/ddr_read_info_fifo.xci]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name ddr_read_data_fifo
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Builtin_FIFO} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {512} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {512} CONFIG.Read_Clock_Frequency {250} CONFIG.Write_Clock_Frequency {250}] [get_ips ddr_read_data_fifo]
generate_target all [get_files  $ip_path/ddr_read_data_fifo/ddr_read_data_fifo.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/ddr_read_data_fifo/ddr_read_data_fifo.xci]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name ddr_read_addr_fifo
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Builtin_FIFO} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {27} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {27} CONFIG.Output_Depth {512} CONFIG.Read_Clock_Frequency {250} CONFIG.Write_Clock_Frequency {250} CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} CONFIG.Full_Threshold_Assert_Value {480}] [get_ips ddr_read_addr_fifo]
generate_target all [get_files  $ip_path/ddr_read_addr_fifo/ddr_read_addr_fifo.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/ddr_read_addr_fifo/ddr_read_addr_fifo.xci]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name host_write_fifo
set_property -dict [list CONFIG.Component_Name {host_write_fifo} CONFIG.Input_Data_Width {512} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {512} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {9} CONFIG.Full_Threshold_Assert_Value {511} CONFIG.Full_Threshold_Negate_Value {510}] [get_ips host_write_fifo]
generate_target all [get_files  $ip_path/host_write_fifo/host_write_fifo.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/host_write_fifo/host_write_fifo.xci]


create_ip -name mult_gen -vendor xilinx.com -library ip -module_name mul16_signed
set_property -dict [list CONFIG.MultType {Parallel_Multiplier} CONFIG.PortAType {Signed} CONFIG.PortAWidth {16} CONFIG.PortBType {Signed} CONFIG.PortBWidth {16} CONFIG.Multiplier_Construction {Use_Mults}] [get_ips mul16_signed]
generate_target all [get_files  $ip_path/mul16_signed/mul16_signed.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/mul16_signed/mul16_signed.xci]
#launch_run mul16_signed_synth_1
#wait_on_run mul16_signed_synth_1

create_ip -name mult_gen -vendor xilinx.com -library ip -module_name mul16_unsigned
set_property -dict [list CONFIG.MultType {Parallel_Multiplier} CONFIG.PortAType {Unsigned} CONFIG.PortAWidth {16} CONFIG.PortBType {Unsigned} CONFIG.PortBWidth {16} CONFIG.Multiplier_Construction {Use_Mults}] [get_ips mul16_unsigned]
generate_target {instantiation_template} [get_files $ip_path/mul16_unsigned/mul16_unsigned.xci]
generate_target all [get_files  $ip_path/mul16_unsigned/mul16_unsigned.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/mul16_unsigned/mul16_unsigned.xci]
#launch_run mul16_unsigned_synth_1
#wait_on_run mul16_unsigned_synth_1

create_ip -name mult_gen -vendor xilinx.com -library ip -module_name mul16x16_signed
set_property -dict [list CONFIG.MultType {Parallel_Multiplier} CONFIG.PortAType {Signed} CONFIG.PortAWidth {16} CONFIG.PortBType {Signed} CONFIG.PortBWidth {16} CONFIG.Multiplier_Construction {Use_Mults}] [get_ips mul16x16_signed]
generate_target all [get_files  $ip_path/mul16x16_signed/mul16x16_signed.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/mul16x16_signed/mul16x16_signed.xci]
#launch_run mul16x16_signed_synth_1
#wait_on_run mul16x16_signed_synth_1

create_ip -name mult_gen -vendor xilinx.com -library ip -module_name mul24x8_signed
set_property -dict [list CONFIG.MultType {Parallel_Multiplier} CONFIG.PortAType {Signed} CONFIG.PortAWidth {24} CONFIG.PortBType {Signed} CONFIG.PortBWidth {8} CONFIG.Multiplier_Construction {Use_Mults}] [get_ips mul24x8_signed]
generate_target all [get_files  $ip_path/mul24x8_signed/mul24x8_signed.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $ip_path/mul24x8_signed/mul24x8_signed.xci]
#launch_run mul24x8_signed_synth_1
#wait_on_run mul24x8_signed_synth_1

add_files {
   ./../../sim/lib/ddr3_dma/ASYNC_FIFO_WRAPPER.v
   ./../../lib/verilog/addr2.v
   ./../../lib/verilog/addr3.v
   ./../../lib/verilog/addr4.v
   ./../../lib/verilog/bit_trunc.v
   ./../../lib/verilog/bn_bias_relu.v
   ./../../lib/verilog/busm2n.v
   ./../../lib/verilog/controller_v2.v
   ./../../lib/verilog/controller_v2_a.v
   ./../../build/src/conv1_layer.v
   ./../../build/src/conv2_layer.v
   ./../../build/src/conv3_layer.v
   ./../../lib/verilog/ctrl_regs.v
   ./../../sim/lib/ddr3_dma/ddr3_dma_engineer.v
   ./../../sim/lib/ddr3_dma/ddr3_dma_read.v
   ./../../sim/lib/ddr3_dma/ddr3_dma_write.v
   ./../../lib/verilog/ddr_read_delay.v
   ./../../lib/verilog/delay.v
   ./../../lib/verilog/host_dma_engineer.v
   ./../../build/src/ip1_layer.v
   ./../../build/src/ip2_layer.v
   ./../../build/src/model.v
   ./../../lib/verilog/multiplier.v
   ./../../build/src/pool1_layer.v
   ./../../build/src/pool2_layer.v
   ./../../build/src/pool3_layer.v
   ./../../lib/verilog/vector_max.v
   ./../../lib/verilog/acc_addr.sv
   ./../../lib/verilog/vector_muladd.sv
   ./../../lib/verilog/model_dma.v
   ./../../build/coe/ip2_bm_ram.coe
   ./../../build/coe/ip1_bm_ram.coe
   ./../../build/coe/conv3_bm_ram.coe
   ./../../build/coe/conv2_bm_ram.coe
   ./../../build/coe/conv1_bm_ram.coe
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv2_rm_ram/conv2_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip2_wm_ram/ip2_wm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip1_bm_ram/ip1_bm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv3_bm_ram/conv3_bm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv2_bm_ram/conv2_bm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip1_wm_ram/ip1_wm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip2_bm_ram/ip2_bm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv1_bm_ram/conv1_bm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/pool3_rm_ram/pool3_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/pool1_rm_ram/pool1_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv2_wm_ram/conv2_wm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv1_rm_ram/conv1_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv1_wm_ram/conv1_wm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip2_rm_ram/ip2_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv3_rm_ram/conv3_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/ip1_rm_ram/ip1_rm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/conv3_wm_ram/conv3_wm_ram.xci
   ./../../build/ips_prj/ips_prj.srcs/sources_1/ip/pool2_rm_ram/pool2_rm_ram.xci
}

close_project
