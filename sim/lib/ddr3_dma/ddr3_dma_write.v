module ddr3_dma_write #(
  parameter DMA_ADDR_WIDTH = 27,
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_BURST_LEN = 16,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input					ddr_clk,
input                   rst,

//ddr3 Interface
input                   init_calib_complete,
input                   axi_aresetn,
// axi write address
output reg [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_awaddr,
output reg [7:0]                        m_axi_awlen,
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
output  [C_M_AXI_DATA_WIDTH-1:0]        m_axi_wdata,
output  [C_M_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb,
output reg                              m_axi_wlast,
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
  m_axi_awaddr = 0;
  m_axi_awlen = 8'h0;
  m_axi_awvalid = 1'b0;
  m_axi_wlast = 1'b0;
  m_axi_wvalid = 1'b0;
  write_done = 1'b0;
end

reg [DMA_ADDR_WIDTH-1:0]    write_left;
reg                         pre_done;
reg                         write_en;

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


wire                            ddr_write_fifo_wen;
wire                            ddr_write_fifo_rd;
wire                            ddr_write_fifo_afull;
wire                            ddr_write_fifo_empty;
wire  [C_M_AXI_DATA_WIDTH-1:0]  ddr_write_fifo_dout;

// There is no buffer here, so follow control happens outside
assign	ddr_write_fifo_wen	= din_en & write_en;
assign	din_rdy				= write_en & ~ddr_write_fifo_afull;

ddr_write_fifo	ddr_write_fifo_inst
(
    .rst(rst),
    .wr_clk(clk),
    .wr_en(ddr_write_fifo_wen),
    .din(din),

    .rd_clk(ddr_clk),
    .rd_en(ddr_write_fifo_rd),
    .dout(ddr_write_fifo_dout),

    .full(),
    .empty(ddr_write_fifo_empty),
    .prog_full(ddr_write_fifo_afull)
);


// Cross clock domain
reg                         write_req_q, write_req_q2;
reg [DMA_ADDR_WIDTH-1:0]    write_start_addr_q, write_start_addr_q2;
reg [DMA_ADDR_WIDTH-1:0]    write_length_q, write_length_q2;

always @(posedge ddr_clk)
begin
  write_req_q <= write_req;
  write_req_q2 <= write_req_q;
  write_start_addr_q <= write_start_addr;
  write_start_addr_q2 <= write_start_addr_q;
  write_length_q <= write_length;
  write_length_q2 <= write_length_q;
end

// Write addresss channel
assign m_axi_awid = 0;
assign m_axi_awprot = 0;
assign m_axi_awqos = 0;
assign m_axi_awlock = 0;
assign m_axi_awuser = 1;
assign m_axi_awcache = 4'b0010;
assign m_axi_awburst = 2'b01; // INCR burst
assign m_axi_awsize = 3'b110; // 64bytes burst, 1 beat on 512b width bus

// Count the number of burst needs to initiate
integer       burst_left = 0;
reg     [3:0] last_burst_len = 0;
reg           burst_write_active = 1'b0;
reg           start_single_burst_write = 1'b0;

always @(posedge ddr_clk)
begin
  if (~axi_aresetn)
    begin
      burst_left <= 0;
      last_burst_len <= 0;
    end
  else if (write_req_q2 && (burst_left == 0))
    begin
      burst_left <= write_length_q2[DMA_ADDR_WIDTH-1:4] + (|write_length_q2[3:0]);
      last_burst_len <= write_length_q2[3:0] - 4'b0001;
    end
  else if (start_single_burst_write)
    burst_left <= burst_left - 1;
  else
    burst_left <= burst_left;
end

// burst_write_active remains asserted
// until the burst write is accepted by the slave
always @(posedge ddr_clk)
begin
  if (~axi_aresetn || write_req_q2)
    burst_write_active <= 1'b0;
  else if (start_single_burst_write)
    burst_write_active <= 1'b1;
  else if (m_axi_bvalid && m_axi_bready)
    burst_write_active <= 1'b0;
end

// Start single burst until enough data in fifo,
// in case ddr_clk faster than clk and drain the fifo
always @(posedge ddr_clk)
begin
  if (~axi_aresetn)
    start_single_burst_write <= 1'b0;
  else if (~m_axi_awvalid && ~start_single_burst_write &&
           ~burst_write_active && (burst_left != 0) && ~ddr_write_fifo_empty)
    start_single_burst_write <= 1'b1;
  else
    start_single_burst_write <= 1'b0;
end

always @(posedge ddr_clk)
begin
  if (~axi_aresetn || write_req_q2)
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

always @(posedge ddr_clk)
begin
  if (~axi_aresetn)
    m_axi_awaddr <= 0;
  else if (write_req_q2)
    m_axi_awaddr <= {write_start_addr_q2, 6'b0} ;   // 64B address to 1B address
  else if (m_axi_awready && m_axi_awvalid)
    m_axi_awaddr <= m_axi_awaddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
  else
    m_axi_awaddr <= m_axi_awaddr;
end

always @(posedge ddr_clk)
begin
  if (burst_left == 1)
    m_axi_awlen <= last_burst_len;
  else
    m_axi_awlen <= 8'h0F;
end

// Write data channel
wire    wnext;
reg     sticky_wnext = 1'b0;
reg     burst_in_progress = 1'b0;
integer write_index = 0;

assign wnext = m_axi_wready & m_axi_wvalid;
assign ddr_write_fifo_rd = (wnext || sticky_wnext || start_single_burst_write) && ~ddr_write_fifo_empty;

// Stick wnext in case fifo is empty
always @(posedge ddr_clk)
begin
  case ({wnext, ddr_write_fifo_rd})
    2'b01: sticky_wnext <= 1'b0;
    2'b10: sticky_wnext <= 1'b1;
    default: sticky_wnext <= sticky_wnext;
  endcase
end

assign m_axi_wuser = 1'b1;
assign m_axi_wstrb = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
assign m_axi_wdata = ddr_write_fifo_dout;

always @(posedge ddr_clk)
begin
  if (~axi_aresetn || write_req_q2 )
    begin
      m_axi_wvalid <= 1'b0;
      burst_in_progress <= 1'b0;
    end
  // If previously not valid, start next transaction
  else if (~m_axi_wvalid && start_single_burst_write)
    begin
      m_axi_wvalid <= 1'b1;
      burst_in_progress <= 1'b1;
    end
  /* Once asserted, WVALID must wait until burst
   is complete with WLAST or fifo is empty*/
  else if (wnext && m_axi_wlast)
    begin
      m_axi_wvalid <= 1'b0;
      burst_in_progress <= 1'b0;
    end
  else
    begin
      m_axi_wvalid <= burst_in_progress && ~ddr_write_fifo_empty;
      burst_in_progress <= burst_in_progress;
    end
end

/* Burst length counter. Uses extra counter register bit to indicate terminal
 count to reduce decode logic */
always @(posedge ddr_clk)
begin
  if (~axi_aresetn || write_req_q2 || start_single_burst_write)
    begin
      write_index <= 0;
    end
  else if (wnext && (write_index != C_M_AXI_BURST_LEN-1))
    begin
      write_index <= write_index + 1;
    end
  else
    write_index <= write_index;
end

//WLAST generation on the MSB of a counter underflow
// WVALID logic, similar to the axi_awvalid always block above
always @(posedge ddr_clk)
begin
  if (~axi_aresetn || write_req_q2 )
    begin
      m_axi_wlast <= 1'b0;
    end
  // axi_wlast is asserted when the write index
  // count reaches the penultimate count to synchronize
  // with the last write data when write_index is b1111
  // else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)
  else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN >= 2) && wnext) || (C_M_AXI_BURST_LEN == 1 ))
    begin
      m_axi_wlast <= 1'b1;
    end
  // Deassrt axi_wlast when the last write data has been
  // accepted by the slave with a valid response
  else if (wnext)
    m_axi_wlast <= 1'b0;
  else if (m_axi_wlast && C_M_AXI_BURST_LEN == 1)
    m_axi_wlast <= 1'b0;
  else
    m_axi_wlast <= m_axi_wlast;
end

// Write response channel
assign  m_axi_bready = 1'b1;

endmodule
