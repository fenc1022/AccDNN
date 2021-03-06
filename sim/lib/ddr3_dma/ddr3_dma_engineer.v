module ddr3_dma_engineer #(
  parameter DMA_ADDR_WIDTH = 27,
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 16,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input					ddr_clk,
input                   rst,
//write_dma Interface
input                           write_req,
input  [DMA_ADDR_WIDTH-1:0]     write_start_addr,
input  [DMA_ADDR_WIDTH-1:0]     write_length,
output                          write_done,
input  [C_M_AXI_DATA_WIDTH-1:0] din,
output                          din_rdy,
input                           din_en,
input                           din_eop,

//read_dma Interface
input                           dout_rdy,
output [C_M_AXI_DATA_WIDTH-1:0] dout,
output [15:0]                   dout_en,
output                          dout_eop,      

input                           read_req_0,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_0,
input  [DMA_ADDR_WIDTH-1:0]     read_length_0,
output                          read_ack_0,

input                           read_req_1,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_1,
input  [DMA_ADDR_WIDTH-1:0]     read_length_1,
output                          read_ack_1,
input                           read_req_2,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_2,
input  [DMA_ADDR_WIDTH-1:0]     read_length_2,
output                          read_ack_2,

input                           read_req_3,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_3,
input  [DMA_ADDR_WIDTH-1:0]     read_length_3,
output                          read_ack_3,

input                           read_req_4,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_4,
input  [DMA_ADDR_WIDTH-1:0]     read_length_4,
output                          read_ack_4,

input                           read_req_5,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_5,
input  [DMA_ADDR_WIDTH-1:0]     read_length_5,
output                          read_ack_5,

input                           read_req_6,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_6,
input  [DMA_ADDR_WIDTH-1:0]     read_length_6,
output                          read_ack_6,

input                           read_req_7,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_7,
input  [DMA_ADDR_WIDTH-1:0]     read_length_7,
output                          read_ack_7,

input                           read_req_8,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_8,
input  [DMA_ADDR_WIDTH-1:0]     read_length_8,
output                          read_ack_8,

input                           read_req_9,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_9,
input  [DMA_ADDR_WIDTH-1:0]     read_length_9,
output                          read_ack_9,

input                           read_req_10,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_10,
input  [DMA_ADDR_WIDTH-1:0]     read_length_10,
output                          read_ack_10,

input                           read_req_11,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_11,
input  [DMA_ADDR_WIDTH-1:0]     read_length_11,
output                          read_ack_11,

input                           read_req_12,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_12,
input  [DMA_ADDR_WIDTH-1:0]     read_length_12,
output                          read_ack_12,

input                           read_req_13,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_13,
input  [DMA_ADDR_WIDTH-1:0]     read_length_13,
output                          read_ack_13,

input                           read_req_14,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_14,
input  [DMA_ADDR_WIDTH-1:0]     read_length_14,
output                          read_ack_14,

input                           read_req_15,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_15,
input  [DMA_ADDR_WIDTH-1:0]     read_length_15,
output                          read_ack_15,

// ddr3 axi master Interface
input                   init_calib_complete,
input                   axi_aresetn,
// axi write address
output  [C_M_AXI_ADDR_WIDTH-1:0]        m_axi_awaddr,
output  [7:0]                           m_axi_awlen,
output  [2:0]                           m_axi_awsize,
output  [1:0]                           m_axi_awburst,
output  [3:0]                           m_axi_awcache,
output                                  m_axi_awvalid,
input                                   m_axi_awready,
output  [C_M_AXI_ID_WIDTH-1:0]          m_axi_awid,
output                                  m_axi_awlock,
output  [2:0]                           m_axi_awprot,
output  [3:0]                           m_axi_awqos,
output                                  m_axi_awuser,
// axi write data
output  [C_M_AXI_DATA_WIDTH-1:0]        m_axi_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb,
output                                  m_axi_wlast,
output                                  m_axi_wvalid,
input                                   m_axi_wready,
output                                  m_axi_wuser,
// axi write response
input   [1:0]                           m_axi_bresp,
input                                   m_axi_bvalid,
output                                  m_axi_bready,
input   [C_M_AXI_ID_WIDTH-1:0]          m_axi_bid,
input                                   m_axi_buser,
// axi read address
output  [C_M_AXI_ADDR_WIDTH-1:0]        m_axi_araddr,
output  [7:0]                           m_axi_arlen,
output  [2:0]                           m_axi_arsize,
output  [1:0]                           m_axi_arburst,
output  [3:0]                           m_axi_arcache,
output                                  m_axi_arvalid,
input                                   m_axi_arready,
output  [C_M_AXI_ID_WIDTH:0]            m_axi_arid,
output                                  m_axi_arlock,
output  [2:0]                           m_axi_arprot,
output  [3:0]                           m_axi_arqos,
output  [0:0]                           m_axi_aruser,
// axi read data
input   [C_M_AXI_DATA_WIDTH-1:0]        m_axi_rdata,
input   [1:0]                           m_axi_rresp,
input                                   m_axi_rlast,
input                                   m_axi_rvalid,
output                                  m_axi_rready,
input   [C_M_AXI_ID_WIDTH:0]            m_axi_rid,
input   [0:0]                           m_axi_ruser
);

