task run_test();
	reg [31:0]raw_data;
	integer i;
	reg [31:0] exp_data;
	begin	
		$display("==================================================");	
		$display("TESTCASE: TEST READ/WRITE ACCESS");
		$display("==================================================");

		//Test with given data
		raw_data = 32'hFFFF_F8FF;	
		master_write(TCR, raw_data, FULL_WORD);
		exp_data = 32'h803;
		master_read(TCR, data);
		cmp_data(data, exp_data);

		master_write(TCR, 32'h0, BYTE0);	//disable timer_en
		master_read(TCR, data);
		cmp_data(data, 32'h802);

		master_write(TCR, 32'h0, FULL_WORD);	//div_val = 0, div_en = 0
		master_read(TCR, data);
		cmp_data(data, 32'h0);
		
		raw_data = 32'hFFFF_FFFF;	
		master_write(TISR, raw_data, FULL_WORD);
		master_read(TISR, data);
		cmp_data(data, 32'h0);

		master_write(TDR0, raw_data, FULL_WORD);
		exp_data = 32'hFFFF_FFFF;
		master_read(TDR0, data);
		cmp_data(data, exp_data);

		master_write(TDR1, raw_data, FULL_WORD);
		master_read(TDR1, data);
		cmp_data(data, exp_data);

		master_write(TCMP0, raw_data, FULL_WORD);
		master_read(TCMP0, data);
		cmp_data(data, exp_data);

		master_write(TCMP1, raw_data, FULL_WORD);
		master_read(TCMP1, data);
		cmp_data(data, exp_data);

		master_write(TIER, raw_data, FULL_WORD);
		exp_data = 0;
		exp_data[0] = 1;
		master_read(TIER, data);
		cmp_data(data, exp_data);

		master_write(THCSR, raw_data, FULL_WORD);	
		master_read(THCSR, data);
		cmp_data(data, exp_data);

		raw_data = 0;
		master_write(TCMP0, raw_data, FULL_WORD);
		master_read(TCMP0, data);
		cmp_data(data, raw_data);

		master_write(TCMP1, raw_data, FULL_WORD);
		master_read(TCMP1, data);
		cmp_data(data, raw_data);

		//Test with random data
		for(i=0; i<20; i=i+1)begin
			raw_data = $random;
			rw_check(TDR0, raw_data, 32'hFFFF_FFFF);
		end
		
		for(i=0; i<20; i=i+1)begin
			raw_data = $random;
			rw_check(TDR1, raw_data, 32'hFFFF_FFFF);
		end
	       	
		for(i=0; i<20; i=i+1)begin
			raw_data = $random;
			rw_check(TCMP0, raw_data, 32'hFFFF_FFFF);
		end

		for(i=0; i<20; i=i+1)begin
			raw_data = $random;
			rw_check(TCMP1, raw_data, 32'hFFFF_FFFF);
		end

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask

task rw_check(input [11:0]address, input [31:0]pwdata, input [31:0]mask);
	reg [31:0]exp_data;

	begin
		master_write(address, pwdata, FULL_WORD);
		exp_data = pwdata & mask;
		master_read(address, data);
		cmp_data(data, exp_data);
	end
endtask
