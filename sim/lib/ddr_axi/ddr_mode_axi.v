module ddr_mode_axi #
(
    parameter         nCK_PER_CLK             = 4,
    parameter         APP_ADDR_WIDTH          = 30,
    parameter         APP_DATA_WIDTH          = 512,
    parameter         APP_MASK_WIDTH          = 64,

    parameter C_S_AXI_ID_WIDTH                = 4,
                                              // Width of all master and slave ID signals.
                                              // # = >= 1.
    parameter C_S_AXI_ADDR_WIDTH              = 32,
                                              // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                              // M_AXI_ARADDR for all SI/MI slots.
                                              // # = 32.
    parameter C_S_AXI_DATA_WIDTH              = 512,
                                              // Width of WDATA and RDATA on SI slot.
                                              // Must be <= APP_DATA_WIDTH.
                                              // # = 32, 64, 128, 256.
    parameter BURST_MODE                      = "8",     // Burst length
    parameter C_S_AXI_SUPPORTS_NARROW_BURST   = 0,
                                              // Indicates whether to instatiate upsizer
                                              // Range: 0, 1
    parameter C_RD_WR_ARB_ALGORITHM           = "RD_PRI_REG",
                                             // Indicates the Arbitration
                                             // Allowed values - "TDM", "ROUND_ROBIN",
                                             // "RD_PRI_REG", "RD_PRI_REG_STARVE_LIMIT"
    parameter C_S_AXI_REG_EN0                 = 20'h00000,
                                             // Instatiates register slices before upsizer.
                                             // The type of register is specified for each channel
                                             // in a vector. 4 bits per channel are used.
                                             // C_S_AXI_REG_EN0[03:00] = AW CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[07:04] =  W CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[11:08] =  B CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[15:12] = AR CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[20:16] =  R CHANNEL REGISTER SLICE
                                             // Possible values for each channel are:
                                             //
                                             //   0 => BYPASS    = The channel is just wired through the
                                             //                    module.
                                             //   1 => FWD       = The master VALID and payload signals
                                             //                    are registrated.
                                             //   2 => REV       = The slave ready signal is registrated
                                             //   3 => FWD_REV   = Both FWD and REV
                                             //   4 => SLAVE_FWD = All slave side signals and master
                                             //                    VALID and payload are registrated.
                                             //   5 => SLAVE_RDY = All slave side signals and master
                                             //                    READY are registrated.
                                             //   6 => INPUTS    = Slave and Master side inputs are
                                             //                    registrated.
    parameter C_S_AXI_REG_EN1                 = 20'h00000,
                                             // Same as C_S_AXI_REG_EN0, but this register is after
                                             // the upsizer
    parameter ECC                             = "OFF"
) 
   (
   input  sys_rst,
   input  clk,
   // iob<>DDR4 signals
   output                              c0_init_calib_complete,
  //  output                              c0_ddr4_ui_clk,

   // Slave Interface Write Address Ports
   input                              c0_ddr4_aresetn,
   input  [C_S_AXI_ID_WIDTH-1:0]      c0_ddr4_s_axi_awid,
   input  [C_S_AXI_ADDR_WIDTH-1:0]    c0_ddr4_s_axi_awaddr,
   input  [7:0]                       c0_ddr4_s_axi_awlen,
   input  [2:0]                       c0_ddr4_s_axi_awsize,
   input  [1:0]                       c0_ddr4_s_axi_awburst,
   input  [0:0]                       c0_ddr4_s_axi_awlock,
   input  [3:0]                       c0_ddr4_s_axi_awcache,
   input  [2:0]                       c0_ddr4_s_axi_awprot,
   input  [3:0]                       c0_ddr4_s_axi_awqos,
   input                              c0_ddr4_s_axi_awvalid,
   output                             c0_ddr4_s_axi_awready,
   // Slave Interface Write Data Ports
   input  [C_S_AXI_DATA_WIDTH-1:0]    c0_ddr4_s_axi_wdata,
   input  [C_S_AXI_DATA_WIDTH/8-1:0]  c0_ddr4_s_axi_wstrb,
   input                              c0_ddr4_s_axi_wlast,
   input                              c0_ddr4_s_axi_wvalid,
   output                             c0_ddr4_s_axi_wready,
   // Slave Interface Write Response Ports
   input                              c0_ddr4_s_axi_bready,
   output [C_S_AXI_ID_WIDTH-1:0]      c0_ddr4_s_axi_bid,
   output [1:0]                       c0_ddr4_s_axi_bresp,
   output                             c0_ddr4_s_axi_bvalid,
   // Slave Interface Read Address Ports
   input  [C_S_AXI_ID_WIDTH-1:0]      c0_ddr4_s_axi_arid,
   input  [C_S_AXI_ADDR_WIDTH-1:0]    c0_ddr4_s_axi_araddr,
   input  [7:0]                       c0_ddr4_s_axi_arlen,
   input  [2:0]                       c0_ddr4_s_axi_arsize,
   input  [1:0]                       c0_ddr4_s_axi_arburst,
   input  [0:0]                       c0_ddr4_s_axi_arlock,
   input  [3:0]                       c0_ddr4_s_axi_arcache,
   input  [2:0]                       c0_ddr4_s_axi_arprot,
   input  [3:0]                       c0_ddr4_s_axi_arqos,
   input                              c0_ddr4_s_axi_arvalid,
   output                             c0_ddr4_s_axi_arready,
   // Slave Interface Read Data Ports
   input                              c0_ddr4_s_axi_rready,
   output [C_S_AXI_ID_WIDTH-1:0]      c0_ddr4_s_axi_rid,
   output [C_S_AXI_DATA_WIDTH-1:0]    c0_ddr4_s_axi_rdata,
   output [1:0]                       c0_ddr4_s_axi_rresp,
   output                             c0_ddr4_s_axi_rlast,
   output                             c0_ddr4_s_axi_rvalid
);

  wire c0_ddr4_clk;
  wire c0_init_done;

  // assign c0_ddr4_ui_clk = c0_ddr4_clk;
  assign c0_init_calib_complete = c0_init_done;

  wire [APP_ADDR_WIDTH-1:0]              c0_ddr4_app_addr;
  wire [2:0]                             c0_ddr4_app_cmd;
  wire                                   c0_ddr4_app_en;
  wire                                   c0_ddr4_app_wdf_end;
  wire                                   c0_ddr4_app_wdf_wren;
  wire                                   c0_ddr4_app_rd_data_end;
  wire                                   c0_ddr4_app_rd_data_valid;
  wire                                   c0_ddr4_app_rdy;
  wire                                   c0_ddr4_app_wdf_rdy;
  wire [APP_DATA_WIDTH-1:0]              c0_ddr4_app_wdf_data;
  wire [APP_DATA_WIDTH-1:0]              c0_ddr4_app_rd_data;


