module ddr3_dma_read #(
  parameter DMA_ADDR_WIDTH = 27,
  parameter C_M_AXI_ID_WIDTH = 4,
  parameter C_M_AXI_ADDR_WIDTH = 32,
  parameter C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input                   ddr_clk,
input                   rst,
//ddr3 Interface
input                   init_calib_complete,
input                   axi_aresetn,
// axi read address
(* MARK_DEBUG="true" *)output     [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_araddr,
(* MARK_DEBUG="true" *)output     [7:0]                        m_axi_arlen,
output     [2:0]                        m_axi_arsize,
output     [1:0]                        m_axi_arburst,
output     [3:0]                        m_axi_arcache,
(* MARK_DEBUG="true" *)output                                  m_axi_arvalid,
(* MARK_DEBUG="true" *)input                                   m_axi_arready,
output     [C_M_AXI_ID_WIDTH-1:0]       m_axi_arid,
output                                  m_axi_arlock,
output     [2:0]                        m_axi_arprot,
output     [3:0]                        m_axi_arqos,
output     [0:0]                        m_axi_aruser,
// axi read data
(* MARK_DEBUG="true" *)input   [C_M_AXI_DATA_WIDTH-1:0]        m_axi_rdata,
input   [1:0]                           m_axi_rresp,
(* MARK_DEBUG="true" *)input                                   m_axi_rlast,
(* MARK_DEBUG="true" *)input                                   m_axi_rvalid,
(* MARK_DEBUG="true" *)output                                  m_axi_rready,
input   [C_M_AXI_ID_WIDTH:0]            m_axi_rid,
input   [0:0]                           m_axi_ruser,

//dma Interface
(* MARK_DEBUG="true" *)input                                   dout_rdy,
(* MARK_DEBUG="true" *)output reg [C_M_AXI_DATA_WIDTH-1:0]     dout,
(* MARK_DEBUG="true" *)output reg [15:0]                       dout_en,
(* MARK_DEBUG="true" *)output reg                              dout_eop,

input                           read_req_0,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_0,
input  [DMA_ADDR_WIDTH-1:0]     read_length_0,
output reg                      read_ack_0,

input                           read_req_1,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_1,
input  [DMA_ADDR_WIDTH-1:0]     read_length_1,
output reg                      read_ack_1,

input                           read_req_2,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_2,
input  [DMA_ADDR_WIDTH-1:0]     read_length_2,
output reg                      read_ack_2,


input                           read_req_3,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_3,
input  [DMA_ADDR_WIDTH-1:0]     read_length_3,
output reg                      read_ack_3,

input                           read_req_4,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_4,
input  [DMA_ADDR_WIDTH-1:0]     read_length_4,
output reg                      read_ack_4,

input                           read_req_5,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_5,
input  [DMA_ADDR_WIDTH-1:0]     read_length_5,
output reg                      read_ack_5,

input                           read_req_6,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_6,
input  [DMA_ADDR_WIDTH-1:0]     read_length_6,
output reg                      read_ack_6,


input                           read_req_7,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_7,
input  [DMA_ADDR_WIDTH-1:0]     read_length_7,
output reg                      read_ack_7,

input                           read_req_8,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_8,
input  [DMA_ADDR_WIDTH-1:0]     read_length_8,
output reg                      read_ack_8,

input                           read_req_9,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_9,
input  [DMA_ADDR_WIDTH-1:0]     read_length_9,
output reg                      read_ack_9,

input                           read_req_10,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_10,
input  [DMA_ADDR_WIDTH-1:0]     read_length_10,
output reg                      read_ack_10,

input                           read_req_11,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_11,
input  [DMA_ADDR_WIDTH-1:0]     read_length_11,
output reg                      read_ack_11,

input                           read_req_12,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_12,
input  [DMA_ADDR_WIDTH-1:0]     read_length_12,
output reg                      read_ack_12,

input                           read_req_13,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_13,
input  [DMA_ADDR_WIDTH-1:0]     read_length_13,
output reg                      read_ack_13,

input                           read_req_14,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_14,
input  [DMA_ADDR_WIDTH-1:0]     read_length_14,
output reg                      read_ack_14,

input                           read_req_15,
input  [DMA_ADDR_WIDTH-1:0]     read_start_addr_15,
input  [DMA_ADDR_WIDTH-1:0]     read_length_15,
output reg                      read_ack_15
);

localparam WIDTH = 16;
// localparam MAX_ACK_DELAY = 4;
localparam MAX_ARLEN = 256;

