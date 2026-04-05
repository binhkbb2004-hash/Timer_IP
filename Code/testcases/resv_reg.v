task run_test();
	begin
		$display("=================================================");
		$display("TESTCASE: CHECK RESERVED REGISTER");
		$display("=================================================");

		//Check with offset 0x1
		master_write(TDR0+1, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TDR0+1, data);
		cmp_data(data, 32'h0);

		master_write(TCMP0+1, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TCMP0+1, data);
		cmp_data(data, 32'h0);

		//Check with offset 0x2
		master_write(TDR0+2, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TDR0+2, data);
		cmp_data(data, 32'h0);

		master_write(TCMP0+2, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TCMP0+2, data);
		cmp_data(data, 32'h0);
	
		//Check with offset 0x3
		master_write(TDR0+3, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TDR0+1, data);
		cmp_data(data, 32'h0);

		master_write(TCMP0+3, 32'hFFFF_FFFF, FULL_WORD);
		master_read(TCMP0+1, data);
		cmp_data(data, 32'h0);
		
		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
