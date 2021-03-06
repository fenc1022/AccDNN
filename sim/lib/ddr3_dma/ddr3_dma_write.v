module ddr3_dma_write #(
  parameter DMA_ADDR_WIDTH = 27,
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 1,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input					ddr_clk,
input                   rst,

//ddr3 Interface
// axi write address
output reg [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_awaddr,
output     [7:0]                        m_axi_awlen,
output     [2:0]                        m_axi_awsize,
output     [1:0]                        m_axi_awburst,
output     [3:0]                        m_axi_awcache,
output reg                              m_axi_awvalid,
input                                   m_axi_awready,
output     [C_M_AXI_ID_WIDTH-1:0]       m_axi_awid,
output                                  m_axi_awlock,
output     [2:0]                        m_axi_awprot,
output     [3:0]                        m_axi_awqos,
output     [0:0]                        m_axi_awuser,
// axi write data
output reg [C_M_AXI_DATA_WIDTH-1:0]     m_axi_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb,
output                                  m_axi_wlast,
output reg                              m_axi_wvalid,
input                                   m_axi_wready,
output                                  m_axi_wuser,
// axi write response
input   [1:0]                           m_axi_bresp,
input                                   m_axi_bvalid,
output                                  m_axi_bready,
input   [C_M_AXI_ID_WIDTH:0]            m_axi_bid,
input   [0:0]                           m_axi_buser,

//dma Interface
input                           write_req,
input  [DMA_ADDR_WIDTH-1:0]     write_start_addr,
input  [DMA_ADDR_WIDTH-1:0]     write_length,
output reg                      write_done,
output                          din_rdy,
input                           din_en,
input  [C_M_AXI_DATA_WIDTH-1:0] din,
input                           din_eop
);

// Initialize registered output
initial
begin
  write_done = 1'b0;
end

reg [DMA_ADDR_WIDTH-1:0]    write_left;
reg                         pre_done;
reg                         write_en;

reg           start_single_burst_write = 1'b0;
wire          ddr_write_fifo_wen;
wire          ddr_write_fifo_empty;
wire          ddr_write_fifo_afull;
wire [31:0]   unconnected;

// Assuming the write_length is always >= 2
always @ (posedge clk)
begin
  if(write_req)
    write_left  <= write_length;
  else if (din_en & write_en)
    write_left  <= write_left - 1;
end

always @ (posedge clk)
begin
  if (write_req)
    pre_done    <= 0;
  else if (din_en & (~|write_left [DMA_ADDR_WIDTH-1:2]) & write_left [1] & (~write_left [0]))
    pre_done    <= 1;
end

always @ (posedge clk)
begin
  if (rst)
    write_en    <= 0;
  else if (write_req)
    write_en    <= 1;
  else if (din_en & (pre_done | din_eop))
    write_en    <= 0;
end

always @ (posedge clk)
  write_done    <= din_en & write_en & (pre_done | din_eop);

// There is no buffer here, so follow control happens outside
assign	ddr_write_fifo_wen	= din_en & write_en;
assign	din_rdy				= write_en & ~ddr_write_fifo_afull;

wire [C_M_AXI_DATA_WIDTH-1:0] ddr_write_fifo_dout;

ddr_write_fifo	ddr_write_fifo_inst
(
    .srst(rst),
    .wr_clk(clk),
    .wr_en(ddr_write_fifo_wen),
    .din(din),

    .rd_clk(ddr_clk),
    .rd_en(start_single_burst_write),
    .dout({unconnected, ddr_write_fifo_dout}),

    .empty(ddr_write_fifo_empty),
    .prog_full(ddr_write_fifo_afull)
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
assign m_axi_awlen = 0;  // awlen+1 beat tranfer
assign m_axi_wlast = 1'b1;
assign m_axi_wuser = 1'b1;
assign m_axi_wstrb = {(C_M_AXI_DATA_WIDTH/8){1'b1}};

always @(posedge clk)
begin
  if (rst)
    start_single_burst_write <= 1'b0;
  else if (~m_axi_awvalid && ~start_single_burst_write && ~ddr_write_fifo_empty)
    start_single_burst_write <= 1'b1;
  else
    start_single_burst_write <= 1'b0;
end

always @(posedge clk)                                   
begin                                                                   
  if (rst)                                           
    begin                                                            
      m_axi_awvalid <= 1'b0;
      m_axi_wdata <= 0;
    end                                                              
  // If previously not valid , start next transaction                
  else if (~m_axi_awvalid && start_single_burst_write)                 
    begin                                                            
      m_axi_awvalid <= 1'b1;
      m_axi_wdata <= ddr_write_fifo_dout;
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

always @(posedge clk)                                         
begin
  if (rst)                                                                                                    
    m_axi_awaddr <= 0;
  else if (write_req)
    m_axi_awaddr <= write_start_addr;
  else if (m_axi_awready && m_axi_awvalid)
    m_axi_awaddr <= m_axi_awaddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;                                                                               
  else                                                               
    m_axi_awaddr <= m_axi_awaddr;                                        
end

// Write data channel
always @(posedge clk)
begin
  if (rst)                                                                                                                               
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
assign  m_axi_bready = 1'b1;

endmodule