ddr4_v2_2_9_axi #
  (
   .C_ECC                         (ECC),
   .C_S_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
   .C_S_AXI_ADDR_WIDTH            (C_S_AXI_ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH            (C_S_AXI_DATA_WIDTH),
   .C_MC_DATA_WIDTH               (APP_DATA_WIDTH),
   .C_MC_ADDR_WIDTH               (APP_ADDR_WIDTH),
   .C_MC_BURST_MODE               (BURST_MODE),
   .C_MC_nCK_PER_CLK              (nCK_PER_CLK),
   .C_S_AXI_SUPPORTS_NARROW_BURST (C_S_AXI_SUPPORTS_NARROW_BURST),
   .C_RD_WR_ARB_ALGORITHM         (C_RD_WR_ARB_ALGORITHM),
   .C_S_AXI_REG_EN0               (C_S_AXI_REG_EN0),
   .C_S_AXI_REG_EN1               (C_S_AXI_REG_EN1)
  )
  u_ddr_axi
    (
     .aclk                                   (c0_ddr4_clk),

     // Slave Interface Write Address Ports
     .aresetn                                (c0_ddr4_aresetn),
     .s_axi_awid                             (c0_ddr4_s_axi_awid),
     .s_axi_awaddr                           (c0_ddr4_s_axi_awaddr),
     .s_axi_awlen                            (c0_ddr4_s_axi_awlen),
     .s_axi_awsize                           (c0_ddr4_s_axi_awsize),
     .s_axi_awburst                          (c0_ddr4_s_axi_awburst),
     .s_axi_awlock                           (c0_ddr4_s_axi_awlock),
     .s_axi_awcache                          (c0_ddr4_s_axi_awcache),
     .s_axi_awprot                           (c0_ddr4_s_axi_awprot),
     .s_axi_awqos                            (c0_ddr4_s_axi_awqos),
     .s_axi_awvalid                          (c0_ddr4_s_axi_awvalid),
     .s_axi_awready                          (c0_ddr4_s_axi_awready),
     // Slave Interface Write Data Ports
     .s_axi_wdata                            (c0_ddr4_s_axi_wdata),
     .s_axi_wstrb                            (c0_ddr4_s_axi_wstrb),
     .s_axi_wlast                            (c0_ddr4_s_axi_wlast),
     .s_axi_wvalid                           (c0_ddr4_s_axi_wvalid),
     .s_axi_wready                           (c0_ddr4_s_axi_wready),
     // Slave Interface Write Response Ports
     .s_axi_bid                              (c0_ddr4_s_axi_bid),
     .s_axi_bresp                            (c0_ddr4_s_axi_bresp),
     .s_axi_bvalid                           (c0_ddr4_s_axi_bvalid),
     .s_axi_bready                           (c0_ddr4_s_axi_bready),
     // Slave Interface Read Address Ports
     .s_axi_arid                             (c0_ddr4_s_axi_arid),
     .s_axi_araddr                           (c0_ddr4_s_axi_araddr),
     .s_axi_arlen                            (c0_ddr4_s_axi_arlen),
     .s_axi_arsize                           (c0_ddr4_s_axi_arsize),
     .s_axi_arburst                          (c0_ddr4_s_axi_arburst),
     .s_axi_arlock                           (c0_ddr4_s_axi_arlock),
     .s_axi_arcache                          (c0_ddr4_s_axi_arcache),
     .s_axi_arprot                           (c0_ddr4_s_axi_arprot),
     .s_axi_arqos                            (c0_ddr4_s_axi_arqos),
     .s_axi_arvalid                          (c0_ddr4_s_axi_arvalid),
     .s_axi_arready                          (c0_ddr4_s_axi_arready),
     // Slave Interface Read Data Ports
     .s_axi_rid                              (c0_ddr4_s_axi_rid),
     .s_axi_rdata                            (c0_ddr4_s_axi_rdata),
     .s_axi_rresp                            (c0_ddr4_s_axi_rresp),
     .s_axi_rlast                            (c0_ddr4_s_axi_rlast),
     .s_axi_rvalid                           (c0_ddr4_s_axi_rvalid),
     .s_axi_rready                           (c0_ddr4_s_axi_rready),

     // MC Master Interface
     //CMD PORT
     .mc_app_en                              (c0_ddr4_app_en),
     .mc_app_cmd                             (c0_ddr4_app_cmd),
     .mc_app_sz                              (),
     .mc_app_addr                            (c0_ddr4_app_addr),
     .mc_app_hi_pri                          (),
     .mc_app_autoprecharge                   (),
     .mc_app_rdy                             (c0_ddr4_app_rdy),
     .mc_init_complete                       (c0_init_done),

     //DATA PORT
     .mc_app_wdf_wren                        (c0_ddr4_app_wdf_wren),
     .mc_app_wdf_mask                        (),
     .mc_app_wdf_data                        (c0_ddr4_app_wdf_data),
     .mc_app_wdf_end                         (c0_ddr4_app_wdf_end),
     .mc_app_wdf_rdy                         (c0_ddr4_app_wdf_rdy),

     .mc_app_rd_valid                        (c0_ddr4_app_rd_data_valid),
     .mc_app_rd_data                         (c0_ddr4_app_rd_data),
     .mc_app_rd_end                          (c0_ddr4_app_rd_data_end),
     .mc_app_ecc_multiple_err                (c0_ddr4_app_ecc_multiple_err)
     );

ddr_mode  u_ddr4_sim_top
(
.init_done           (c0_init_done),
.app_addr            (c0_ddr4_app_addr),
.app_cmd             (c0_ddr4_app_cmd),
.app_en              (c0_ddr4_app_en),
.app_wdf_data        (c0_ddr4_app_wdf_data),
.app_wdf_end         (c0_ddr4_app_wdf_end),
.app_wdf_wren        (c0_ddr4_app_wdf_wren),
.app_rd_data         (c0_ddr4_app_rd_data),
.app_rd_data_end     (c0_ddr4_app_rd_data_end),
.app_rd_data_valid   (c0_ddr4_app_rd_data_valid),
.app_rdy             (c0_ddr4_app_rdy),
.app_wdf_rdy         (c0_ddr4_app_wdf_rdy),
.clk_ddr             (c0_ddr4_clk),
.reset               (sys_rst),
.clk                 (clk)
);

endmodule