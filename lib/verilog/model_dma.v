module model_dma #(
  parameter DMA_ADDR_WIDTH = 27,
  parameter C_S_AXI_DATA_WIDTH	= 32,
  parameter C_S_AXI_ADDR_WIDTH	= 7,
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 16,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input                   ddr_clk,
input                   resetn,
input                   init_calib_complete,
// Ports of Axi Slave contrl bus
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
input wire [2 : 0] s_axi_awprot,
input wire  s_axi_awvalid,
output wire  s_axi_awready,
input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
input wire  s_axi_wvalid,
output wire  s_axi_wready,
output wire [1 : 0] s_axi_bresp,
output wire  s_axi_bvalid,
input wire  s_axi_bready,
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
input wire [2 : 0] s_axi_arprot,
input wire  s_axi_arvalid,
output wire  s_axi_arready,
output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
output wire [1 : 0] s_axi_rresp,
output wire  s_axi_rvalid,
input wire  s_axi_rready,

// ddr3 axi master Interface
// axi write address
output  [C_M_AXI_ADDR_WIDTH-1:0]        ddr_awaddr,
output  [7:0]                           ddr_awlen,
output  [2:0]                           ddr_awsize,
output  [1:0]                           ddr_awburst,
output  [3:0]                           ddr_awcache,
output                                  ddr_awvalid,
input                                   ddr_awready,
output  [C_M_AXI_ID_WIDTH-1:0]          ddr_awid,
output                                  ddr_awlock,
output  [2:0]                           ddr_awprot,
output  [3:0]                           ddr_awqos,
output                                  ddr_awuser,
// axi write data
output  [C_M_AXI_DATA_WIDTH-1:0]        ddr_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      ddr_wstrb,
output                                  ddr_wlast,
output                                  ddr_wvalid,
input                                   ddr_wready,
output                                  ddr_wuser,
// axi write response
input   [1:0]                           ddr_bresp,
input                                   ddr_bvalid,
output                                  ddr_bready,
input   [C_M_AXI_ID_WIDTH-1:0]          ddr_bid,
input                                   ddr_buser,
// axi read address
output  [C_M_AXI_ADDR_WIDTH-1:0]        ddr_araddr,
output  [7:0]                           ddr_arlen,
output  [2:0]                           ddr_arsize,
output  [1:0]                           ddr_arburst,
output  [3:0]                           ddr_arcache,
output                                  ddr_arvalid,
input                                   ddr_arready,
output  [C_M_AXI_ID_WIDTH-1:0]          ddr_arid,
output                                  ddr_arlock,
output  [2:0]                           ddr_arprot,
output  [3:0]                           ddr_arqos,
output                                  ddr_aruser,
// axi read data
input   [C_M_AXI_DATA_WIDTH-1:0]        ddr_rdata,
input   [1:0]                           ddr_rresp,
input                                   ddr_rlast,
input                                   ddr_rvalid,
output                                  ddr_rready,
input   [C_M_AXI_ID_WIDTH-1:0]          ddr_rid,
input                                   ddr_ruser,