// Initialize registered output
initial
begin
  dout = 0;
  dout_en = 0;
  dout_eop = 0;
  read_ack_0  = 0;
  read_ack_1  = 0;
  read_ack_2  = 0;
  read_ack_3  = 0;
  read_ack_4  = 0;
  read_ack_5  = 0;
  read_ack_6  = 0;
  read_ack_7  = 0;
  read_ack_8  = 0;
  read_ack_9  = 0;
  read_ack_10 = 0;
  read_ack_11 = 0;
  read_ack_12 = 0;
  read_ack_13 = 0;
  read_ack_14 = 0;
  read_ack_15 = 0;
end

// arbiter
wire    [WIDTH-1:0]     read_req_w;
reg     [WIDTH-1:0]     read_req;
wire    [2*WIDTH-1:0]   double_read_req;
reg     [WIDTH-1:0]     base;
reg                     busy;
wire					read_done;
reg     [2*WIDTH-1:0]   double_read_ack;
wire    [WIDTH-1:0]     read_ack;
reg		[WIDTH-1:0]     read_ack_reg;
reg		[WIDTH-1:0]		read_ack_keep;
reg		[15:0]			read_allow;
reg		[15:0]			read_ack_dl1;
reg		[15:0]			read_ack_dl2;
reg		[15:0]			read_ack_dl3;
reg		[15:0]			read_ack_dl4;

always @ (posedge clk)
begin
    read_ack_dl1	<= read_ack_reg;
    read_ack_dl2	<= read_ack_dl1;
    read_ack_dl3	<= read_ack_dl2;
    read_ack_dl4	<= read_ack_dl3;
end

integer i;
always @ (posedge clk)
begin
    for (i = 0; i < 16; i = i + 1)
    begin
        if (rst)
            read_allow [i]	<= 1'b1;
        else if (read_ack_reg [i])
            read_allow [i]	<= 1'b0;
        else if (read_ack_dl4 [i])
            read_allow [i]	<= 1'b1;
    end
end

assign read_req_w   = { read_req_15,read_req_14,read_req_13,read_req_12,
                        read_req_11,read_req_10,read_req_9,read_req_8,
                        read_req_7,read_req_6,read_req_5,read_req_4,
                        read_req_3,read_req_2,read_req_1,read_req_0
                        };

always @ (posedge clk)
    read_req    <= read_req_w & read_allow;

assign double_read_req  = {read_req,read_req};  


always @ (posedge clk)
begin
  if (rst)
    busy <= 1'b0;
  else if(read_done)
    busy <= 1'b0;
  else if((|read_req)) 
    busy <= 1'b1;
end

always @ (posedge clk)
begin
  if(rst)
    base <= 16'b1;
  else if (|read_ack)
    base <= {read_ack[WIDTH-2:0],read_ack[WIDTH-1]};
end

always @ (posedge clk)
begin
  if(rst)
    double_read_ack <= 0;
  else if (~busy)
    double_read_ack <= double_read_req & ~(double_read_req-base);
  else
    double_read_ack <= 0;
end

assign read_ack = double_read_ack[WIDTH-1:0] | double_read_ack[2*WIDTH-1:WIDTH];  

always @ (posedge clk)
  read_ack_reg   <= read_ack;

always @ (*)
begin
  read_ack_0    <= read_ack_reg[0];
  read_ack_1    <= read_ack_reg[1];
  read_ack_2    <= read_ack_reg[2];
  read_ack_3    <= read_ack_reg[3];
  read_ack_4    <= read_ack_reg[4];
  read_ack_5    <= read_ack_reg[5];
  read_ack_6    <= read_ack_reg[6];
  read_ack_7    <= read_ack_reg[7];
  read_ack_8    <= read_ack_reg[8];
  read_ack_9    <= read_ack_reg[9];
  read_ack_10   <= read_ack_reg[10];
  read_ack_11   <= read_ack_reg[11];
  read_ack_12   <= read_ack_reg[12];
  read_ack_13   <= read_ack_reg[13];
  read_ack_14   <= read_ack_reg[14];
  read_ack_15   <= read_ack_reg[15];
end

(* MARK_DEBUG="true" *)reg     [DMA_ADDR_WIDTH-1:0]    read_addr; // in 64B uint
(* MARK_DEBUG="true" *)reg     [DMA_ADDR_WIDTH-1:0]    read_length;
(* MARK_DEBUG="true" *)reg     [DMA_ADDR_WIDTH-1:0]    read_start_addr;
(* MARK_DEBUG="true" *)reg					            read_init;
(* MARK_DEBUG="true" *)reg     [DMA_ADDR_WIDTH-1:0]    read_left = 0;
(* MARK_DEBUG="true" *)reg                             read_en;
(* MARK_DEBUG="true" *)wire				            ddr_read_addr_send;

