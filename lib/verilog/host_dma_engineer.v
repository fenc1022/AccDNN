module host_dma_engineer #(
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 1, // Only support 1 for now
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512,
  parameter BLOB_SIZE = 4096
) (
input                                   clk,
input                                   model_start,
input   [C_M_AXI_ADDR_WIDTH-1:0]        blob_out_address,
// axi master Interface
input                   m_axi_aresetn,
// axi write address
output reg [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_awaddr,
output  [7:0]                           m_axi_awlen,
output  [2:0]                           m_axi_awsize,
output  [1:0]                           m_axi_awburst,
output  [3:0]                           m_axi_awcache,
output reg                              m_axi_awvalid,
output  [C_M_AXI_ID_WIDTH-1:0]          m_axi_awid,
output                                  m_axi_awlock,
output  [2:0]                           m_axi_awprot,
output  [3:0]                           m_axi_awqos,
output                                  m_axi_awuser,
input                                   m_axi_awready,
// axi write data
output  [C_M_AXI_DATA_WIDTH-1:0]        m_axi_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb,
output                                  m_axi_wlast,
output reg                              m_axi_wvalid,
output                                  m_axi_wuser,
input                                   m_axi_wready,
// axi write response
output   [1:0]                          m_axi_bresp,
output                                  m_axi_bvalid,
output   [C_M_AXI_ID_WIDTH-1:0]         m_axi_bid,
output                                  m_axi_buser,
input                                   m_axi_bready,
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

output reg                              blob_din_eop,
output reg [C_M_AXI_DATA_WIDTH-1:0]     blob_din,
output reg                              blob_din_en,
input                                   blob_din_rdy
);


wire                            host_write_fifo_empty;
wire  [C_M_AXI_DATA_WIDTH-1:0]  host_write_fifo_dout;
reg                             start_single_burst_write = 1'b0;

host_write_fifo	host_write_fifo_inst
(
    .srst(~m_axi_aresetn),
    .clk(clk),
    .wr_en(blob_dout_en),
    .din(blob_dout),
    .rd_en(start_single_burst_write),
    .dout(host_write_fifo_dout),

    .full(blob_dout_rdy),
    .empty(host_write_fifo_empty),
    .wr_rst_busy(),
  .rd_rst_busy()
);

// Write addresss channel
assign m_axi_awid = 0;
assign m_axi_awprot = 0;
assign m_axi_awqos = 0;
assign m_axi_awlock = 0;
assign m_axi_awuser = 1;
assign m_axi_awcache = 4'b0010;
assign m_axi_awburst = 2'b01; // INCR burst
assign m_axi_awsize = 3'b110; // 64bytes burst, 1 beat on 512b width bus
assign m_axi_awlen = 8'h0F;
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

// To do: Calculate write back address
always @(posedge clk)                                         
begin                                                                
  if (~m_axi_aresetn)                                                                                                    
    m_axi_awaddr <= 0;                                             
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
reg     model_start_q;
reg     model_start_rise;
integer burst_left = 0;

always @(posedge clk)
begin
  model_start_q <= model_start;
  model_start_rise <= model_start && ~model_start_q;  
end

always @(posedge clk)
begin
  if(~m_axi_aresetn)
    burst_left <= 0;
  else if (model_start_rise)
    // Assuming dividable
    burst_left <= BLOB_SIZE / C_M_AXI_DATA_WIDTH;  
  else if (m_axi_arvalid && m_axi_arready)
    burst_left <= burst_left - 1;
  else
    burst_left <= burst_left;
end

// Generate start_single_burst_read pulse
reg   start_single_burst_read = 1'b0;
reg   burst_read_active = 1'b0;

// burst_read_active remains asserted 
// until the burst read data received
always @(posedge clk)
begin
  if (~m_axi_aresetn || model_start_rise)
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
assign m_axi_arlen = 8'h0F;

always @(posedge clk)                                 
begin                                                                                                         
  if (~m_axi_aresetn || model_start_rise)                                         
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
    m_axi_araddr <= blob_out_address;                                                            
  else if (m_axi_arready && m_axi_arvalid)                                                                                       
    m_axi_araddr <= m_axi_araddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;                                                                               
  else                                                               
    m_axi_araddr <= m_axi_araddr;                                        
end

always @(posedge clk)
begin
  blob_din <= m_axi_rdata;
  blob_din_en <= m_axi_rvalid;
  if ((burst_left == 1) && m_axi_arvalid && m_axi_arready)
    blob_din_eop <= 1'b1;
  else if (blob_din_eop && blob_din_en && blob_din_rdy)  
    blob_din_eop <= 1'b0;
  else
    blob_din_eop <=blob_din_eop;
end  

endmodule