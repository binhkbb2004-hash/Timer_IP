task run_test();
	begin
		$display("====================================================");
		$display("TESTCASE: CHECK INTERRUPT");
		$display("====================================================");
		
		//1. Write 0xFFFF to TDR0
		master_write(TDR0, 32'hFFFF, HALF_WORD0);
		master_read(TDR0, data);
		cmp_data(data, 32'hFFFF);

		//2. Enable interrupt
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TIER, tim_pwdata, BYTE0);
		
		//Write to TCMP Register
		tim_pwdata = 0;
		master_write(TCMP1, tim_pwdata, FULL_WORD);
		master_read(TCMP1, data);
		cmp_data(data, 32'h0);
		
		master_write(TCMP0, 32'h1_FFFF, FULL_WORD);
		master_read(TCMP0, data);
		cmp_data(data, 32'h1_FFFF);
		
		//3. start timer
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TCR, tim_pwdata, BYTE0);
		
		//4. check interrupt
		repeat(65600) @(posedge sys_clk);

		if(tim_int)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t PASS: Timer interrupt is asserted%s", GREEN, $time, RESET);
			$display("------------------------------------------------------------");
		end else begin 
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t FAIL: Timer interrupt is not asserted%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end

		//check interrupt status 
		master_read(TISR, data);
		cmp_data(data, 32'h1);

		//check interrupt when disable interrupt
		tim_pwdata = 0;
		tim_pwdata[0] = 0;
		master_write(TIER, tim_pwdata, BYTE0);
		if(!tim_int)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t PASS: Timer interrupt is deasserted%s", GREEN, $time, RESET);
			$display("------------------------------------------------------------");
		end else begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t FAIL: Timer interrupt is not deasserted%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end
		
		//Check tim_st ?= 1
		master_read(TISR, data);
		cmp_data(data, 32'h1);
	
		//Check write 0 to TISR
		tim_pwdata = 0;
		master_write(TISR, tim_pwdata, BYTE0);
		master_read(TISR, data);
		cmp_data(data, 32'h1);

		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TISR, tim_pwdata, BYTE0);
		master_read(TISR, data);
		cmp_data(data, 32'h0);
		
		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