// host axi master Interface
// axi write address
output  [C_M_AXI_ADDR_WIDTH-1:0]        host_awaddr,
output  [7:0]                           host_awlen,
output  [2:0]                           host_awsize,
output  [1:0]                           host_awburst,
output  [3:0]                           host_awcache,
output                                  host_awvalid,
input                                   host_awready,
output  [C_M_AXI_ID_WIDTH-1:0]          host_awid,
output                                  host_awlock,
output  [2:0]                           host_awprot,
output  [3:0]                           host_awqos,
output                                  host_awuser,
// axi write data
output  [C_M_AXI_DATA_WIDTH-1:0]        host_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      host_wstrb,
output                                  host_wlast,
output                                  host_wvalid,
input                                   host_wready,
output                                  host_wuser,
// axi write response
input   [1:0]                           host_bresp,
input                                   host_bvalid,
output                                  host_bready,
input   [C_M_AXI_ID_WIDTH-1:0]          host_bid,
input                                   host_buser,
// axi read address
output  [C_M_AXI_ADDR_WIDTH-1:0]        host_araddr,
output  [7:0]                           host_arlen,
output  [2:0]                           host_arsize,
output  [1:0]                           host_arburst,
output  [3:0]                           host_arcache,
output                                  host_arvalid,
input                                   host_arready,
output  [C_M_AXI_ID_WIDTH-1:0]          host_arid,
output                                  host_arlock,
output  [2:0]                           host_arprot,
output  [3:0]                           host_arqos,
output                                  host_aruser,
// axi read data
input   [C_M_AXI_DATA_WIDTH-1:0]        host_rdata,
input   [1:0]                           host_rresp,
input                                   host_rlast,
input                                   host_rvalid,
output                                  host_rready,
input   [C_M_AXI_ID_WIDTH-1:0]          host_rid,
input                                   host_ruser
);

wire                                model_start;
wire                                write_req;
wire [DMA_ADDR_WIDTH-1:0]           write_start_addr;
wire [C_M_AXI_ADDR_WIDTH-1:0]       blob_out_address;
wire [DMA_ADDR_WIDTH-1:0]           write_length;
wire                                write_done;
wire [C_M_AXI_DATA_WIDTH-1:0]       din;
wire                                din_rdy;
wire                                din_en;
wire                                din_eop;
wire                                dout_rdy;
wire [C_M_AXI_DATA_WIDTH-1:0]       dout;
wire [15:0]                         dout_en;
wire                                dout_eop;      
wire                                read_req_0;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_0;
wire [DMA_ADDR_WIDTH-1:0]           read_length_0;
wire                                read_ack_0;
wire                                read_req_1;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_1;
wire [DMA_ADDR_WIDTH-1:0]           read_length_1;
wire                                read_ack_1;
wire                                read_req_2;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_2;
wire [DMA_ADDR_WIDTH-1:0]           read_length_2;
wire                                read_ack_2;
wire                                read_req_3;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_3;
wire [DMA_ADDR_WIDTH-1:0]           read_length_3;
wire                                read_ack_3;
wire                                read_req_4;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_4;
wire [DMA_ADDR_WIDTH-1:0]           read_length_4;
wire                                read_ack_4;
wire                                read_req_5;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_5;
wire [DMA_ADDR_WIDTH-1:0]           read_length_5;
wire                                read_ack_5;
wire                                read_req_6;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_6;
wire [DMA_ADDR_WIDTH-1:0]           read_length_6;
wire                                read_ack_6;
wire                                read_req_7;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_7;
wire [DMA_ADDR_WIDTH-1:0]           read_length_7;
wire                                read_ack_7;
wire                                read_req_8;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_8;
wire [DMA_ADDR_WIDTH-1:0]           read_length_8;
wire                                read_ack_8;
wire                                read_req_9;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_9;
wire [DMA_ADDR_WIDTH-1:0]           read_length_9;
wire                                read_ack_9;
wire                                read_req_10;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_10;
wire [DMA_ADDR_WIDTH-1:0]           read_length_10;
wire                                read_ack_10;
wire                                read_req_11;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_11;
wire [DMA_ADDR_WIDTH-1:0]           read_length_11;
wire                                read_ack_11;
wire                                read_req_12;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_12;
wire [DMA_ADDR_WIDTH-1:0]           read_length_12;
wire                                read_ack_12;
wire                                read_req_13;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_13;
wire [DMA_ADDR_WIDTH-1:0]           read_length_13;
wire                                read_ack_13;
wire                                read_req_14;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_14;
wire [DMA_ADDR_WIDTH-1:0]           read_length_14;
wire                                read_ack_14;
wire                                read_req_15;
wire [DMA_ADDR_WIDTH-1:0]           read_start_addr_15;
wire [DMA_ADDR_WIDTH-1:0]           read_length_15;
wire                                read_ack_15;

  ctrl_regs # (
    .DMA_ADDR_WIDTH(DMA_ADDR_WIDTH),
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
  ) ctrl_regs_inst (
    .model_start(model_start),
    .write_start_addr(write_start_addr),
    .blob_out_address(blob_out_address),
    .S_AXI_ACLK(clk),
    .S_AXI_ARESETN(resetn),
    .S_AXI_AWADDR(s_axi_awaddr),
    .S_AXI_AWPROT(s_axi_awprot),
    .S_AXI_AWVALID(s_axi_awvalid),
    .S_AXI_AWREADY(s_axi_awready),
    .S_AXI_WDATA(s_axi_wdata),
    .S_AXI_WSTRB(s_axi_wstrb),
    .S_AXI_WVALID(s_axi_wvalid),
    .S_AXI_WREADY(s_axi_wready),
    .S_AXI_BRESP(s_axi_bresp),
    .S_AXI_BVALID(s_axi_bvalid),
    .S_AXI_BREADY(s_axi_bready),
    .S_AXI_ARADDR(s_axi_araddr),
    .S_AXI_ARPROT(s_axi_arprot),
    .S_AXI_ARVALID(s_axi_arvalid),
    .S_AXI_ARREADY(s_axi_arready),
    .S_AXI_RDATA(s_axi_rdata),
    .S_AXI_RRESP(s_axi_rresp),
    .S_AXI_RVALID(s_axi_rvalid),
    .S_AXI_RREADY(s_axi_rready)
  );


