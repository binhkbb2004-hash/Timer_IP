module APB_Slave(
	input  wire 	psel,
	input  wire 	pwrite,
	input  wire 	penable,
	input  wire 	clk,
	input  wire 	rst_n,
	output reg 	wr_en,
	output reg 	rd_en,
	output wire 	pready
);
	wire 	wr_en_pre;
	wire 	rd_en_pre;

	assign wr_en_pre = psel & penable & pwrite & !wr_en;
	assign rd_en_pre = psel & penable & !pwrite & !rd_en;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			wr_en <= 1'b0;
		end else begin
			wr_en <= wr_en_pre;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			rd_en <= 1'b0;
		end else begin
			rd_en <= rd_en_pre;
		end
	end

	assign pready = rd_en | wr_en;

endmodule