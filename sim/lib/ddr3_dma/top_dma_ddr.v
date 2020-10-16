
module top_dma_ddr #
(
    parameter C_AXI_ID_WIDTH = 4
)
(
  //write_dma Interface
  write_req,
  write_start_addr,
  write_length,
  write_done,
  din,
  din_rdy,
  din_en,
  din_eop,
  //read_dma Interface
  dout,
  dout_en,
  dout_eop,
  
  read_req_0,
  read_start_addr_0,
  read_length_0,
  read_ack_0,  
  
  read_req_1,
  read_start_addr_1,
  read_length_1,
  read_ack_1,  
  
  read_req_2,
  read_start_addr_2,
  read_length_2,
  read_ack_2, 
  
  read_req_3,
  read_start_addr_3,
  read_length_3,
  read_ack_3,  
  
  read_req_4,
  read_start_addr_4,
  read_length_4,
  read_ack_4, 
  
  read_req_5,
  read_start_addr_5,
  read_length_5,
  read_ack_5,
  
  read_req_6,
  read_start_addr_6,
  read_length_6,
  read_ack_6,
  
  read_req_7,
  read_start_addr_7,
  read_length_7,
  read_ack_7, 
  
  read_req_8,
  read_start_addr_8,
  read_length_8,
  read_ack_8, 
  
  read_req_9,
  read_start_addr_9,
  read_length_9,
  read_ack_9,  
  
  read_req_10,
  read_start_addr_10,
  read_length_10,
  read_ack_10,
  
  read_req_11,
  read_start_addr_11,
  read_length_11,
  read_ack_11,
  
  read_req_12,
  read_start_addr_12,
  read_length_12,
  read_ack_12, 
  
  read_req_13,
  read_start_addr_13,
  read_length_13,
  read_ack_13,
  
  read_req_14,
  read_start_addr_14,
  read_length_14,
  read_ack_14, 
  
  read_req_15,
  read_start_addr_15,
  read_length_15,
  read_ack_15, 
  
  clk,
  rst,
  ddr_rst,
  init_calib_complete
);

//write_dma Interface
input             write_req;
input  [26:0]     write_start_addr;
input  [26:0]     write_length;
output            write_done;
input  [511:0]    din;
output            din_rdy;
input             din_en;
input             din_eop;

//read_dma Interface
output     [511:0]      dout;
output     [15:0]       dout_en;
output                  dout_eop;      

input                   read_req_0;
input  [26:0]           read_start_addr_0;
input  [26:0]           read_length_0;
output                  read_ack_0;


input                   read_req_1;
input  [26:0]           read_start_addr_1;
input  [26:0]           read_length_1;
output                  read_ack_1;


input                   read_req_2;
input  [26:0]           read_start_addr_2;
input  [26:0]           read_length_2;
output                  read_ack_2;


input                   read_req_3;
input  [26:0]           read_start_addr_3;
input  [26:0]           read_length_3;
output                  read_ack_3;


input                   read_req_4;
input  [26:0]           read_start_addr_4;
input  [26:0]           read_length_4;
output                  read_ack_4;


input                   read_req_5;
input  [26:0]           read_start_addr_5;
input  [26:0]           read_length_5;
output                  read_ack_5;


input                   read_req_6;
input  [26:0]           read_start_addr_6;
input  [26:0]           read_length_6;
output                  read_ack_6;


input                   read_req_7;
input  [26:0]           read_start_addr_7;
input  [26:0]           read_length_7;
output                  read_ack_7;


input                   read_req_8;
input  [26:0]           read_start_addr_8;
input  [26:0]           read_length_8;
output                  read_ack_8;


input                   read_req_9;
input  [26:0]           read_start_addr_9;
input  [26:0]           read_length_9;
output                  read_ack_9;


input                   read_req_10;
input  [26:0]           read_start_addr_10;
input  [26:0]           read_length_10;
output                  read_ack_10;


input                   read_req_11;
input  [26:0]           read_start_addr_11;
input  [26:0]           read_length_11;
output                  read_ack_11;


input                   read_req_12;
input  [26:0]           read_start_addr_12;
input  [26:0]           read_length_12;
output                  read_ack_12;


input                   read_req_13;
input  [26:0]           read_start_addr_13;
input  [26:0]           read_length_13;
output                  read_ack_13;


