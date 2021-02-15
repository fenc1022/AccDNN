`timescale 1 ns / 1 ps

`define TOTAL_INPUT_COUNT   128     // 32x32x4x16/512
`define TOTAL_WEIGHT_COUNT  4568    // TODO: How to find weight size for each model

module host_dma_engineer #(
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 1, // Only support 1 for now
  parameter integer DMA_ADDR_WIDTH = 27,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                                   clk,
input                                   load_weights, // ddr_write_req in simulation testbench
input                                   model_start,
input   [31:0]                          image_num,
input   [C_M_AXI_ADDR_WIDTH-1:0]        host_weights_addr,
input   [C_M_AXI_ADDR_WIDTH-1:0]        host_src_addr,
input   [C_M_AXI_ADDR_WIDTH-1:0]        host_dst_addr,
// axi master Interface
input                   m_axi_aresetn,
// axi write address
(* MARK_DEBUG="true" *)output reg [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_awaddr,
output  [7:0]                           m_axi_awlen,
output  [2:0]                           m_axi_awsize,
output  [1:0]                           m_axi_awburst,
output  [3:0]                           m_axi_awcache,
(* MARK_DEBUG="true" *)output reg                              m_axi_awvalid,
output  [C_M_AXI_ID_WIDTH-1:0]          m_axi_awid,
output                                  m_axi_awlock,
output  [2:0]                           m_axi_awprot,
output  [3:0]                           m_axi_awqos,
output                                  m_axi_awuser,
(* MARK_DEBUG="true" *)input                                   m_axi_awready,
// axi write data
(* MARK_DEBUG="true" *)output  [C_M_AXI_DATA_WIDTH-1:0]        m_axi_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb,
(* MARK_DEBUG="true" *)output                                  m_axi_wlast,
(* MARK_DEBUG="true" *)output reg                              m_axi_wvalid,
output                                  m_axi_wuser,
(* MARK_DEBUG="true" *)input                                   m_axi_wready,
// axi write response
input   [1:0]                           m_axi_bresp,
(* MARK_DEBUG="true" *)input                                   m_axi_bvalid,
input   [C_M_AXI_ID_WIDTH-1:0]          m_axi_bid,
input                                   m_axi_buser,
output                                  m_axi_bready,
// axi read address
output reg [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_araddr,
output  [7:0]                           m_axi_arlen,
output  [2:0]                           m_axi_arsize,
output  [1:0]                           m_axi_arburst,
output  [3:0]                           m_axi_arcache,
output reg                              m_axi_arvalid,
output  [C_M_AXI_ID_WIDTH-1:0]          m_axi_arid,
output                                  m_axi_arlock,
output  [2:0]                           m_axi_arprot,
output  [3:0]                           m_axi_arqos,
output                                  m_axi_aruser,
input                                   m_axi_arready,
// axi read data
input   [C_M_AXI_DATA_WIDTH-1:0]        m_axi_rdata,
input   [1:0]                           m_axi_rresp,
input                                   m_axi_rlast,
input                                   m_axi_rvalid,
input   [C_M_AXI_ID_WIDTH-1:0]          m_axi_rid,
input                                   m_axi_ruser,
output                                  m_axi_rready,

// blob interface
input	                                  blob_dout_eop,
input  [C_M_AXI_DATA_WIDTH-1:0]	        blob_dout,
input	                                  blob_dout_en,
output	                                blob_dout_rdy,

output                                  blob_din_eop,
output     [C_M_AXI_DATA_WIDTH-1:0]     blob_din,
output                                  blob_din_en,
input                                   blob_din_rdy,

// ddr interface
output  [DMA_ADDR_WIDTH-1:0]            ddr_write_length,
output  [C_M_AXI_DATA_WIDTH-1:0]        ddr_din,
input                                   ddr_din_rdy,
output                                  ddr_din_en,
output                                  ddr_din_eop
);


(* MARK_DEBUG="true" *)wire                            host_write_fifo_empty;
(* MARK_DEBUG="true" *)wire                            host_write_fifo_full;
wire  [C_M_AXI_DATA_WIDTH-1:0]  host_write_fifo_dout;
(* MARK_DEBUG="true" *)reg                             start_single_burst_write = 1'b0;
reg     model_start_q;
reg     model_start_rise;
reg     load_weights_q;
reg     load_weights_rise;
reg     is_weights = 1'b0;  // 1: transfer weight to ddr; 0: transfer blob to model
integer burst_left = 0;
integer cycle_cnt = 0;
reg     start_single_burst_read = 1'b0;
reg     burst_read_active = 1'b0;

host_write_fifo	host_write_fifo_inst
(
    .srst(~m_axi_aresetn),
    .clk(clk),
    .wr_en(blob_dout_en),
    .din(blob_dout),
    .rd_en(start_single_burst_write),
    .dout(host_write_fifo_dout),

    .full(host_write_fifo_full),
    .empty(host_write_fifo_empty),
    .wr_rst_busy(),
  .rd_rst_busy()
);

assign blob_dout_rdy = ~host_write_fifo_full;

// Write addresss channel
assign m_axi_awid = 0;
assign m_axi_awprot = 0;
assign m_axi_awqos = 0;
assign m_axi_awlock = 0;
assign m_axi_awuser = 1;
assign m_axi_awcache = 4'b0010;
assign m_axi_awburst = 2'b01; // INCR burst
assign m_axi_awsize = 3'b110; // 64bytes burst, 1 beat on 512b width bus
assign m_axi_awlen = 8'h00; // awlen+1 beat tranfer
assign m_axi_wlast = 1'b1;   
assign m_axi_wuser = 1'b1;
assign m_axi_wstrb = {(C_M_AXI_DATA_WIDTH/8){1'b1}};

always @(posedge clk)
begin
  if (~m_axi_aresetn)
    start_single_burst_write <= 1'b0;
  else if (~m_axi_awvalid && ~start_single_burst_write && ~host_write_fifo_empty)
    start_single_burst_write <= 1'b1;
  else
    start_single_burst_write <= 1'b0;
end

always @(posedge clk)                                   
begin                                                                   
  if (~m_axi_aresetn)                                           
    begin                                                            
      m_axi_awvalid <= 1'b0;                                           
    end                                                              
  // If previously not valid , start next transaction                
  else if (~m_axi_awvalid && start_single_burst_write)                 
    begin                                                            
      m_axi_awvalid <= 1'b1;                                           
    end                                                              
  /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid      
  must wait until transaction is accepted */                         
  else if (m_axi_awready && m_axi_awvalid)                             
    begin                                                            
      m_axi_awvalid <= 1'b0;                                           
    end                                                              
  else                                                               
    m_axi_awvalid <= m_axi_awvalid;                                      
end                                                                

// Write back address
always @(posedge clk)                                         
begin                                                                
  if (~m_axi_aresetn)                                                                                                    
    m_axi_awaddr <= 0;
  else if (model_start_rise)
    m_axi_awaddr <= host_dst_addr;
  else if (m_axi_awready && m_axi_awvalid)
    m_axi_awaddr <= m_axi_awaddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;                                                                               
  else                                                               
    m_axi_awaddr <= m_axi_awaddr;                                        
end

// Write data channel
assign m_axi_wdata = host_write_fifo_dout;

always @(posedge clk)                                                      
begin                                                                             
  if (~m_axi_aresetn == 0)                                                                                                                               
    m_axi_wvalid <= 1'b0;                                                                                                                         
  // If previously not valid, start next transaction                              
  else if (~m_axi_wvalid && start_single_burst_write)                                                                                                     
    m_axi_wvalid <= 1'b1;                                                                                                                               
  /* Once asserted, WVALID must wait until data is accepted */                                 
  else if (m_axi_wready & m_axi_wvalid)                                                  
    m_axi_wvalid <= 1'b0;                                                          
  else                                                                          
    m_axi_wvalid <= m_axi_wvalid;                                                   
end                                                                               

// Write response channel
assign m_axi_bready = 1'b1;

// Count the number of burst needs to initate
always @(posedge clk)
begin
  model_start_q    <= model_start;
  model_start_rise <= model_start && ~model_start_q;
  load_weights_q    <= load_weights;
  load_weights_rise <= load_weights && ~load_weights_q;
end

always @(posedge clk)
begin
  if(~m_axi_aresetn)
    burst_left <= 0;
  else if (model_start_rise)
    burst_left <= `TOTAL_INPUT_COUNT * image_num;
  else if (load_weights_rise)
    burst_left <= `TOTAL_WEIGHT_COUNT;
  else if (m_axi_arvalid && m_axi_arready)
    burst_left <= burst_left - 1;
  else
    burst_left <= burst_left;
  
  if(~m_axi_aresetn)
    cycle_cnt <= 0;
  else if (model_start_rise)
    cycle_cnt <= `TOTAL_INPUT_COUNT * image_num;
  else if (load_weights_rise)
    cycle_cnt <= `TOTAL_WEIGHT_COUNT;
  else if (m_axi_rvalid && m_axi_rready)
    cycle_cnt <= cycle_cnt - 1;
  else
    cycle_cnt <= cycle_cnt;

  if(~m_axi_aresetn)
    is_weights <= 1'b0;
  else if (model_start_rise)
    is_weights <= 1'b0;
  else if (load_weights_rise)
    is_weights <= 1'b1;
  
end

// Generate start_single_burst_read pulse

// burst_read_active remains asserted 
// until the burst read data received
always @(posedge clk)
begin
  if (~m_axi_aresetn || model_start_rise || load_weights_rise)
    burst_read_active <= 1'b0;
  else if (start_single_burst_read)
    burst_read_active <= 1'b1;
  else if (m_axi_rvalid && m_axi_rready && m_axi_rlast)
    burst_read_active <= 1'b0;
end

always @(posedge clk)
begin
  if (~m_axi_aresetn)
    start_single_burst_read <= 1'b0;
  else if (~m_axi_arvalid && ~start_single_burst_read &&
           ~burst_read_active && (burst_left != 0))
    start_single_burst_read <= 1'b1;
  else
    start_single_burst_read <= 1'b0;
end

// Read address channel
assign m_axi_arid = 0;
assign m_axi_arprot = 0;
assign m_axi_arqos = 0;
assign m_axi_arlock = 0;
assign m_axi_arburst = 2'b01; // INCR burst mode
assign m_axi_arcache = 4'b0010;
assign m_axi_aruser = 1'b1;
assign m_axi_arsize = 3'b110; // 64bytes burst, 1 beat on 512b width bus
assign m_axi_arlen = 8'h00;  // arlen+1 beat tranfer

always @(posedge clk)                                 
begin                                                                                                         
  if (~m_axi_aresetn || model_start_rise || load_weights_rise)                                         
    begin                                                          
      m_axi_arvalid <= 1'b0;                                         
    end                                                            
  // If previously not valid , start next transaction              
  else if (~m_axi_arvalid && start_single_burst_read)                
    begin                                                          
      m_axi_arvalid <= 1'b1;                                         
    end                                                            
  else if (m_axi_arready && m_axi_arvalid)                           
    begin                                                          
      m_axi_arvalid <= 1'b0;                                         
    end                                                            
  else                                                             
    m_axi_arvalid <= m_axi_arvalid;                                    
end

always @(posedge clk)                                         
begin                                                                
  if (~m_axi_aresetn)                                                                                                    
    m_axi_araddr <= 0;                                             
  else if (model_start_rise)
    m_axi_araddr <= host_src_addr;                                                            
  else if (load_weights_rise)
    m_axi_araddr <= host_weights_addr;
  else if (m_axi_arready && m_axi_arvalid)                                                                                       
    m_axi_araddr <= m_axi_araddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;                                                                               
  else                                                               
    m_axi_araddr <= m_axi_araddr;                                        
end

assign blob_din = m_axi_rdata;
assign blob_din_en = m_axi_rvalid & (!is_weights);
assign blob_din_eop = blob_din_en & blob_din_rdy & (cycle_cnt == 1) & (!is_weights);

assign ddr_din = m_axi_rdata;
assign ddr_din_en = m_axi_rvalid & is_weights;
assign ddr_din_eop = ddr_din_en & ddr_din_rdy & (cycle_cnt == 1) & is_weights;

assign m_axi_rready = is_weights ? ddr_din_rdy : blob_din_rdy;
assign ddr_write_length = `TOTAL_WEIGHT_COUNT;

endmodule