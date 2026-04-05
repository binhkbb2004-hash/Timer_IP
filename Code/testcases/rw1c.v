task run_test();
	begin
		$display("====================================================");
		$display("TESTCASE: CHECK WRITE 1 TO CLEAR INTERRUPT TISR");
		$display("====================================================");
		
		master_write(TCMP1, 32'h0, FULL_WORD);
		master_read(TCMP1, data);
		cmp_data(data, 32'h0);

		master_write(TDR0, 32'hFFFF_FF00, FULL_WORD);
		master_read(TDR0, data);
		cmp_data(data, 32'hFFFF_FF00);
		
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TIER, tim_pwdata, BYTE0);	//enable interrupt
		master_read(TIER, data);
		cmp_data(data, 32'h1);

		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TCR, tim_pwdata, BYTE0); //enable counter
		master_read(TCR, data);
		cmp_data(data, 32'h101);

		fork
			begin
				repeat(100) @(posedge sys_clk);
				master_read(TISR, data);
				if(data[0] === 1)begin
					$display("----------------------------------------------------");
					$display("%sTIME: %0t, FAIL | Interrupt is asserted not properly%s", RED, $time, RESET);
					$display("----------------------------------------------------");
					error = error + 1;
				end else begin
					$display("----------------------------------------------------");
					$display("%sTIME: %0t, PASS | Interrupt is not asserted when Count < TCMP%s", GREEN, $time, RESET);
					$display("----------------------------------------------------");
				end
			end

			begin
				repeat(300) @(posedge sys_clk);
				master_read(TISR, data);
				if(data[0] === 1)begin
					$display("----------------------------------------------------");
					$display("%sTIME: %0t, PASS | Interrupt is asserted properly%s", GREEN, $time, RESET);
					$display("----------------------------------------------------");
				end else begin
					$display("----------------------------------------------------");
					$display("%sTIME: %0t, FAIL | Interrupt is not asserted%s", RED, $time, RESET);
					$display("----------------------------------------------------");
					error = error + 1;
				end	
			end
		join	

		//write 1 to clear TISR

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
