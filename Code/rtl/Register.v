module Register(
	input wire 		clk,
	input wire 		rst_n,
	input wire 		wr_en,
	input wire 		rd_en,
	input wire 		dbg_mode,
	input wire 		int_st,
	input wire [31:0]	pwdata,
	input wire [11:0]	paddr,
	input wire [3:0]	pstrb,
	input wire [63:0]	cnt,

	output reg  		div_en,
	output reg  [3:0]	div_val,
    output wire 		halt_req_out,
	output reg  		timer_en,
	output wire 		pslverr,
	output wire 		set_int,
	output wire 		clear_int,
	output reg  		int_en,
	output wire 		TDR0_wr_sel,
	output wire 		TDR1_wr_sel,
	output wire 		clear_cnt,
	output wire [31:0]	prdata
);

	parameter TCR   = 12'h00;
	parameter TDR0  = 12'h04;
	parameter TDR1  = 12'h08;
	parameter TCMP0 = 12'h0C;
	parameter TCMP1 = 12'h10;
	parameter TIER  = 12'h14;
	parameter TISR  = 12'h18;
	parameter THCSR = 12'h1C;
	
	parameter TCMP_INIT_VALUE = 32'hFFFF_FFFF;

	reg 	[7:0]	reg_sel;
	wire 		TCR_sel;
	wire 		timer_en_sel; 
	wire 		timer_en_pre;
	reg  		timer_en_delay;
	wire 		div_en_sel;
	wire 		div_en_pre;
    wire 		div_en_error;
	wire 		div_val_sel;
	wire 		div_val_error;
	wire 		prohibit_val;
	wire 	[3:0]	div_val_pre;
	wire 	[31:0] 	tcmp0_pre;
	reg  	[31:0] 	tcmp0;
	wire	[31:0]	tcmp1_pre;
	reg  	[31:0] 	tcmp1;
	wire 		int_en_sel;
	wire 		int_en_pre;
	wire 		halt_req_sel;
	wire 		halt_req_pre;
	reg 		halt_req;
	wire 		halt_ack;
	wire 	[63:0]	TCMP_VALUE;
	reg  	[31:0] 	rdata_pre;

	//decode address
	always @* begin
		case(paddr)
			TCR: 	reg_sel = 8'b 0000_0001;
			TDR0:   reg_sel = 8'b 0000_0010;
			TDR1:	reg_sel = 8'b 0000_0100;
			TCMP0:	reg_sel = 8'b 0000_1000;
			TCMP1:  reg_sel = 8'b 0001_0000;
			TIER: 	reg_sel = 8'b 0010_0000;
			TISR:	reg_sel = 8'b 0100_0000;
			THCSR: 	reg_sel = 8'b 1000_0000;
			default:reg_sel = 8'b 0000_0000;
		endcase
	end
	
	//1. TCR REGISTER 
	//TCR select
	assign TCR_sel = wr_en & reg_sel[0];

	//write timer_en
	assign timer_en_sel = TCR_sel & pstrb[0] & (!pslverr);
	assign timer_en_pre = timer_en_sel ? pwdata[0] : timer_en; 

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			timer_en <= 1'b0;
		end else begin
			timer_en <= timer_en_pre; 
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			timer_en_delay <= 1'b0;
		end else begin
			timer_en_delay <= timer_en;
		end
	end

	assign clear_cnt = !timer_en & timer_en_delay;

	//check error for div_en
	assign div_en_error = timer_en & pstrb[0] & (pwdata[1] != div_en) & TCR_sel;
	
	//write div_en
	assign div_en_sel = TCR_sel & pstrb[0] & (!pslverr);
	assign div_en_pre = div_en_sel ? pwdata[1] : div_en;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			div_en <= 1'b0;
		end else begin
			div_en <= div_en_pre;
		end
	end

	//check error for div_val
	assign prohibit_val  = TCR_sel & pstrb[1] & (pwdata[11:8] >= 9);
	assign div_val_error = timer_en & pstrb[1] & (pwdata[11:8] != div_val) & TCR_sel;

	//write div_val
	assign div_val_sel = TCR_sel & pstrb[1] & (!pslverr) & (pwdata[11:8] < 9);
	assign div_val_pre = div_val_sel ? pwdata[11:8] : div_val;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			div_val <= 4'b0001;
		end else begin
			div_val <= div_val_pre;
		end
	end	

	assign pslverr = div_val_error | prohibit_val | div_en_error;

	//2. TDR0 REGISTER 
	assign TDR0_wr_sel = wr_en & reg_sel[1];

	//3. TDR1
	assign TDR1_wr_sel = wr_en & reg_sel[2];

	//4. TCMP0
	assign tcmp0_pre[7:0] 	= wr_en & reg_sel[3] & pstrb[0]		?	pwdata[7:0]		: 	tcmp0[7:0];
    assign tcmp0_pre[15:8]	= wr_en & reg_sel[3] & pstrb[1]		? 	pwdata[15:8]	: 	tcmp0[15:8];	
	assign tcmp0_pre[23:16]	= wr_en & reg_sel[3] & pstrb[2]		? 	pwdata[23:16]	: 	tcmp0[23:16];
	assign tcmp0_pre[31:24] = wr_en	& reg_sel[3] & pstrb[3]		? 	pwdata[31:24]	: 	tcmp0[31:24];

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tcmp0	 <= TCMP_INIT_VALUE;
		end else begin
			tcmp0	<= tcmp0_pre;
		end
	end
	
	//5. TCMP1	
	assign tcmp1_pre[7:0] 	= wr_en & reg_sel[4] & pstrb[0]		?	pwdata[7:0]		: 	tcmp1[7:0];	
	assign tcmp1_pre[15:8]	= wr_en & reg_sel[4] & pstrb[1]		? 	pwdata[15:8]	: 	tcmp1[15:8];  
	assign tcmp1_pre[23:16]	= wr_en & reg_sel[4] & pstrb[2]		? 	pwdata[23:16]	: 	tcmp1[23:16];
	assign tcmp1_pre[31:24] = wr_en	& reg_sel[4] & pstrb[3]		? 	pwdata[31:24]	: 	tcmp1[31:24];

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			tcmp1	 <= TCMP_INIT_VALUE;
		end else begin
			tcmp1	 <= tcmp1_pre;
		end
	end

	assign TCMP_VALUE = {tcmp1, tcmp0};

	//6. TIER
	assign int_en_sel = wr_en & pstrb[0] & reg_sel[5];
	assign int_en_pre = int_en_sel ? pwdata[0] : int_en;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			int_en <= 1'b0;
		end else begin
			int_en <= int_en_pre;
		end
	end	


	//7. TISR
	assign set_int 	 = (cnt == TCMP_VALUE);
	assign clear_int = wr_en & reg_sel[6] & (pwdata[0] == 1);

	//8. THCSR
	assign halt_req_sel = wr_en & pstrb[0] & reg_sel[7];
	assign halt_req_pre = halt_req_sel ? pwdata[0] : halt_req;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			halt_req <= 1'b0;
		end else begin
			halt_req <= halt_req_pre;
		end	
	end

	assign halt_ack = halt_req & dbg_mode;
	assign halt_req_out = halt_ack;

	//logic for read
	
	always @(*) begin
		if(rd_en) begin
			case(paddr) 
				TCR:   	rdata_pre = {20'h0, div_val, 6'h0, div_en, timer_en};
				TDR0:  	rdata_pre = cnt[31:0];
				TDR1:  	rdata_pre = cnt[63:32];
				TCMP0: 	rdata_pre = tcmp0;
				TCMP1: 	rdata_pre = tcmp1;
				TIER:  	rdata_pre = {31'h0, int_en};
				TISR:  	rdata_pre = {31'h0, int_st};
				THCSR: 	rdata_pre = {30'h0, halt_ack, halt_req};
				default:rdata_pre = 32'h0;
			endcase
		end else begin
			rdata_pre = 32'h0;
		end
	end

	assign prdata = rdata_pre;

endmodule