input                   read_req_14;
input  [26:0]           read_start_addr_14;
input  [26:0]           read_length_14;
output                  read_ack_14;


input                   read_req_15;
input  [26:0]           read_start_addr_15;
input  [26:0]           read_length_15;
output                  read_ack_15;

output                  init_calib_complete;
input                   clk;
input                   rst;
input                   ddr_rst;
  
  wire                                  ddr_clk;

  // Slave Interface Write Address Ports
  wire [C_AXI_ID_WIDTH-1:0]        c0_ddr4_s_axi_awid;
  wire [31:0]                      c0_ddr4_s_axi_awaddr;
  wire [7:0]                       c0_ddr4_s_axi_awlen;
  wire [2:0]                       c0_ddr4_s_axi_awsize;
  wire [1:0]                       c0_ddr4_s_axi_awburst;
  wire [3:0]                       c0_ddr4_s_axi_awcache;
  wire [2:0]                       c0_ddr4_s_axi_awprot;
  wire                             c0_ddr4_s_axi_awvalid;
  wire                             c0_ddr4_s_axi_awready;
   // Slave Interface Write Data Ports
  wire [511:0]                     c0_ddr4_s_axi_wdata;
  wire [63:0]                      c0_ddr4_s_axi_wstrb;
  wire                             c0_ddr4_s_axi_wlast;
  wire                             c0_ddr4_s_axi_wvalid;
  wire                             c0_ddr4_s_axi_wready;
   // Slave Interface Write Response Ports
  wire                             c0_ddr4_s_axi_bready;
  wire [C_AXI_ID_WIDTH-1:0]        c0_ddr4_s_axi_bid;
  wire [1:0]                       c0_ddr4_s_axi_bresp;
  wire                             c0_ddr4_s_axi_bvalid;
   // Slave Interface Read Address Ports
  wire [C_AXI_ID_WIDTH-1:0]        c0_ddr4_s_axi_arid;
  wire [31:0]                      c0_ddr4_s_axi_araddr;
  wire [7:0]                       c0_ddr4_s_axi_arlen;
  wire [2:0]                       c0_ddr4_s_axi_arsize;
  wire [1:0]                       c0_ddr4_s_axi_arburst;
  wire [3:0]                       c0_ddr4_s_axi_arcache;
  wire                             c0_ddr4_s_axi_arvalid;
  wire                             c0_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  wire                             c0_ddr4_s_axi_rready;
  wire [C_AXI_ID_WIDTH:0]          c0_ddr4_s_axi_rid;
  wire [511:0]                     c0_ddr4_s_axi_rdata;
  wire [1:0]                       c0_ddr4_s_axi_rresp;
  wire                             c0_ddr4_s_axi_rlast;
  wire                             c0_ddr4_s_axi_rvalid;

// reset axi interface after ddr_clk runs
reg ddr4_aresetn = 1'b0;
always @(posedge ddr_clk)
begin
    ddr4_aresetn <= init_calib_complete;
end