ddr3_dma_write #
(
    .DMA_ADDR_WIDTH         ( DMA_ADDR_WIDTH        ),
    .C_M_AXI_ID_WIDTH       ( C_M_AXI_ID_WIDTH      ),
    .C_M_AXI_BURST_LEN      ( 1                     ), // TODO: Support longer burst length
    .C_M_AXI_ADDR_WIDTH     ( C_M_AXI_ADDR_WIDTH    ),
    .C_M_AXI_DATA_WIDTH     ( C_M_AXI_DATA_WIDTH    )
) u_ddr3_dma_write 
(
    .clk                     ( clk                  ),
    .ddr_clk                 ( ddr_clk              ),
    .rst                     ( rst                  ),
    .write_req               ( write_req            ),
    .write_start_addr        ( write_start_addr     ),
    .write_length            ( write_length         ),
    .write_done              ( write_done           ),
    .din                     ( din                  ),
    .din_en                  ( din_en               ),
    .din_eop                 ( din_eop              ),
    .din_rdy                 ( din_rdy              ),
    .m_axi_awaddr            ( m_axi_awaddr         ),
    .m_axi_awlen             ( m_axi_awlen          ),
    .m_axi_awsize            ( m_axi_awsize         ),
    .m_axi_awburst           ( m_axi_awburst        ),
    .m_axi_awcache           ( m_axi_awcache        ),
    .m_axi_awvalid           ( m_axi_awvalid        ),
    .m_axi_awready           ( m_axi_awready        ),
    .m_axi_awid              ( m_axi_awid           ),
    .m_axi_awlock            ( m_axi_awlock         ),
    .m_axi_awprot            ( m_axi_awprot         ),
    .m_axi_awqos             ( m_axi_awqos          ),
    .m_axi_awuser            ( m_axi_awuser         ),
    .m_axi_wdata             ( m_axi_wdata          ),
    .m_axi_wstrb             ( m_axi_wstrb          ),
    .m_axi_wlast             ( m_axi_wlast          ),
    .m_axi_wvalid            ( m_axi_wvalid         ),
    .m_axi_wready            ( m_axi_wready         ),
    .m_axi_wuser             ( m_axi_wuser          ),
    .m_axi_bresp             ( m_axi_bresp          ),
    .m_axi_bvalid            ( m_axi_bvalid         ),
    .m_axi_bready            ( m_axi_bready         ),
    .m_axi_bid               ( m_axi_bid            ),
    .m_axi_buser             ( m_axi_buser          )
);

