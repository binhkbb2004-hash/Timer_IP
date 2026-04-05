task run_test();
	reg [31:0] exp_value;
	begin	
		$display("==================================================");
		$display("TESTCASE: CHECK DEFAULT VALUE");	
		$display("==================================================");

		// check TCR
		exp_value = 0;
		exp_value[8] = 1;	
		master_read(TCR, data);
		cmp_data(data, exp_value);

		// check TDR
		exp_value = 0;
		master_read(TDR0, data);
		cmp_data(data, exp_value);

		master_read(TDR1, data);
		cmp_data(data, exp_value);

		// check TCMP0
		exp_value = 32'hFFFF_FFFF;
		master_read(TCMP0, data);
		cmp_data(data, exp_value);

		master_read(TCMP1, data);
		cmp_data(data, exp_value);

		// check TIER
		exp_value = 0;
		master_read(TIER, data);
		cmp_data(data, exp_value);

		// check TISR
		exp_value = 0;
		master_read(TISR, data);
		cmp_data(data, exp_value);

		// check THCSR
		exp_value = 0;
		master_read(THCSR, data);
		cmp_data(data, exp_value);

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