ddr3_dma_engineer #(
  .C_M_AXI_BURST_LEN    (C_M_AXI_BURST_LEN),
  .C_M_AXI_DATA_WIDTH   (C_M_AXI_DATA_WIDTH)
) ddr3_dma_engineer_inst(
.clk                 ( clk                ),
.ddr_clk             ( ddr_clk            ),
.rst                 ( ~resetn            ),
.write_req           ( write_req          ),
.write_start_addr    ( write_start_addr   ),
.write_length        ( write_length       ),
.write_done          ( write_done         ),
.din                 ( din                ),
.din_rdy             ( din_rdy            ),
.din_en              ( din_en             ),
.din_eop             ( din_eop            ),
.dout_rdy            ( dout_rdy           ),
.dout                ( dout               ),
.dout_en             ( dout_en            ),
.dout_eop            ( dout_eop           ),      
.read_req_0          ( read_req_0         ),
.read_start_addr_0   ( read_start_addr_0  ),
.read_length_0       ( read_length_0      ),
.read_ack_0          ( read_ack_0         ),
.read_req_1          ( read_req_1         ),
.read_start_addr_1   ( read_start_addr_1  ),
.read_length_1       ( read_length_1      ),
.read_ack_1          ( read_ack_1         ),
.read_req_2          ( read_req_2         ),
.read_start_addr_2   ( read_start_addr_2  ),
.read_length_2       ( read_length_2      ),
.read_ack_2          ( read_ack_2         ),
.read_req_3          ( read_req_3         ),
.read_start_addr_3   ( read_start_addr_3  ),
.read_length_3       ( read_length_3      ),
.read_ack_3          ( read_ack_3         ),
.read_req_4          ( read_req_4         ),
.read_start_addr_4   ( read_start_addr_4  ),
.read_length_4       ( read_length_4      ),
.read_ack_4          ( read_ack_4         ),
.read_req_5          ( read_req_5         ),
.read_start_addr_5   ( read_start_addr_5  ),
.read_length_5       ( read_length_5      ),
.read_ack_5          ( read_ack_5         ),
.read_req_6          ( read_req_6         ),
.read_start_addr_6   ( read_start_addr_6  ),
.read_length_6       ( read_length_6      ),
.read_ack_6          ( read_ack_6         ),
.read_req_7          ( read_req_7         ),
.read_start_addr_7   ( read_start_addr_7  ),
.read_length_7       ( read_length_7      ),
.read_ack_7          ( read_ack_7         ),
.read_req_8          ( read_req_8         ),
.read_start_addr_8   ( read_start_addr_8  ),
.read_length_8       ( read_length_8      ),
.read_ack_8          ( read_ack_8         ),
.read_req_9          ( read_req_9         ),
.read_start_addr_9   ( read_start_addr_9  ),
.read_length_9       ( read_length_9      ),
.read_ack_9          ( read_ack_9         ),
.read_req_10         ( read_req_10        ),
.read_start_addr_10  ( read_start_addr_10 ),
.read_length_10      ( read_length_10     ),
.read_ack_10         ( read_ack_10        ),
.read_req_11         ( read_req_11        ),
.read_start_addr_11  ( read_start_addr_11 ),
.read_length_11      ( read_length_11     ),
.read_ack_11         ( read_ack_11        ),
.read_req_12         ( read_req_12        ),
.read_start_addr_12  ( read_start_addr_12 ), 
.read_length_12      ( read_length_12     ),
.read_ack_12         ( read_ack_12        ),
.read_req_13         ( read_req_13        ),
.read_start_addr_13  ( read_start_addr_13 ),
.read_length_13      ( read_length_13     ),
.read_ack_13         ( read_ack_13        ),
.read_req_14         ( read_req_14        ),
.read_start_addr_14  ( read_start_addr_14 ),
.read_length_14      ( read_length_14     ),
.read_ack_14         ( read_ack_14        ),
.read_req_15         ( read_req_15        ),
.read_start_addr_15  ( read_start_addr_15 ),
.read_length_15      ( read_length_15     ),
.read_ack_15         ( read_ack_15        ),

.init_calib_complete ( init_calib_complete ),
.axi_aresetn         ( resetn            ),
.m_axi_awaddr        ( ddr_awaddr        ),
.m_axi_awlen         ( ddr_awlen         ),
.m_axi_awsize        ( ddr_awsize        ),
.m_axi_awburst       ( ddr_awburst       ),
.m_axi_awcache       ( ddr_awcache       ),
.m_axi_awvalid       ( ddr_awvalid       ),
.m_axi_awready       ( ddr_awready       ),
.m_axi_awid          ( ddr_awid          ),
.m_axi_awlock        ( ddr_awlock        ),
.m_axi_awprot        ( ddr_awprot        ),
.m_axi_awqos         ( ddr_awqos         ),
.m_axi_awuser        ( ddr_awuser        ),
.m_axi_wdata         ( ddr_wdata         ),
.m_axi_wstrb         ( ddr_wstrb         ),
.m_axi_wlast         ( ddr_wlast         ),
.m_axi_wvalid        ( ddr_wvalid        ),
.m_axi_wready        ( ddr_wready        ),
.m_axi_wuser         ( ddr_wuser         ),
.m_axi_bresp         ( ddr_bresp         ),
.m_axi_bvalid        ( ddr_bvalid        ),
.m_axi_bready        ( ddr_bready        ),
.m_axi_bid           ( ddr_bid           ),
.m_axi_buser         ( ddr_buser         ),
.m_axi_araddr        ( ddr_araddr        ),
.m_axi_arlen         ( ddr_arlen         ),
.m_axi_arsize        ( ddr_arsize        ),
.m_axi_arburst       ( ddr_arburst       ),
.m_axi_arcache       ( ddr_arcache       ),
.m_axi_arvalid       ( ddr_arvalid       ),
.m_axi_arready       ( ddr_arready       ),
.m_axi_arid          ( ddr_arid          ),
.m_axi_arlock        ( ddr_arlock        ),
.m_axi_arprot        ( ddr_arprot        ),
.m_axi_arqos         ( ddr_arqos         ),
.m_axi_aruser        ( ddr_aruser        ),
.m_axi_rdata         ( ddr_rdata         ),
.m_axi_rresp         ( ddr_rresp         ),
.m_axi_rlast         ( ddr_rlast         ),
.m_axi_rvalid        ( ddr_rvalid        ),
.m_axi_rready        ( ddr_rready        ),
.m_axi_rid           ( ddr_rid           ),
.m_axi_ruser         ( ddr_ruser         )
);