ddr3_dma_read #
(
    .DMA_ADDR_WIDTH         ( DMA_ADDR_WIDTH        ),
    .C_M_AXI_ID_WIDTH       ( C_M_AXI_ID_WIDTH      ),
    .C_M_AXI_ADDR_WIDTH     ( C_M_AXI_ADDR_WIDTH    ),
    .C_M_AXI_DATA_WIDTH     ( C_M_AXI_DATA_WIDTH    )

)  u_ddr3_dma_read 
(
    .clk                     ( clk                  ),
    .ddr_clk                 ( ddr_clk              ),
    .rst                     ( rst                  ),
    .axi_aresetn             ( axi_aresetn          ),
    .init_calib_complete     ( init_calib_complete  ),
    .read_req_0              ( read_req_0           ),
    .read_start_addr_0       ( read_start_addr_0    ),
    .read_length_0           ( read_length_0        ),
    .read_req_1              ( read_req_1           ),
    .read_start_addr_1       ( read_start_addr_1    ),
    .read_length_1           ( read_length_1        ),
    .read_req_2              ( read_req_2           ),
    .read_start_addr_2       ( read_start_addr_2    ),
    .read_length_2           ( read_length_2        ),
    .read_req_3              ( read_req_3           ),
    .read_start_addr_3       ( read_start_addr_3    ),
    .read_length_3           ( read_length_3        ),
    .read_req_4              ( read_req_4           ),
    .read_start_addr_4       ( read_start_addr_4    ),
    .read_length_4           ( read_length_4        ),
    .read_req_5              ( read_req_5           ),
    .read_start_addr_5       ( read_start_addr_5    ),
    .read_length_5           ( read_length_5        ),
    .read_req_6              ( read_req_6           ),
    .read_start_addr_6       ( read_start_addr_6    ),
    .read_length_6           ( read_length_6        ),
    .read_req_7              ( read_req_7           ),
    .read_start_addr_7       ( read_start_addr_7    ),
    .read_length_7           ( read_length_7        ),
    .read_req_8              ( read_req_8           ),
    .read_start_addr_8       ( read_start_addr_8    ),
    .read_length_8           ( read_length_8        ),
    .read_req_9              ( read_req_9           ),
    .read_start_addr_9       ( read_start_addr_9    ),
    .read_length_9           ( read_length_9        ),
    .read_req_10             ( read_req_10          ),
    .read_start_addr_10      ( read_start_addr_10   ),
    .read_length_10          ( read_length_10       ),
    .read_req_11             ( read_req_11          ),
    .read_start_addr_11      ( read_start_addr_11   ),
    .read_length_11          ( read_length_11       ),
    .read_req_12             ( read_req_12          ),
    .read_start_addr_12      ( read_start_addr_12   ),
    .read_length_12          ( read_length_12       ),
    .read_req_13             ( read_req_13          ),
    .read_start_addr_13      ( read_start_addr_13   ),
    .read_length_13          ( read_length_13       ),
    .read_req_14             ( read_req_14          ),
    .read_start_addr_14      ( read_start_addr_14   ),
    .read_length_14          ( read_length_14       ),
    .read_req_15             ( read_req_15          ),
    .read_start_addr_15      ( read_start_addr_15   ),
    .read_length_15          ( read_length_15       ),
    .dout_rdy                ( dout_rdy             ),
    .dout                    ( dout                 ),
    .dout_en                 ( dout_en              ),
    .dout_eop                ( dout_eop             ),
    .read_ack_0              ( read_ack_0           ),
    .read_ack_1              ( read_ack_1           ),
    .read_ack_2              ( read_ack_2           ),
    .read_ack_3              ( read_ack_3           ),
    .read_ack_4              ( read_ack_4           ),
    .read_ack_5              ( read_ack_5           ),
    .read_ack_6              ( read_ack_6           ),
    .read_ack_7              ( read_ack_7           ),
    .read_ack_8              ( read_ack_8           ),
    .read_ack_9              ( read_ack_9           ),
    .read_ack_10             ( read_ack_10          ),
    .read_ack_11             ( read_ack_11          ),
    .read_ack_12             ( read_ack_12          ),
    .read_ack_13             ( read_ack_13          ),
    .read_ack_14             ( read_ack_14          ),
    .read_ack_15             ( read_ack_15          ),
    .m_axi_araddr            ( m_axi_araddr         ),
    .m_axi_arlen             ( m_axi_arlen          ),
    .m_axi_arsize            ( m_axi_arsize         ),
    .m_axi_arburst           ( m_axi_arburst        ),
    .m_axi_arcache           ( m_axi_arcache        ),
    .m_axi_arvalid           ( m_axi_arvalid        ),
    .m_axi_arready           ( m_axi_arready        ),
    .m_axi_arid              ( m_axi_arid           ),
    .m_axi_arlock            ( m_axi_arlock         ),
    .m_axi_arprot            ( m_axi_arprot         ),
    .m_axi_arqos             ( m_axi_arqos          ),
    .m_axi_aruser            ( m_axi_aruser         ),
    .m_axi_rdata             ( m_axi_rdata          ),
    .m_axi_rresp             ( m_axi_rresp          ),
    .m_axi_rlast             ( m_axi_rlast          ),
    .m_axi_rvalid            ( m_axi_rvalid         ),
    .m_axi_rready            ( m_axi_rready         ),
    .m_axi_rid               ( m_axi_rid            ),
    .m_axi_ruser             ( m_axi_ruser          )
);

endmodule
