task run_test();
	begin	
		
	        $display("==========================================================");
		$display("TESTCASE: CHECK HALT MODE");
		$display("==========================================================");

		dbg_mode = 0;
	     	check_debug_mode(dbg_mode);

	     	master_write(TCR, 32'h0, BYTE0); //disable timer_en
	      	master_read(TCR, data);
	      	cmp_data(data, 32'h100);
		
	      	dbg_mode = 1;
	      	check_debug_mode(dbg_mode);

	      	if(error === 0)begin
			$display("PASS TESTCASE");
	      	end else begin
			$display("FAIL TESTCASE");
	      	end
	end
endtask

task check_debug_mode(input debug_mode);
	reg [31:0] predata;
	reg halt_req;
	begin
		dbg_mode = debug_mode;
		master_read(TDR0, data);
		cmp_data(data, 32'h0);

		//enable counter
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TCR, tim_pwdata, BYTE0);

		repeat(100) @(posedge sys_clk);
		
		//halt_req
		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(THCSR, tim_pwdata, BYTE0);
		master_read(THCSR, data);
		halt_req = data[0];

		if(dbg_mode & halt_req)begin
			cmp_data(data, 32'h3);
		end else begin
			cmp_data(data, 32'h1);
		end

		master_read(TDR0, data);
		predata = data;
		repeat(100) @(posedge sys_clk);
		master_read(TDR0, data);

		if(dbg_mode & halt_req)begin
			if(data === predata)begin
				$display("----------------------------------------------------------");
                                $display("%sTIME: %0t, PASS | Timer halt in debug mode | data: %h, predata: %h%s", GREEN, $time, data, predata, RESET);
                                $display("----------------------------------------------------------");
			end else begin
				$display("----------------------------------------------------------");
                                $display("%sTIME: %0t, PASS | Timer not halt in debug mode | data: %h, predata: %h%s", GREEN, $time, data, predata, RESET);
                                $display("----------------------------------------------------------");
				error = error + 1;
			end
		end else begin
			if(data > predata)begin
				$display("----------------------------------------------------------");
				$display("%sTIME: %0t, PASS | Counter countinue count when not in debug mode | data: %h, predata: %h%s", GREEN, $time, data, predata, RESET);
				$display("----------------------------------------------------------");
			end else begin
				$display("----------------------------------------------------------");
				$display("%sTIME: %0t, FAIL | Counter halt when not in debug mode  | data: %h, predata: %h%s", RED, $time, data, predata, RESET);
				$display("----------------------------------------------------------");
				error = error + 1;
			end
		end
		
		predata = data;
		tim_pwdata = 0;
		tim_pwdata[0] = 0;
		master_write(THCSR, tim_pwdata, BYTE0);	//disable halt_req
		master_read(THCSR, data);
		cmp_data(data, 32'h0);

		repeat(100) @(posedge sys_clk);
		master_read(TDR0, data);
		if(data > predata) begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Counter count up after debug mode | count value = %0h%s", GREEN, $time, data, RESET);
			$display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Counter not count up after debug mode | count value = %0h%s", RED, $time, data, RESET);
			$display("----------------------------------------------------------");
			error = error + 1;
		end
	end
endtask
