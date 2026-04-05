module Interrupt(
	input  wire 	clk,
	input  wire 	rst_n,
	input  wire 	set_int,
	input  wire 	clear_int,
	input  wire 	int_en,
	output reg  	int_st,
	output wire 	tim_int
);
	wire int_st_set, int_st_pre;

	assign int_st_set = set_int 	? 1'b1 	: int_st;
	assign int_st_pre = clear_int 	? 1'b0 	: int_st_set;
		
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			int_st <= 1'b0;
		end else begin
			int_st <= int_st_pre;
		end
	end

	assign tim_int = int_st & int_en; 
endmodule