ddr_mode_axi  u_ddr3_sim_top
(
  .c0_init_calib_complete              (init_calib_complete),
  .c0_ddr4_ui_clk                      (ddr_clk),
  .sys_rst                             (ddr_rst),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (ddr4_aresetn),
  .c0_ddr4_s_axi_awid                  (c0_ddr4_s_axi_awid),
  .c0_ddr4_s_axi_awaddr                (c0_ddr4_s_axi_awaddr),
  .c0_ddr4_s_axi_awlen                 (c0_ddr4_s_axi_awlen),
  .c0_ddr4_s_axi_awsize                (c0_ddr4_s_axi_awsize),
  .c0_ddr4_s_axi_awburst               (c0_ddr4_s_axi_awburst),
  .c0_ddr4_s_axi_awlock                (1'b0),
  .c0_ddr4_s_axi_awcache               (c0_ddr4_s_axi_awcache),
  .c0_ddr4_s_axi_awprot                (c0_ddr4_s_axi_awprot),
  .c0_ddr4_s_axi_awqos                 (4'b0),
  .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
  .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
  .c0_ddr4_s_axi_wstrb                 (c0_ddr4_s_axi_wstrb),
  .c0_ddr4_s_axi_wlast                 (c0_ddr4_s_axi_wlast),
  .c0_ddr4_s_axi_wvalid                (c0_ddr4_s_axi_wvalid),
  .c0_ddr4_s_axi_wready                (c0_ddr4_s_axi_wready),
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
  .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
  .c0_ddr4_s_axi_bvalid                (c0_ddr4_s_axi_bvalid),
  .c0_ddr4_s_axi_bready                (c0_ddr4_s_axi_bready),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  (c0_ddr4_s_axi_arid),
  .c0_ddr4_s_axi_araddr                (c0_ddr4_s_axi_araddr),
  .c0_ddr4_s_axi_arlen                 (c0_ddr4_s_axi_arlen),
  .c0_ddr4_s_axi_arsize                (c0_ddr4_s_axi_arsize),
  .c0_ddr4_s_axi_arburst               (c0_ddr4_s_axi_arburst),
  .c0_ddr4_s_axi_arlock                (1'b0),
  .c0_ddr4_s_axi_arcache               (c0_ddr4_s_axi_arcache),
  .c0_ddr4_s_axi_arprot                (3'b0),
  .c0_ddr4_s_axi_arqos                 (4'b0),
  .c0_ddr4_s_axi_arvalid               (c0_ddr4_s_axi_arvalid),
  .c0_ddr4_s_axi_arready               (c0_ddr4_s_axi_arready),
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (c0_ddr4_s_axi_rid),
  .c0_ddr4_s_axi_rdata                 (c0_ddr4_s_axi_rdata),
  .c0_ddr4_s_axi_rresp                 (c0_ddr4_s_axi_rresp),
  .c0_ddr4_s_axi_rlast                 (c0_ddr4_s_axi_rlast),
  .c0_ddr4_s_axi_rvalid                (c0_ddr4_s_axi_rvalid),
  .c0_ddr4_s_axi_rready                (c0_ddr4_s_axi_rready)
);


ddr3_dma_engineer  u_ddr3_dma_engineer 
(
    .clk                     ( clk                   ),
    .ddr_clk                 ( ddr_clk               ),
    .rst                     ( rst                   ),
    .axi_aresetn             ( ~ddr_rst              ),
    .init_calib_complete     ( init_calib_complete   ),
    .write_req               ( write_req             ),
    .write_start_addr        ( write_start_addr      ),
    .write_length            ( write_length          ),
    .write_done              ( write_done            ),
    .din                     ( din                   ),
    .din_en                  ( din_en                ),
    .din_eop                 ( din_eop               ),
    .din_rdy                 ( din_rdy               ),
    .dout                    ( dout                  ),
    .dout_en                 ( dout_en               ),
    .dout_eop                ( dout_eop              ),
    .dout_rdy                ( 1'b1                  ),
    .read_req_0              ( read_req_0            ),
    .read_start_addr_0       ( read_start_addr_0     ),
    .read_length_0           ( read_length_0         ),
    .read_req_1              ( read_req_1            ),
    .read_start_addr_1       ( read_start_addr_1     ),
    .read_length_1           ( read_length_1         ),
    .read_req_2              ( read_req_2            ),
    .read_start_addr_2       ( read_start_addr_2     ),
    .read_length_2           ( read_length_2         ),
    .read_req_3              ( read_req_3            ),
    .read_start_addr_3       ( read_start_addr_3     ),
    .read_length_3           ( read_length_3         ),
    .read_req_4              ( read_req_4            ),
    .read_start_addr_4       ( read_start_addr_4     ),
    .read_length_4           ( read_length_4         ),
    .read_req_5              ( read_req_5            ),
    .read_start_addr_5       ( read_start_addr_5     ),
    .read_length_5           ( read_length_5         ),
    .read_req_6              ( read_req_6            ),
    .read_start_addr_6       ( read_start_addr_6     ),
    .read_length_6           ( read_length_6         ),
    .read_req_7              ( read_req_7            ),
    .read_start_addr_7       ( read_start_addr_7     ),
    .read_length_7           ( read_length_7         ),
    .read_req_8              ( read_req_8            ),
    .read_start_addr_8       ( read_start_addr_8     ),
    .read_length_8           ( read_length_8         ),
    .read_req_9              ( read_req_9            ),
    .read_start_addr_9       ( read_start_addr_9     ),
    .read_length_9           ( read_length_9         ),
    .read_req_10             ( read_req_10           ),
    .read_start_addr_10      ( read_start_addr_10    ),
    .read_length_10          ( read_length_10        ),
    .read_req_11             ( read_req_11           ),
    .read_start_addr_11      ( read_start_addr_11    ),
    .read_length_11          ( read_length_11        ),
    .read_req_12             ( read_req_12           ),
    .read_start_addr_12      ( read_start_addr_12    ),
    .read_length_12          ( read_length_12        ),
    .read_req_13             ( read_req_13           ),
    .read_start_addr_13      ( read_start_addr_13    ),
    .read_length_13          ( read_length_13        ),
    .read_req_14             ( read_req_14           ),
    .read_start_addr_14      ( read_start_addr_14    ),
    .read_length_14          ( read_length_14        ),
    .read_req_15             ( read_req_15           ),
    .read_start_addr_15      ( read_start_addr_15    ),
    .read_length_15          ( read_length_15        ),
    .read_ack_0              ( read_ack_0            ),
    .read_ack_1              ( read_ack_1            ),
    .read_ack_2              ( read_ack_2            ),
    .read_ack_3              ( read_ack_3            ),
    .read_ack_4              ( read_ack_4            ),
    .read_ack_5              ( read_ack_5            ),
    .read_ack_6              ( read_ack_6            ),
    .read_ack_7              ( read_ack_7            ),
    .read_ack_8              ( read_ack_8            ),
    .read_ack_9              ( read_ack_9            ),
    .read_ack_10             ( read_ack_10           ),
    .read_ack_11             ( read_ack_11           ),
    .read_ack_12             ( read_ack_12           ),
    .read_ack_13             ( read_ack_13           ),
    .read_ack_14             ( read_ack_14           ),
    .read_ack_15             ( read_ack_15           ),
    // Master Interface Write Address Ports
    .m_axi_awready                     (c0_ddr4_s_axi_awready),
    .m_axi_awid                        (c0_ddr4_s_axi_awid),
    .m_axi_awaddr                      (c0_ddr4_s_axi_awaddr),
    .m_axi_awlen                       (c0_ddr4_s_axi_awlen),
    .m_axi_awsize                      (c0_ddr4_s_axi_awsize),
    .m_axi_awburst                     (c0_ddr4_s_axi_awburst),
    .m_axi_awlock                      (),
    .m_axi_awcache                     (c0_ddr4_s_axi_awcache),
    .m_axi_awprot                      (c0_ddr4_s_axi_awprot),
    .m_axi_awvalid                     (c0_ddr4_s_axi_awvalid),
    // Master Interface Write Data Ports
    .m_axi_wready                      (c0_ddr4_s_axi_wready),
    .m_axi_wdata                       (c0_ddr4_s_axi_wdata),
    .m_axi_wstrb                       (c0_ddr4_s_axi_wstrb),
    .m_axi_wlast                       (c0_ddr4_s_axi_wlast),
    .m_axi_wvalid                      (c0_ddr4_s_axi_wvalid),
    // Master Interface Write Response Ports
    .m_axi_bid                         (c0_ddr4_s_axi_bid),
    .m_axi_bresp                       (c0_ddr4_s_axi_bresp),
    .m_axi_bvalid                      (c0_ddr4_s_axi_bvalid),
    .m_axi_bready                      (c0_ddr4_s_axi_bready),
    // Master Interface Read Address Ports
    .m_axi_arready                     (c0_ddr4_s_axi_arready),
    .m_axi_arid                        (c0_ddr4_s_axi_arid),
    .m_axi_araddr                      (c0_ddr4_s_axi_araddr),
    .m_axi_arlen                       (c0_ddr4_s_axi_arlen),
    .m_axi_arsize                      (c0_ddr4_s_axi_arsize),
    .m_axi_arburst                     (c0_ddr4_s_axi_arburst),
    .m_axi_arlock                      (),
    .m_axi_arcache                     (c0_ddr4_s_axi_arcache),
    .m_axi_arprot                      (),
    .m_axi_arvalid                     (c0_ddr4_s_axi_arvalid),
    // Master Interface Read Data Ports
    .m_axi_rid                         (c0_ddr4_s_axi_rid),
    .m_axi_rresp                       (c0_ddr4_s_axi_rresp),
    .m_axi_rvalid                      (c0_ddr4_s_axi_rvalid),
    .m_axi_rdata                       (c0_ddr4_s_axi_rdata),
    .m_axi_rlast                       (c0_ddr4_s_axi_rlast),
    .m_axi_rready                      (c0_ddr4_s_axi_rready)
);

endmodule
