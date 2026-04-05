task run_test();
	reg [31:0]pwdata;
	begin
		$display("=========================================================");
		$display("TESTCASE: CHECK PREADY");
		$display("=========================================================");	
		
		pwdata = 32'hFF;
		check_pready_write(TDR0, pwdata, FULL_WORD);
		check_pready_read(TDR0, data);
		cmp_data(data, pwdata);

		pwdata = 0;
		pwdata[0] = 1;
		check_pready_write(TIER, pwdata, BYTE1);
		check_pready_read(TIER, data);
		cmp_data(data, 32'h0);

		check_pready_write(TISR, pwdata, BYTE1);
		check_pready_read(TISR, data);
		cmp_data(data, 32'h0);
		
		check_pready_write(THCSR, pwdata, BYTE1);
		check_pready_read(THCSR, data);
		cmp_data(data, 32'h0);

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
	end
endtask

task check_pready_write(input [11:0]paddr, input [31:0]pwdata, input [3:0]pstrb);
	begin
		$display("----------------------------------------------------------");	
		$display("TIME: %0t, [INFO] Write data at addr: 12'h%x, data: 32'h%x, pstrb: 4'b%4b", $time, paddr, pwdata, pstrb);
		$display("----------------------------------------------------------");

		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_paddr = paddr;
		tim_pwdata = pwdata;
		tim_pstrb = pstrb;
		tim_pwrite = 1;
		
		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		
		#1;
		if(tim_pready === 1)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t | FAIL: Pready asserted same time as penable%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end

		wait(tim_pready);
		@(posedge sys_clk);
		if(tim_pready === 1)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Pready is asserted properly%s", GREEN, $time, RESET);
			$display("------------------------------------------------------------");
		end else begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Pready is not asserted%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end
		#1;
		tim_pwrite = 0;
		tim_paddr = 0;
		tim_pwdata = 0;
		tim_psel = 0;
		tim_penable = 0;
		tim_pstrb = 0;
	end
endtask

task check_pready_read(input[11:0]paddr, output [31:0]prdata);
	begin
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_paddr = paddr;
		tim_pwrite = 0;
		
		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		
		#1;
		if(tim_pready === 1)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t | FAIL: Pready asserted same time as penable%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end

		wait(tim_pready);
		@(posedge sys_clk);
		prdata = tim_prdata;
		$display("----------------------------------------------------------");
		$display("TIME: %0t, [INFO] Read data at addr: 12'h%x, data: 32'h%x", $time, paddr, prdata);
		$display("----------------------------------------------------------");

		if(tim_pready === 1)begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t, PASS | Pready is asserted properly%s", GREEN, $time, RESET);
			$display("------------------------------------------------------------");
		end else begin
			$display("------------------------------------------------------------");
			$display("%sTIME: %0t, FAIL | Pready is not asserted%s", RED, $time, RESET);
			$display("------------------------------------------------------------");
			error = error + 1;
		end
		#1;
		tim_psel = 0;
		tim_penable = 0;
		tim_paddr = 0;
	end
endtask

