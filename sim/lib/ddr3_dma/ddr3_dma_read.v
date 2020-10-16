`define C_M_AXI_ADDR_WIDTH 32

module ddr3_dma_read #(
  parameter C_S_AXI_ID_WIDTH = 4,
  parameter integer C_M_AXI_BURST_LEN = 1, // Only support 1 for now
  parameter integer C_M_AXI_DATA_WIDTH = 512
) (
input                   clk,
input                   ddr_clk,
input                   rst,
//ddr3 Interface
input                   init_calib_complete,
input                   axi_aresetn,
// axi read address
output reg [`C_M_AXI_ADDR_WIDTH-1:0]       m_axi_araddr,
output reg [7:0]                           m_axi_arlen,
output  [2:0]                           m_axi_arsize,
output  [1:0]                           m_axi_arburst,
output  [3:0]                           m_axi_arcache,
output                                  m_axi_arvalid,
input                                   m_axi_arready,
output  [C_S_AXI_ID_WIDTH-1:0]          m_axi_arid,
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
input   [C_S_AXI_ID_WIDTH:0]            m_axi_rid,
input   [0:0]                           m_axi_ruser,

//dma Interface
//output                  ddr_read,
input                   dout_rdy,
output reg [511:0]          dout,
output reg [15:0]           dout_en,
output reg                  dout_eop,

input                   read_req_0,
input  [26:0]           read_start_addr_0,
input  [26:0]           read_length_0,
output reg                 read_ack_0,

input                   read_req_1,
input  [26:0]           read_start_addr_1,
input  [26:0]           read_length_1,
output reg                 read_ack_1,

input                   read_req_2,
input  [26:0]           read_start_addr_2,
input  [26:0]           read_length_2,
output reg                 read_ack_2,


input                   read_req_3,
input  [26:0]           read_start_addr_3,
input  [26:0]           read_length_3,
output reg                 read_ack_3,

input                   read_req_4,
input  [26:0]           read_start_addr_4,
input  [26:0]           read_length_4,
output reg                 read_ack_4,

input                   read_req_5,
input  [26:0]           read_start_addr_5,
input  [26:0]           read_length_5,
output reg                 read_ack_5,

input                   read_req_6,
input  [26:0]           read_start_addr_6,
input  [26:0]           read_length_6,
output reg                 read_ack_6,


input                   read_req_7,
input  [26:0]           read_start_addr_7,
input  [26:0]           read_length_7,
output reg                 read_ack_7,

input                   read_req_8,
input  [26:0]           read_start_addr_8,
input  [26:0]           read_length_8,
output reg                 read_ack_8,

input                   read_req_9,
input  [26:0]           read_start_addr_9,
input  [26:0]           read_length_9,
output reg                 read_ack_9,

input                   read_req_10,
input  [26:0]           read_start_addr_10,
input  [26:0]           read_length_10,
output reg                 read_ack_10,

input                   read_req_11,
input  [26:0]           read_start_addr_11,
input  [26:0]           read_length_11,
output reg                 read_ack_11,

input                   read_req_12,
input  [26:0]           read_start_addr_12,
input  [26:0]           read_length_12,
output reg                 read_ack_12,

input                   read_req_13,
input  [26:0]           read_start_addr_13,
input  [26:0]           read_length_13,
output reg                 read_ack_13,

input                   read_req_14,
input  [26:0]           read_start_addr_14,
input  [26:0]           read_length_14,
output reg                 read_ack_14,

input                   read_req_15,
input  [26:0]           read_start_addr_15,
input  [26:0]           read_length_15,
output reg                 read_ack_15
);

localparam WIDTH = 16;
localparam MAX_ACK_DELAY = 4;

// Initialize registered output
initial
begin
  m_axi_araddr = 0;
  m_axi_arlen = 8'h0;
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
wire    [WIDTH-1:0]             read_req_w;
(*mark_debug = "true"*)reg      [WIDTH-1:0]     read_req;
wire    [2*WIDTH-1:0]           double_read_req;
reg     [WIDTH-1:0]             base;
reg                             busy;
wire							read_done;
reg     [2*WIDTH-1:0]           double_read_ack;
wire    [WIDTH-1:0]             read_ack;
(*mark_debug = "true"*)reg		[WIDTH-1:0]     read_ack_reg;
reg		[WIDTH-1:0]				read_ack_keep;



reg		[15:0]					read_allow;
reg		[15:0]					read_ack_dl1;
reg		[15:0]					read_ack_dl2;
reg		[15:0]					read_ack_dl3;
reg		[15:0]					read_ack_dl4;

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


reg		[29:0]		read_addr;
reg     [26:0]      read_length;
reg     [26:0]      read_start_addr;
reg					read_init;
reg     [26:0]      read_left;
reg                 read_en;
wire				ddr_read_addr_send;



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

//assign	ddr_read	= read_init;


always @ (posedge clk)
begin
  read_addr [2:0]	<= 3'h0;

  if(read_init)
	read_addr [29:3] <= read_start_addr;
  else if (ddr_read_addr_send)
	read_addr [29:3] <= read_addr [29:3] + 1;
end

// Assuming the read_length is always >= 2
always @ (posedge clk)
begin
  if(read_init)
	read_left  <= read_length;
  else if (ddr_read_addr_send)
	read_left  <= read_left - 1;
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


reg						read_credit_val;
// wire					ddr_read_addr_fifo_afull;
// wire					ddr_read_addr_fifo_empty;

