task run_test();
	integer i;
	begin
		$display("========================================================");
		$display("TESTCASE: CHECK WRITE STROBE");
		$display("========================================================");
	        
	       	for(i = 0; i < 20; i = i + 1)begin
			tim_pstrb = $random;
			tim_pwdata = $random;
			check_writestrb(TCMP0, tim_pwdata, 32'hFFFF_FFFF, tim_pstrb);		
	       	end

		for(i = 0; i < 20; i = i + 1)begin
			tim_pstrb = $random;
			tim_pwdata = $random;
			check_writestrb(TCMP1, tim_pwdata, 32'hFFFF_FFFF, tim_pstrb);
		end

		for(i = 0; i < 20; i = i + 1)begin
                        tim_pstrb = $random;
                        tim_pwdata = $random;
                        check_writestrb(TDR0, tim_pwdata, 32'hFFFF_FFFF, tim_pstrb);
                end

		for(i = 0; i < 20; i = i + 1)begin
                        tim_pstrb = $random;
                        tim_pwdata = $random;
                        check_writestrb(TDR1, tim_pwdata, 32'hFFFF_FFFF, tim_pstrb);
                end
		
		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end

	end
endtask

task check_writestrb(input [12:0]addr, input [31:0]pwdata, input[31:0]mask, input[3:0]pstrb);
	reg [31:0] data_mask;
	reg [31:0] exp_data;
	begin
		master_read(addr, data);
		master_write(addr, pwdata, pstrb);
		data_mask = pwdata & mask;
		case (pstrb)
			4'b0001: exp_data = {data[31:8], data_mask[7:0]};
			4'b0010: exp_data = {data[31:16], data_mask[15:8], data[7:0]};       	
			4'b0011: exp_data = {data[31:16], data_mask[15:0]};
			4'b0100: exp_data = {data[31:24], data_mask[23:16], data[15:0]};
			4'b0101: exp_data = {data[31:24], data_mask[23:16], data[15:8], data_mask[7:0]};
			4'b0110: exp_data = {data[31:24], data_mask[23:8], data[7:0]};
			4'b0111: exp_data = {data[31:24], data_mask[23:0]};
			4'b1000: exp_data = {data_mask[31:24], data[23:0]};
			4'b1001: exp_data = {data_mask[31:24], data[23:8], data_mask[7:0]};
			4'b1010: exp_data = {data_mask[31:24], data[23:16], data_mask[15:8], data[7:0]};
			4'b1011: exp_data = {data_mask[31:24], data[23:16], data_mask[15:0]};
			4'b1100: exp_data = {data_mask[31:16], data[15:0]};
			4'b1101: exp_data = {data_mask[31:16], data[15:8], data_mask[7:0]};
			4'b1110: exp_data = {data_mask[31:8], data[7:0]};
			4'b1111: exp_data = data_mask;
			default: exp_data = data;
		endcase
		master_read(addr, data);
		cmp_data(data, exp_data);		
	end
endtask
