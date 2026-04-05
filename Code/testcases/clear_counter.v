task run_test();
	begin

		$display("=====================================================");
		$display("TESTCASE: CHECK CLEAR COUNTER");
		$display("=====================================================");

		tim_pwdata = 0;
		tim_pwdata[0] = 1;
		master_write(TCR, tim_pwdata, BYTE0);

		repeat(100) @(posedge sys_clk);
		master_read(TDR0, data);
		if(data !== 32'h0)begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Counter count up | Count value = %0x%s", GREEN, $time, data, RESET);
			$display("----------------------------------------------------------");
		end else begin
			$display("----------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Counter not count | Count value = %0x%s", RED, $time, data, RESET);
			$display("----------------------------------------------------------");
			error = error + 1;
		end

		tim_pwdata = 0;
		tim_pwdata[0] = 0;
		master_write(TCR, tim_pwdata, BYTE0);
		master_read(TDR0, data);
		if(data === 32'h0)begin
                        $display("----------------------------------------------------------");
                        $display("%sTIME: %0t, PASS | Counter clear | Count value = %0x%s", GREEN, $time, data, RESET);
                        $display("----------------------------------------------------------");
                end else begin
                        $display("----------------------------------------------------------");
                        $display("%sTIME: %0t, FAIL | Counter not clear | Count value = %0x%s", RED, $time, data, RESET);
                        $display("----------------------------------------------------------");
                        error = error + 1;
                end 

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$dislpay("FAIL TESTCASE");
		end
	end
endtask