host_dma_engineer #(
  .C_M_AXI_BURST_LEN  (1),
  .C_M_AXI_DATA_WIDTH (C_M_AXI_DATA_WIDTH)
) host_dma_engineer_inst(
.clk                 ( clk                ),
.model_start         ( model_start        ),
.blob_out_address    ( blob_out_address   ),
.m_axi_aresetn       ( resetn             ),
.m_axi_awaddr        ( host_awaddr        ),
.m_axi_awlen         ( host_awlen         ),
.m_axi_awsize        ( host_awsize        ),
.m_axi_awburst       ( host_awburst       ),
.m_axi_awcache       ( host_awcache       ),
.m_axi_awvalid       ( host_awvalid       ),
.m_axi_awready       ( host_awready       ),
.m_axi_awid          ( host_awid          ),
.m_axi_awlock        ( host_awlock        ),
.m_axi_awprot        ( host_awprot        ),
.m_axi_awqos         ( host_awqos         ),
.m_axi_awuser        ( host_awuser        ),
.m_axi_wdata         ( host_wdata         ),
.m_axi_wstrb         ( host_wstrb         ),
.m_axi_wlast         ( host_wlast         ),
.m_axi_wvalid        ( host_wvalid        ),
.m_axi_wready        ( host_wready        ),
.m_axi_wuser         ( host_wuser         ),
.m_axi_bresp         ( host_bresp         ),
.m_axi_bvalid        ( host_bvalid        ),
.m_axi_bready        ( host_bready        ),
.m_axi_bid           ( host_bid           ),
.m_axi_buser         ( host_buser         ),
.m_axi_araddr        ( host_araddr        ),
.m_axi_arlen         ( host_arlen         ),
.m_axi_arsize        ( host_arsize        ),
.m_axi_arburst       ( host_arburst       ),
.m_axi_arcache       ( host_arcache       ),
.m_axi_arvalid       ( host_arvalid       ),
.m_axi_arready       ( host_arready       ),
.m_axi_arid          ( host_arid          ),
.m_axi_arlock        ( host_arlock        ),
.m_axi_arprot        ( host_arprot        ),
.m_axi_arqos         ( host_arqos         ),
.m_axi_aruser        ( host_aruser        ),
.m_axi_rdata         ( host_rdata         ),
.m_axi_rresp         ( host_rresp         ),
.m_axi_rlast         ( host_rlast         ),
.m_axi_rvalid        ( host_rvalid        ),
.m_axi_rready        ( host_rready        ),
.m_axi_rid           ( host_rid           ),
.m_axi_ruser         ( host_ruser         ),
.blob_dout_en        ( blob_dout_en       ),
.blob_dout           ( blob_dout          ),
.blob_dout_eop       ( blob_dout_eop      ),
.blob_dout_rdy       ( blob_dout_rdy      ),
.blob_din_en         ( blob_din_en        ),
.blob_din            ( blob_din           ),
.blob_din_eop        ( blob_din_eop       ),
.blob_din_rdy        ( blob_din_rdy       )
);