assign	read_done			= ddr_read_addr_send & (~|read_left [26:1]) & read_left [0];
assign	ddr_read_addr_send	= read_en ; // & ~ddr_read_addr_fifo_afull;

// ddr_read_addr_fifo	ddr_read_addr_fifo
// (
// 	.rst(rst),
// 	.wr_clk(clk),
// 	.wr_en(ddr_read_addr_send),
// 	.din(read_addr [29:3]),

// 	.rd_clk(ddr_clk),
// 	.rd_en(app_en),
// 	.dout(app_addr [29:3]),

// 	.full(),
// 	.empty(ddr_read_addr_fifo_empty),
// 	.prog_full(ddr_read_addr_fifo_afull)
// );

// Cross clock domain
reg         read_init_q, read_init_q2;
reg         read_init_rise = 0;
reg [31:0]  read_length_q, read_length_q2;
reg [31:0]  read_start_addr_q, read_start_addr_q2;

always @(posedge ddr_clk)
begin
  read_init_q <= read_init;
  read_init_q2 <= read_init_q;
  read_init_rise <= read_init_q && ~read_init_q2;
  read_length_q <= read_length;
  read_length_q2 <= read_length_q;
  read_start_addr_q <= read_start_addr;
  read_start_addr_q2 <= read_start_addr_q;
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

// Count the number of burst needs to initate
integer       burst_left = 0;
reg           burst_read_active = 1'b0;
reg           start_single_burst_read = 1'b0;

always @(posedge ddr_clk)
begin
  if (~axi_aresetn)
    begin
      burst_left <= 0;
    end
  else if (read_init_rise && (burst_left == 0))
    begin
      burst_left <= read_length_q2;
    end
  else if (start_single_burst_read)
    burst_left <= burst_left - 1;
  else
    burst_left <= burst_left;
end


// burst_read_active remains asserted 
// until the burst write is accepted by the slave
always @(posedge ddr_clk)
begin
  if (~axi_aresetn || read_init_rise)
    burst_read_active <= 1'b0;
  else if (start_single_burst_read)
    burst_read_active <= 1'b1;
  else if (m_axi_rvalid && m_axi_rready && m_axi_rlast)
    burst_read_active <= 1'b0;
end

// Generate start_single_burst_read pulse
always @(posedge ddr_clk)
begin
  if (~axi_aresetn)
    start_single_burst_read <= 1'b0;
  else if (~m_axi_arvalid && ~start_single_burst_read &&
           ~burst_read_active && (burst_left != 0))
    start_single_burst_read <= 1'b1;
  else
    start_single_burst_read <= 1'b0;
end

reg int_axi_arvalid = 1'b0;

always @(posedge ddr_clk)                                 
begin                                                                                                         
  if (~axi_aresetn || read_init_rise)                                         
    begin                                                          
      int_axi_arvalid <= 1'b0;                                         
    end                                                            
  // If previously not valid , start next transaction              
  else if (~int_axi_arvalid && start_single_burst_read)                
    begin                                                          
      int_axi_arvalid <= 1'b1;                                         
    end                                                            
  else if (m_axi_arready && m_axi_arvalid)                           
    begin                                                          
      int_axi_arvalid <= 1'b0;                                         
    end                                                            
  else                                                             
    int_axi_arvalid <= int_axi_arvalid;                                    
end

assign m_axi_arvalid = int_axi_arvalid & read_credit_val;

always @(posedge ddr_clk)                                         
begin                                                                
  if (~axi_aresetn)                                                                                                    
    m_axi_araddr <= 0;                                             
  else if (read_init_rise)
    m_axi_araddr <= {read_start_addr_q2, 6'b0};   // 64B address to 1B address                                                         
  else if (m_axi_arready && m_axi_arvalid)                                                                                       
    m_axi_araddr <= m_axi_araddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;                                                                               
  else                                                               
    m_axi_araddr <= m_axi_araddr;                                        
end

always @(posedge ddr_clk)
begin
    m_axi_arlen <= C_M_AXI_BURST_LEN - 1;   
end

// Generate dma interface signals
wire						ddr_read_data_fifo_rd;
wire	[511:0]				ddr_read_data_fifo_out;
wire						ddr_read_data_fifo_empty;
wire						ddr_read_sync_fifo_empty;
wire						last_read_dly;
wire	[WIDTH-1:0]			read_ack_dly;


ddr_read_info_fifo	ddr_read_info_fifo
(
	.rst(rst),
	.clk(clk),
	.wr_en(ddr_read_addr_send),
	.din({read_done, read_ack_keep}),

	.rd_en(ddr_read_data_fifo_rd),
	.dout({last_read_dly, read_ack_dly}),

	.full(),
	.empty()
);

assign	ddr_read_data_fifo_rd	= ~ddr_read_data_fifo_empty & dout_rdy;

wire  ddr_read_data_fifo_full;
ddr_read_data_fifo	ddr_read_data_fifo
(
	.rst(rst),
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
	dout_eop	<= last_read_dly;
end


// What is this fifo used for ??
wire					ddr_read_sync_fifo_rd;

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

wire ddr_read_en;
assign	ddr_read_sync_fifo_rd = ~ddr_read_sync_fifo_empty;
assign	ddr_read_en = m_axi_arready & m_axi_arvalid;

reg		[8:0]		read_credit;

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