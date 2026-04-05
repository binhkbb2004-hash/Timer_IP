task run_test();
	reg [31:0]pwdata;
	begin	
		$display("===================================================================");
		$display("TESTCASE: CHECK PSLAVE ERROR");
		$display("===================================================================");	

		pwdata = 0;
		pwdata[0] = 1;
		master_write(TCR, pwdata, BYTE0);
		master_read(TCR, data);
		cmp_data(data, 32'h101);

		pwdata[1] = 1;
		check_pslverr(pwdata, BYTE0);
		master_read(TCR, data);
		cmp_data(data, 32'h101);

		pwdata[1] = 1;
		check_pslverr(pwdata, BYTE3);

		pwdata[1] = 0;
		pwdata[11:8] = 4'b1010;
		check_pslverr(pwdata, BYTE3);	

		pwdata[1] = 0;
		pwdata[11:8] = 4'b1000;
		check_pslverr(pwdata, BYTE1);
		master_read(TCR, data);
		cmp_data(data, 32'h101);

		pwdata = 0;
		master_write(TCR, pwdata, BYTE0);
		pwdata[11:8] = 4'b1010;
		check_pslverr(pwdata, BYTE1);
		master_read(TCR, data);
		cmp_data(data, 32'h100);

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask

task check_pslverr(input [31:0]pwdata, input [3:0]pstrb);
	reg div_en_error;
	reg div_val_error;
	reg prohibit_value;
	reg pslverr;
	begin
		master_read(TCR, data);
		$display("----------------------------------------------------------");
		$display("TIME: %0t, [INFO] Write data at addr: 12'h%x, data: 32'h%x, pstrb: 4'b%4b", $time, TCR, pwdata, pstrb);
		$display("----------------------------------------------------------");
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_paddr = TCR;
		tim_pwdata = pwdata;
		tim_pwrite = 1;
		tim_pstrb = pstrb;

		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		
		wait(tim_pready);
		div_en_error = data[0] & pstrb[0] & (pwdata[1] !== data[1]);
		div_val_error = data[0] & pstrb[1] & (pwdata[11:8] !== data[11:8]);
		prohibit_value = (pwdata >= 9) & pstrb[1];
		pslverr = div_en_error | div_val_error | prohibit_value;
		
		if(pslverr === 1)begin
			if(tim_pslverr === 1) begin
				$display("----------------------------------------------------------");
				$display("%sTIME: %0t, PASS | pslave error is asserted | pslverr = %0b%s", GREEN, $time, tim_pslverr, RESET);
				$display("----------------------------------------------------------");
			end else begin
				$display("----------------------------------------------------------");
				$display("%sTIME: %0t, FAIL | pslave error is not asserted | pslverr = %0b%s", GREEN, $time, tim_pslverr, RESET);
				$display("----------------------------------------------------------");
			end	
		end else begin
			$display("----------------------------------------------------------");
			$display("TIME: %0d, Write valid in TCR", $time);
			$display("----------------------------------------------------------");
		end

		@(posedge sys_clk);
		#1;
		tim_pwrite = 0;
		tim_pwdata = 0;
		tim_psel = 0;
		tim_penable = 0;
		tim_pstrb = 0;
		tim_paddr = 0;
	end
endtask
