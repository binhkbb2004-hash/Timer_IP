module top(
	input wire  sys_clk,
	input wire  sys_rst_n,
	input wire  tim_psel,
	input wire  tim_pwrite,
	input wire  tim_penable,
	input wire  dbg_mode,
	input wire  [31:0]tim_pwdata,
	input wire  [3:0] tim_pstrb,
	input wire  [11:0]tim_paddr,
	output wire tim_int,
	output wire tim_pready,
	output wire tim_pslverr,
	output wire [31:0]tim_prdata
);
	wire wr_en, rd_en, int_st, clear_int, set_int, div_en, timer_en, TDR0_wr_sel, TDR1_wr_sel, clear_cnt, int_en, cnt_en, halt_req;
	wire [3:0]div_val;
	wire [63:0]cnt;

	APB_Slave module1(
		.psel	(tim_psel),
		.pwrite	(tim_pwrite),
		.penable(tim_penable),
		.clk	(sys_clk),
		.rst_n	(sys_rst_n),
		.wr_en	(wr_en),
		.rd_en	(rd_en),
		.pready	(tim_pready)
	);

	Register module2(
		.wr_en		(wr_en),
		.rd_en		(rd_en),
		.pwdata		(tim_pwdata),
		.paddr		(tim_paddr),
		.clk		(sys_clk),
		.rst_n		(sys_rst_n),
		.pstrb		(tim_pstrb),
		.dbg_mode	(dbg_mode),
		.cnt		(cnt),
		.int_st		(int_st),         
		.prdata		(tim_prdata),
		.set_int	(set_int),
		.clear_int	(clear_int),
		.div_en		(div_en),
		.div_val	(div_val),
		.halt_req_out	(halt_req),
		.timer_en	(timer_en),
		.pslverr	(tim_pslverr),
		.TDR0_wr_sel	(TDR0_wr_sel),
		.TDR1_wr_sel	(TDR1_wr_sel),
		.clear_cnt	(clear_cnt),
		.int_en		(int_en)
	);
               
        Counter_control module3( 
		.clk		(sys_clk),    	
		.rst_n		(sys_rst_n),
		.div_en		(div_en),
		.div_val	(div_val),
		.timer_en	(timer_en),
		.halt_req	(halt_req),
		.cnt_en		(cnt_en)	
	);

	Counter module4(
		.clk		(sys_clk),       	
		.rst_n		(sys_rst_n),
		.cnt_en		(cnt_en),
		.TDR0_wr_sel	(TDR0_wr_sel),
		.TDR1_wr_sel	(TDR1_wr_sel),
		.clear_cnt	(clear_cnt),
		.pwdata		(tim_pwdata),
		.pstrb		(tim_pstrb),
		.cnt		(cnt)
	);

	Interrupt module5(
		.clk		(sys_clk),
		.rst_n		(sys_rst_n),
		.set_int	(set_int),
		.clear_int	(clear_int),
		.int_en		(int_en),
		.int_st		(int_st),
		.tim_int	(tim_int)
	);

endmodule
