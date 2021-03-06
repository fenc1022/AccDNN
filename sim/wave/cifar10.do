add wave -noupdate -format Logic /model_tb/clk
add wave -noupdate -format Logic /model_tb/ddr_rst
add wave -noupdate -format Logic /model_tb/rst
add wave -noupdate -format Logic /model_tb/init_calib_complete
add wave -noupdate -format Logic /model_tb/input_rdy
add wave -noupdate -format Literal /model_tb/input_count

add wave -noupdate -format Logic /model_tb/write_req
add wave -noupdate -format Literal /model_tb/write_start_addr
add wave -noupdate -format Literal /model_tb/write_length
add wave -noupdate -format Literal /model_tb/weight_count
add wave -noupdate -format Logic /model_tb/ddr_din_en
add wave -noupdate -format Literal /model_tb/ddr_din
add wave -noupdate -format Logic /model_tb/ddr_din_rdy
add wave -noupdate -format Logic /model_tb/ddr_din_eop
add wave -noupdate -format Logic /model_tb/write_done

#add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/dout_en
#add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/dout_eop
#add wave -noupdate -format Literal /model_tb/u0_top_dma_ddr/dout

add wave -noupdate -format Literal /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_addr         
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_cmd          
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_en           
add wave -noupdate -format Literal /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_wdf_data     
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_wdf_end      
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_wdf_wren     
add wave -noupdate -format Literal /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_rd_data      
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_rd_data_end  
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_rd_data_valid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_rdy          
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_sim_top/u_ddr4_sim_top/app_wdf_rdy      

add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/din
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/din_rdy
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/din_en
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/din_eop
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/dout_rdy
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/dout
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/dout_en
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/dout_eop
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_awaddr
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_awvalid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_awready
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_wdata
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_wlast
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_wvalid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_wready
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_bvalid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_bready
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_araddr
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_arvalid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_arready
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_rdata
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_rlast
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_rvalid
add wave -noupdate -format Logic /model_tb/u0_top_dma_ddr/u_ddr3_dma_engineer/m_axi_rready

#add wave -noupdate -format Logic /model_tb/blob_din_en
#add wave -noupdate -format Literal /model_tb/blob_din
#add wave -noupdate -format Logic /model_tb/blob_din_rdy
#add wave -noupdate -format Logic /model_tb/blob_din_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/clk
#add wave -noupdate -format Logic /model_tb/u0_module/rst
#add wave -noupdate -format Logic /model_tb/u0_module/blob_din_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/blob_din_en
#add wave -noupdate -format Literal /model_tb/u0_module/blob_din
#add wave -noupdate -format Logic /model_tb/u0_module/blob_din_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/input_blob_din_eop
#add wave -noupdate -format Literal /model_tb/u0_module/input_blob_din
#add wave -noupdate -format Logic /model_tb/u0_module/input_blob_din_en
#add wave -noupdate -format Logic /model_tb/u0_module/input_blob_din_rdy
#
#add wave -noupdate -format Logic /model_tb/u0_module/clk
#add wave -noupdate -format Logic /model_tb/u0_module/rst
#
#add wave -noupdate -format Logic /model_tb/u0_module/conv1_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/conv1_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/conv1_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/conv1_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/pool1_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/pool1_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/pool1_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/pool1_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/conv2_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/conv2_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/conv2_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/conv2_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/pool2_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/pool2_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/pool2_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/pool2_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/conv3_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/conv3_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/conv3_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/conv3_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/pool3_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/pool3_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/pool3_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/pool3_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/ip1_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/ip1_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/ip1_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/ip1_blob_dout_eop
#
#add wave -noupdate -format Logic /model_tb/u0_module/ip2_blob_dout_rdy
#add wave -noupdate -format Logic /model_tb/u0_module/ip2_blob_dout_en
#add wave -noupdate -format Literal /model_tb/u0_module/ip2_blob_dout
#add wave -noupdate -format Logic /model_tb/u0_module/ip2_blob_dout_eop

add wave -noupdate -format Logic /model_tb/u0_module/blob_dout_rdy
add wave -noupdate -format Logic /model_tb/u0_module/blob_dout_en
add wave -noupdate -format Literal /model_tb/u0_module/blob_dout
add wave -noupdate -format Logic /model_tb/u0_module/blob_dout_eop


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1768 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 170
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {6960 ns}