always @ (posedge clk)
begin
  case (1'b1)
    read_ack[0]  : {read_length, read_start_addr} <= {read_length_0,  read_start_addr_0};
    read_ack[1]  : {read_length, read_start_addr} <= {read_length_1,  read_start_addr_1};
    read_ack[2]  : {read_length, read_start_addr} <= {read_length_2,  read_start_addr_2};
    read_ack[3]  : {read_length, read_start_addr} <= {read_length_3,  read_start_addr_3};
    read_ack[4]  : {read_length, read_start_addr} <= {read_length_4,  read_start_addr_4};
    read_ack[5]  : {read_length, read_start_addr} <= {read_length_5,  read_start_addr_5};
    read_ack[6]  : {read_length, read_start_addr} <= {read_length_6,  read_start_addr_6};
    read_ack[7]  : {read_length, read_start_addr} <= {read_length_7,  read_start_addr_7};
    read_ack[8]  : {read_length, read_start_addr} <= {read_length_8,  read_start_addr_8};
    read_ack[9]  : {read_length, read_start_addr} <= {read_length_9,  read_start_addr_9};
    read_ack[10] : {read_length, read_start_addr} <= {read_length_10, read_start_addr_10};
    read_ack[11] : {read_length, read_start_addr} <= {read_length_11, read_start_addr_11};
    read_ack[12] : {read_length, read_start_addr} <= {read_length_12, read_start_addr_12};
    read_ack[13] : {read_length, read_start_addr} <= {read_length_13, read_start_addr_13};
    read_ack[14] : {read_length, read_start_addr} <= {read_length_14, read_start_addr_14};
    read_ack[15] : {read_length, read_start_addr} <= {read_length_15, read_start_addr_15};	
  endcase	
end

always @ (posedge clk)
begin
    read_init	<= |read_ack;

    if (read_init)
        read_ack_keep	<= read_ack_reg;
end

always @ (posedge clk)
begin
  if(read_init)
	read_addr <= read_start_addr;
  else if (ddr_read_addr_send)
	  read_addr <= read_addr + MAX_ARLEN;
end

// Assuming the read_length is always >= 2
always @ (posedge clk)
begin
  if (rst)
    read_left <= 0;
  else begin
    if(read_init)
      read_left  <= read_length;
    else if (ddr_read_addr_send) begin
      if (read_left > MAX_ARLEN)
        read_left  <= read_left - MAX_ARLEN;
      else
        read_left  <= 0;
    end
  end
end

always @ (posedge clk)
begin
  if (rst)
    read_en    <= 0;
  else if (read_init)
    read_en    <= 1;
  else if (read_done)
    read_en    <= 0;
end

(* MARK_DEBUG="true" *)reg     read_credit_val;
(* MARK_DEBUG="true" *)wire    ddr_read_addr_fifo_afull;
(* MARK_DEBUG="true" *)wire    ddr_read_addr_fifo_empty;

assign	read_done			= ddr_read_addr_send & (read_left <= MAX_ARLEN);
assign	ddr_read_addr_send	= ~ddr_read_addr_fifo_afull & read_en;

(* MARK_DEBUG="true" *)reg [7:0] burst_len;
always @(*) begin
  if (read_left > MAX_ARLEN)
    burst_len <= 8'hFF;
  else if (read_left > 0)
    burst_len <= read_left - 1;
  else
    burst_len <= 0;
end

ddr_read_addr_fifo	ddr_read_addr_fifo
(
	.srst(rst),
	.wr_clk(clk),
	.wr_en(ddr_read_addr_send),
	.din({read_addr, burst_len}),
	.rd_clk(ddr_clk),
	.rd_en(m_axi_arvalid),
	.dout({m_axi_araddr[C_M_AXI_ADDR_WIDTH-1:6], m_axi_arlen}), // 1bit less than DIN
	.full(),
	.empty(ddr_read_addr_fifo_empty),
	.prog_full(ddr_read_addr_fifo_afull)
);

assign m_axi_arvalid = m_axi_arready & (~ddr_read_addr_fifo_empty); // & read_credit_val;
assign m_axi_araddr[5:0] = 6'b0;

// Read address channel
assign m_axi_arid = 0;
assign m_axi_arprot = 0;
assign m_axi_arqos = 0;
assign m_axi_arlock = 0;
assign m_axi_arburst = 2'b01; // INCR burst mode
assign m_axi_arcache = 4'b0010;
assign m_axi_aruser = 1'b1;
assign m_axi_arsize = 3'b110; // 64bytes burst, 1 beat on 512b width bus

// Generate dma interface signals
(* MARK_DEBUG="true" *)wire						        ddr_read_data_fifo_rd;
(* MARK_DEBUG="true" *)wire	[C_M_AXI_DATA_WIDTH-1:0]    ddr_read_data_fifo_out;
(* MARK_DEBUG="true" *)wire						        ddr_read_data_fifo_empty;
(* MARK_DEBUG="true" *)wire						        ddr_read_info_fifo_empty;
(* MARK_DEBUG="true" *)wire						        ddr_read_sync_fifo_empty;
(* MARK_DEBUG="true" *)wire						        last_read_dly;
(* MARK_DEBUG="true" *)wire	[WIDTH-1:0]			  read_ack_dly;

(* MARK_DEBUG="true" *)wire [7:0] cur_burst_len; // 0~255, burst length - 1
(* MARK_DEBUG="true" *)wire       ddr_read_info_fifo_rd;
(* MARK_DEBUG="true" *)wire       last_beat;
(* MARK_DEBUG="true" *)reg  [7:0] burst_left = 0; // 0~255

// read data_fifo cur_burst_len-1 times alone
// then read info_fifo and data_fifo simutaniously the last time
assign last_beat = (burst_left == 1) | (cur_burst_len == 0);
assign ddr_read_info_fifo_rd = ddr_read_data_fifo_rd & last_beat;

always @(posedge clk) begin
  if (ddr_read_data_fifo_rd & (burst_left == 0))
    burst_left <= cur_burst_len;
  else if (ddr_read_data_fifo_rd)
    burst_left <= burst_left - 1;
  else
    burst_left <= burst_left;
end

ddr_read_info_fifo	ddr_read_info_fifo
(
    .srst(rst),
    .clk(clk),
    .wr_en(ddr_read_addr_send),
    .din({read_done, read_ack_keep, burst_len}),

    .rd_en(ddr_read_info_fifo_rd),
    .dout({last_read_dly, read_ack_dly, cur_burst_len}),

    .full(),
    .empty(ddr_read_info_fifo_empty)
);


assign	ddr_read_data_fifo_rd	= ~ddr_read_data_fifo_empty & dout_rdy;

(* MARK_DEBUG="true" *)wire  ddr_read_data_fifo_full;
ddr_read_data_fifo	ddr_read_data_fifo
(
    .srst(rst),
    .wr_clk(ddr_clk),
    .wr_en(m_axi_rvalid & ~rst),
    .din(m_axi_rdata),

    .rd_clk(clk),
    .rd_en(ddr_read_data_fifo_rd),
    .dout(ddr_read_data_fifo_out),

    .full(ddr_read_data_fifo_full),
    .empty(ddr_read_data_fifo_empty)
);

assign  m_axi_rready = ~ddr_read_data_fifo_full;

always @ (posedge clk)
begin
    dout		<= ddr_read_data_fifo_out;
    dout_en		<= {16{ddr_read_data_fifo_rd}} & read_ack_dly;
    dout_eop	<= last_read_dly & last_beat & ddr_read_data_fifo_rd;
end


(* MARK_DEBUG="true" *)wire					ddr_read_sync_fifo_rd;

ASYNC_FIFO_WRAPPER # (3, 1) ddr_read_sync_fifo
(
    .asyn_reset_i(rst),
    .w_clk_i(clk),
    .w_en_i(ddr_read_data_fifo_rd),
    .w_din_i(1'b0),

    .r_clk_i(ddr_clk),
    .r_en_i(ddr_read_sync_fifo_rd),
    .r_dout_o(),

    .w_full_o(),
    .r_empty_o(ddr_read_sync_fifo_empty)
);

(* MARK_DEBUG="true" *)wire    ddr_read_en;
assign	ddr_read_sync_fifo_rd = ~ddr_read_sync_fifo_empty;
assign	ddr_read_en = m_axi_arready & m_axi_arvalid;

(* MARK_DEBUG="true" *)reg		[8:0]		read_credit;

always @ (posedge ddr_clk)
    read_credit_val	<= ~&read_credit [8:3];

always @ (posedge ddr_clk)
begin
    if (rst)
        read_credit	<= 500;
    else
        read_credit	<= read_credit + ddr_read_sync_fifo_rd - ddr_read_en;
end

endmodule