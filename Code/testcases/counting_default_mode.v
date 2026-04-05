task run_test();
	reg [31:0]pwdata;
	reg [63:0]cnt;
	reg [63:0]cnt1;
	begin	
		$display("==========================================================");
		$display("TESTCASE: CHECK COUNTING DEFAULT MODE");
		$display("==========================================================");
		
		cnt = 0;
		cnt1 = 0;
		dbg_mode = 1;
		
		pwdata = 0;
		pwdata[0] = 1;
		master_write(TCR, pwdata, FULL_WORD);	//start counting
		repeat(256) @(posedge sys_clk);

		//halt to read data
		pwdata = 0;
		pwdata[0] = 1;
		master_write(THCSR, pwdata, BYTE0);

		master_read(TDR0, data);
		cnt = data; 
		if(data === golden_cnt) begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Default mode work properly | Count value = %0h, Count expect = %0h%s", GREEN, $time, data, golden_cnt, RESET);
			$display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Default mode not work properly | Count value = %0h, Count expect = %0h%s", RED, $time, data, golden_cnt, RESET);
			$display("----------------------------------------------------------");
			error = error + 1;
		end

		//disable halt
		pwdata = 0;
		master_write(THCSR, pwdata, BYTE0);
		
		repeat(256) @(posedge sys_clk);
		master_read(TDR0, data);
		cnt1 = data;
		if(cnt1 >= cnt + 256)begin
			$display("----------------------------------------------------------");
                        $display("%sTIME: %0t, PASS | Timer work properly after halted | Count value = %0h, Count previous = %0h%s", GREEN, $time, cnt1, cnt, RESET);
                        $display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
                        $display("%sTIME: %0t, FAIL | Timer not work properly after halted | Count value = %0h, Count previous = %0h%s", RED, $time, cnt1, cnt, RESET);
                        $display("----------------------------------------------------------");
			error = error + 1;
		end

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
