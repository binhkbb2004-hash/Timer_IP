task run_test();
	begin
		$display("=========================================================");
		$display("TESTCASE: APB WRITE MULTI-ACCESS");
		$display("=========================================================");

		//multiple write - normal read
		master_write_multi_data(TCMP0, 32'h0, FULL_WORD, TCMP1, 32'h0, FULL_WORD);
		master_read(TCMP0, data);
		cmp_data(data, 32'h0);
		master_read(TCMP1, data);
		cmp_data(data, 32'h0);

		//write normal - multiple read
		master_write(TDR0, 32'hFF, BYTE0);
		master_write(TDR1, 32'hFF00, BYTE1);
		master_read_multi_data(TDR0, data, TDR1, data2);
		cmp_data(data, 32'hFF);
		cmp_data(data2, 32'hFF00);

		//write-read (TDR0), write-read(TDR1)
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_pwrite = 1;
		tim_paddr = TDR0;
		tim_pwdata = 32'h5555_5555;
		tim_pstrb = 4'b1111;

		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		
		wait(tim_pready);
		@(posedge sys_clk);
		#1;
		tim_pwrite = 0;
		tim_penable = 0;
		tim_pwdata = 0;
		tim_pstrb = 0;

		@(posedge sys_clk);
		#1;
		tim_penable = 1;

		wait(tim_pready);
		@(posedge sys_clk);
		cmp_data(tim_prdata, 32'h5555_5555);
		#1;
		tim_pwrite = 1;
		tim_paddr = TDR1;
		tim_penable = 0;
		tim_pwdata = 32'h6666_6666;
		tim_pstrb = 4'b1111;

		@(posedge sys_clk);
		#1;
		tim_penable = 1;

		wait(tim_pready);
		@(posedge sys_clk);
		#1;
		tim_penable = 0;
		tim_pwdata = 0;
		tim_pwrite = 0;
		tim_pstrb = 0;

		@(posedge sys_clk);
		#1;
		tim_penable = 1;

		wait(tim_pready);
		@(posedge sys_clk);
		cmp_data(tim_prdata, 32'h6666_6666);
		#1;
		tim_paddr = 0;
		tim_penable = 0;
		tim_psel = 0;

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
