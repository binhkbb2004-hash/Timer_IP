module Counter_control(
	input wire 		clk,
	input wire 		rst_n,
	input wire 		div_en,
	input wire 	[3:0]	div_val,
	input wire 		timer_en,
	input wire 		halt_req,	
	output wire		cnt_en
);

	reg [7:0] 	counter_internal;
	reg	[7:0] 	limit;

	wire		default_mode;
	wire		ctrl_mode_0;
	wire 		ctrl_mode_other;
	wire	[7:0]	cnt_pre;
	wire	[7:0]	cnt_2_pre; 
	wire 		cnt_set;
	wire 		cnt_clr;	
	
	always @(*) begin
		case(div_val)
			4'b0001: limit = 1;
			4'b0010: limit = 3;
			4'b0011: limit = 7;
			4'b0100: limit = 15;
			4'b0101: limit = 31;
			4'b0110: limit = 63;
			4'b0111: limit = 127;
			4'b1000: limit = 255;
			default: limit = 0;
		endcase
	end

	assign cnt_set = timer_en & div_en & (div_val != 4'h0) & (!halt_req);
	assign cnt_clr = (!timer_en) | (!div_en) | ((counter_internal == limit) & (!halt_req));

	assign cnt_2_pre = cnt_set ? (counter_internal + 1) : counter_internal;
    assign cnt_pre   = cnt_clr ? 8'h0 : cnt_2_pre;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			counter_internal <= 8'h0;
		end else begin
			counter_internal <= cnt_pre;
		end
	end	

	assign default_mode 	= timer_en & (!div_en) & (!halt_req);
	assign ctrl_mode_0  	= timer_en & div_en & (div_val == 4'h0) & (!halt_req);                           	
	assign ctrl_mode_other  = timer_en & div_en & (div_val != 4'h0) & (!halt_req) & (counter_internal == limit); 

	assign cnt_en = default_mode | ctrl_mode_0 | ctrl_mode_other;	

endmodule 
