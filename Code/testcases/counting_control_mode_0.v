task run_test();
	reg [31:0]pwdata;
	reg [63:0]cnt;
	reg [63:0]cnt1;
	begin	
		$display("======================================================");
		$display("TESTCASE: CHECK COUNTER IN DIV MODE 0");
		$display("======================================================");
		
		dbg_mode = 1;
		
		//check TCR
		master_read(TCR, data);
		cmp_data(data, 32'h100);
		
		pwdata = 0;
		pwdata[1:0] = 2'b11;	//enable counter in div mode with div value =4'b0001
		master_write(TCR, pwdata, BYTE0);

		repeat(20) @(posedge sys_clk);
		master_read(TDR0, data);
		if(data === 0)begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Counter not count | Count value = %0h%s", RED, $time, data, RESET);
			$display("----------------------------------------------------------");
			error = error + 1;
		end else begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Count count up | Count value = %0h%s", GREEN, $time, data, RESET);
			$display("----------------------------------------------------------");

		end

		pwdata[0] = 0;
		master_write(TCR, pwdata, BYTE0);

		pwdata = 0;
		pwdata[11:8] = 4'b0000;	//div_value = 4'b0000
		pwdata[1] = 1; 		//enable div
		pwdata[0] = 1;		//enable timer
		master_write(TCR, pwdata, FULL_WORD);
		
		repeat(256) @(posedge sys_clk);
		
		//halt to read data
		pwdata = 0;
		pwdata[0] = 1;
		master_write(THCSR, pwdata, BYTE0);

		master_read(TDR0, data);
		cnt = data;
		if(data === golden_cnt) begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Default mode work properly | Count value = %0d, Count expect = %0d%s", GREEN, $time, data, golden_cnt, RESET);
			$display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Default mode not work properly | Count value = %0d, Count expect = %0d%s", RED, $time, data, golden_cnt, RESET);
			$display("----------------------------------------------------------");
			error = error + 1;
		end

		//check counter after halted
		pwdata = 0;
		master_write(THCSR, pwdata, BYTE0);

		repeat(256)@(posedge sys_clk);
		master_read(TDR0, data);
		cnt1 = data;
		if(cnt1 >= cnt)begin
			$display("----------------------------------------------------------");
                        $display("%sTIME: %0t, PASS | Timer work properly after halted | Count value = %0d, Count previous = %0d%s", GREEN, $time, cnt1, cnt, RESET);
                        $display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
                        $display("%sTIME: %0t, FAIL | Timer not work properly after halted | Count value = %0d, Count previous = %0d%s", RED, $time, cnt1, cnt, RESET);
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
