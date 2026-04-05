task run_test();
	begin
		master_read(TCR, data);
		cmp_data(data, 32'b1_0000_0000);
		master_read(TDR0, data);
		cmp_data(data, 32'h0);
		master_read(TDR1, data);
		cmp_data(data, 32'h0);
		master_read(TCMP0, data);
		cmp_data(data, 32'hFFFF_FFFF);
		master_read(TCMP1, data);
		cmp_data(data, 32'hFFFF_FFFF);
		master_read(TIER, data);
		cmp_data(data, 32'h0);
		master_read(TISR, data);
		cmp_data(data, 32'h0);
		master_read(THCSR, data);
		cmp_data(data, 32'h0);

		//1. Write 0xFFFF to TDR0 and read back
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
		repeat(65536) @(posedge sys_clk);

		@(posedge sys_clk);
		#1;

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
		tim_pwdata[0] = 1;
		master_write(TIER, tim_pwdata, BYTE0);
		if(tim_int !== 0)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t PASS: Timer interrupt is deasserted%s",GREEN,  $time, RESET);
			$display("------------------------------------------------------------");
		end else begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %5t FAIL: Timer interrupt is not deasserted%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end

		//write 1 to clear interrupt status
		master_read(TISR, data);
		cmp_data(data, 32'h1);
	
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TISR, tim_pwdata, BYTE0);
		master_read(TISR, data);
		cmp_data(data, 32'h0);
	end
endtask
