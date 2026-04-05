module Counter(
	input wire  		clk,
	input wire  		rst_n,
	input wire  		cnt_en,
	input wire  		TDR0_wr_sel,
	input wire  		TDR1_wr_sel,
	input wire  		clear_cnt,
	input wire  [3:0]	pstrb,
	input wire  [31:0]	pwdata,
	output wire [63:0]	cnt
);	
	parameter TDR_DEFAULT_VALUE = 32'h0;
	
	wire 	[31:0]		tdr0_pre;
	reg 	[31:0]		tdr0;
	wire 	[31:0]		tdr1_pre;
	reg 	[31:0]		tdr1;
	wire 	[63:0]		cnt_next;

	assign tdr0_pre[7:0] 	= clear_cnt			?	8'h0		:
		   	  	  TDR0_wr_sel & pstrb[0]	?	pwdata[7:0]	:
		   	  	  cnt_en			?	cnt_next[7:0]	:	tdr0[7:0];

	assign tdr0_pre[15:8]  = clear_cnt			?	8'h0		:
	   		  	 TDR0_wr_sel & pstrb[1]		?	pwdata[15:8]	:
	   		  	 cnt_en				?	cnt_next[15:8]	:	tdr0[15:8];

	assign tdr0_pre[23:16] = clear_cnt			?	8'h0		:
	   		  	 TDR0_wr_sel & pstrb[2]		?	pwdata[23:16]	:
	   		 	 cnt_en				?	cnt_next[23:16]	:	tdr0[23:16];

	assign tdr0_pre[31:24]  = clear_cnt			?	8'h0		:
	   		  	  TDR0_wr_sel & pstrb[3]	?	pwdata[31:24]	:
	   		 	  cnt_en			?	cnt_next[31:24]	:	tdr0[31:24];



	assign tdr1_pre[7:0] 	= clear_cnt			?	8'h0		:
	   	 		  TDR1_wr_sel & pstrb[0]	?	pwdata[7:0]	:
	   	  		  cnt_en			?	cnt_next[39:32]	:	tdr1[7:0];
                                                                                             
	assign tdr1_pre[15:8]  = clear_cnt			?	8'h0		:
   		  		 TDR1_wr_sel & pstrb[1]		?	pwdata[15:8]	:
   		  		 cnt_en				?	cnt_next[47:40]	:	tdr1[15:8];
                                                                                             
	assign tdr1_pre[23:16] = clear_cnt			?	8'h0		:
   		  	  	 TDR1_wr_sel & pstrb[2]		?	pwdata[23:16]	:
   		  	  	 cnt_en				?	cnt_next[55:48]	:	tdr1[23:16];
                                                                                             
	assign tdr1_pre[31:24] = clear_cnt			?	8'h0		:
   		   	 	 TDR1_wr_sel & pstrb[3]		?	pwdata[31:24]	:
   		   	   	 cnt_en				?	cnt_next[63:56]	:	tdr1[31:24];	
	   
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tdr0 <= TDR_DEFAULT_VALUE;
		end else begin
			tdr0 <= tdr0_pre;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tdr1 <= TDR_DEFAULT_VALUE;
		end else begin
			tdr1 <= tdr1_pre;
		end
	end

	assign cnt 	= {tdr1, tdr0};
	assign cnt_next = cnt + 1;
endmodule