model model_inst
(
.clk                     ( clk                ),
.rst                     ( ~resetn            ),
.ddr_read_length_14      ( read_length_14     ),
.ddr_dout                ( dout               ),
.ddr_read_length_3       ( read_length_3      ),
.ddr_read_start_addr_8   ( read_start_addr_8  ),
.ddr_read_req_14         ( read_req_14        ),
.ddr_read_start_addr_6   ( read_start_addr_6  ),
.ddr_read_start_addr_7   ( read_start_addr_7  ),
.ddr_read_start_addr_4   ( read_start_addr_4  ),
.blob_dout_rdy           ( blob_dout_rdy      ),
.ddr_read_start_addr_2   ( read_start_addr_2  ),
.ddr_read_start_addr_3   ( read_start_addr_3  ),
.ddr_read_start_addr_0   ( read_start_addr_0  ),
.ddr_read_start_addr_1   ( read_start_addr_1  ),
.ddr_read_req_13         ( read_req_13        ),
.ddr_read_req_12         ( read_req_12        ),
.ddr_read_req_11         ( read_req_11        ),
.ddr_read_req_10         ( read_req_10        ),
.ddr_dout_eop            ( dout_eop           ),
.ddr_read_start_addr_12  ( read_start_addr_12 ),
.blob_dout_en            ( blob_dout_en       ),
.ddr_read_start_addr_9   ( read_start_addr_9  ),
.ddr_read_start_addr_10  ( read_start_addr_10 ),
.ddr_read_start_addr_11  ( read_start_addr_11 ),
.ddr_read_start_addr_5   ( read_start_addr_5  ),
.ddr_read_start_addr_13  ( read_start_addr_13 ),
.ddr_read_start_addr_14  ( read_start_addr_14 ),
.ddr_dout_en             ( dout_en            ),
.ddr_read_length_0       ( read_length_0      ),
.ddr_read_length_1       ( read_length_1      ),
.ddr_read_length_2       ( read_length_2      ),
.blob_din_rdy            ( blob_din_rdy       ),
.ddr_read_length_4       ( read_length_4      ),
.ddr_read_length_5       ( read_length_5      ),
.ddr_read_length_6       ( read_length_6      ),
.ddr_read_length_7       ( read_length_7      ),
.ddr_read_length_8       ( read_length_8      ),
.ddr_read_length_9       ( read_length_9      ),
.ddr_read_req_7          ( read_req_7         ),
.ddr_read_ack_14         ( read_ack_14        ),
.ddr_read_req_3          ( read_req_3         ),
.ddr_read_req_2          ( read_req_2         ),
.ddr_read_req_1          ( read_req_1         ),
.ddr_read_req_0          ( read_req_0         ),
.blob_dout_eop           ( blob_dout_eop      ),
.blob_dout               ( blob_dout          ),
.ddr_read_req_5          ( read_req_5         ),
.ddr_read_req_4          ( read_req_4         ),
.ddr_read_ack_12         ( read_ack_12        ),
.ddr_read_req_9          ( read_req_9         ),
.ddr_read_req_8          ( read_req_8         ),
.blob_din_eop            ( blob_din_eop       ),
.blob_din                ( blob_din           ),
.ddr_read_ack_13         ( read_ack_13        ),
.ddr_read_length_12      ( read_length_12     ),
.ddr_read_ack_10         ( read_ack_10        ),
.ddr_read_length_13      ( read_length_13     ),
.blob_din_en             ( blob_din_en        ),
.ddr_read_ack_11         ( read_ack_11        ),
.ddr_read_length_10      ( read_length_10     ),
.ddr_read_req_6          ( read_req_6         ),
.ddr_read_length_11      ( read_length_11     ),
.ddr_read_ack_8          ( read_ack_8         ),
.ddr_read_ack_9          ( read_ack_9         ),
.ddr_read_ack_4          ( read_ack_4         ),
.ddr_read_ack_5          ( read_ack_5         ),
.ddr_read_ack_6          ( read_ack_6         ),
.ddr_read_ack_7          ( read_ack_7         ),
.ddr_read_ack_0          ( read_ack_0         ),
.ddr_read_ack_1          ( read_ack_1         ),
.ddr_read_ack_2          ( read_ack_2         ),
.ddr_read_ack_3          ( read_ack_3         )
);

endmodule