task run_test();
	integer div_val;
	reg [31:0]pwdata;
	reg [63:0]cnt;
	reg [63:0]cnt1;
	begin	
		$display("=============================================================");
		$display("TESTCASE: COUNTING MODE DIV != 0");
		$display("=============================================================");
	      	
		dbg_mode = 1;
		cnt = 0;
		cnt1 = 0;

	      	pwdata = 0;
	       	pwdata[1:0] = 2'b11;
	       	master_write(TCR, pwdata, FULL_WORD);
	       	master_read(TCR, data);
	       	cmp_data(data, 32'b11);

	       	pwdata[0] = 0;
		master_write(TCR, pwdata, BYTE0);
		master_read(TCR, data);
		cmp_data(data, 32'b10);

		pwdata = 0;
		pwdata[11:8] = 4'b1000;
		pwdata[1] = 1;
		master_write(TCR, pwdata, FULL_WORD);
		master_read(TCR, data);
		cmp_data(data, 32'h802);

		pwdata[0] = 1;
		master_write(TCR, pwdata, FULL_WORD);
		master_read(TCR, data);
		cmp_data(data, 32'h803);

		pwdata[0] = 0;
		master_write(TCR, pwdata, BYTE0);
		master_read(TCR, data);
		cmp_data(data, 32'h802);
	
	       	for(div_val = 0; div_val <= 8; div_val = div_val + 1)begin
			pwdata = 0;
			pwdata[11:8] = div_val[3:0];
			pwdata[1:0] = 2'b11;
			master_write(TCR, pwdata, FULL_WORD);
			
			repeat(256) @(posedge sys_clk);         //expect value = 256/2^div_val
			
			//turn on dbg_mode
			tim_pwdata = 0;
                        tim_pwdata[0] = 1;
                        master_write(THCSR, tim_pwdata, BYTE0);
                        //dbg_mode = 1;

                	master_read(TDR0, data);
			cnt = data;
                	//if(data >= 256 / (1 << div_val)) begin
			if(data === (golden_cnt >> div_val))begin
                	        $display("----------------------------------------------------------");
                	        $display("%sTIME: %0t, PASS | Mode %4b work properly | Count value = %0h, Count expect = %0h%s", GREEN, $time, div_val[3:0], data, golden_cnt >> div_val, RESET);
                	        $display("----------------------------------------------------------");
               		end else begin
                	        $display("----------------------------------------------------------");
                	        $display("%sTIME: %0t, FAIL | Mode %4b not work properly | Count value = %0h, Count expect = %0h%s", RED, $time, div_val[3:0], data, golden_cnt >> div_val, RESET);
                	        $display("----------------------------------------------------------");
				error = error + 1;
                	end

			//check timer after halted
			tim_pwdata = 0;
			master_write(THCSR, tim_pwdata, BYTE0);
			repeat(512) @(posedge sys_clk);
			tim_pwdata = 0;
			tim_pwdata[0] = 1;
			master_write(THCSR, tim_pwdata, BYTE0);

			master_read(TDR0, data);
			cnt1 = data;

			if((cnt1 === golden_cnt >> div_val) && (cnt1 > cnt))begin
				$display("----------------------------------------------------------");
                                $display("%sTIME: %0t, PASS | Timer count correct, count after halted | Count value = %0h, Count expect = %0h%s", GREEN, $time, cnt1, golden_cnt >> div_val, RESET);
                                $display("----------------------------------------------------------");
			end else begin
				$display("----------------------------------------------------------");
                                $display("%sTIME: %0t, FAIL | Timer count incorrect | Count value = %0h, Count expect = %0h%s", RED, $time, cnt1, golden_cnt >> div_val, RESET);
                                $display("----------------------------------------------------------");
                                error = error + 1;
			end

			//disable
			pwdata[0] = 0;
			master_write(TCR, pwdata, BYTE0);

			//disable halt
			tim_pwdata = 0;
			master_write(THCSR, tim_pwdata, BYTE0);
	       	end

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask
