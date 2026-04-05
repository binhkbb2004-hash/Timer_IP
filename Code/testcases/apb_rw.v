task run_test();
	begin	
		$display("=================================================================");
		$display("TESTCASE: APB PROTOCOL");
		$display("=================================================================");

		//write error (psel = 0)
		tim_psel_err = 1;
		ms_write(TDR0, 32'hFFFF_FFFF, FULL_WORD);
		tim_psel_err = 0;
		ms_read(TDR0, data);	//read normal
		cmp_data(data, 32'h0);
		
		//write normal
		ms_write(TDR0, 32'hFFFF_FFFF, FULL_WORD);	//write normal
		ms_read(TDR0, data);	//read normal
		cmp_data(data, 32'hFFFF_FFFF);
		
		//read error (psel = 0)
		tim_psel_err = 1;
		ms_read(TDR0, data);
		cmp_data(data, 32'h0);
		
		//write error (penable = 0)
		tim_psel_err = 0;
		tim_penable_err = 1;
		ms_write(TCR, 32'h302, FULL_WORD);
		tim_penable_err = 0;
		ms_read(TCR, data);	//read normal
		cmp_data(data, 32'h100);
		
		//write normal 
		ms_write(TCR, 32'h302, FULL_WORD);
		ms_read(TCR, data);
		cmp_data(data, 32'h302);

		ms_write(TCR, 32'h300, FULL_WORD);
		//read error (penable = 0)
		tim_penable_err = 1;
		ms_read(TDR1, data);
		cmp_data(data, 32'h0);
		
		//read normal
		tim_penable_err = 0;
		ms_read(TCR, data);
		cmp_data(data, 32'h300);	
		

		if(error === 0)begin
			$display("PASS TESTCASE");
		end else begin
			$display("FAIL TESTCASE");
		end
		/*
		@(posedge sys_clk);
		tim_psel = 0;
		tim_penable = 1;
		tim_pwrite = 1;
	
		@(posedge sys_clk);
		tim_psel = 0;
		tim_penable = 1;
		tim_pwrite = 0;		
		*/
	end
endtask

task ms_write(input [11:0]paddr, input [31:0]pwdata, input [3:0]pstrb);
	begin
		@(posedge sys_clk);
		#1;
		tim_pwrite = 1;
		tim_psel = 1 & (!tim_psel_err);
		tim_pwdata = pwdata;
		tim_pstrb = pstrb;
		tim_paddr = paddr;

		@(posedge sys_clk);
		#1;
		tim_penable = 1 & (!tim_penable_err);

		if(tim_psel_err | tim_penable_err)begin
			$display("----------------------------------------------------------"); 
                        $display("TIME: %0t, Write not valid when error at addr: 12'h%h, data: 32'h%h", $time, paddr, pwdata);
                        $display("----------------------------------------------------------");
		end else begin
			wait(tim_pready);
			$display("----------------------------------------------------------");
                        $display("TIME: %0t, Write valid at addr: 12'h%h, data: 32'h%h", $time, paddr, pwdata);
                        $display("----------------------------------------------------------");
		end
		
		@(posedge sys_clk);
		tim_psel = 0;
		#1;
		tim_pwrite = 0;
		tim_penable = 0;
		tim_paddr = 0;
		tim_pwdata = 0;
		tim_pstrb = 0;
	end
endtask

task ms_read(input [11:0]paddr, output [31:0]prdata);
	begin
		@(posedge sys_clk);
		#1;
		tim_paddr = paddr;
		tim_psel = 1 & (!tim_psel_err);
		tim_pwrite = 0;

		@(posedge sys_clk);
		#1;
		tim_penable = 1 & (!tim_penable_err);
		
		if(tim_psel_err | tim_penable_err)begin
                        $display("----------------------------------------------------------");
                        $display("TIME: %0t, Read not valid when error at addr: 12'h%h", $time, paddr);
                        $display("----------------------------------------------------------");
                end else begin
                        wait(tim_pready);
			#1;
			prdata = tim_prdata;
                        $display("----------------------------------------------------------");
                        $display("TIME: %0t, Read valid at addr: 12'h%h, data: 32'h%h", $time, paddr, tim_prdata);
                        $display("----------------------------------------------------------");
                end
		
		@(posedge sys_clk);
		prdata = tim_prdata;
		tim_psel = 0;
		#1;
		tim_paddr = 0;
		tim_penable = 0;
	end
endtask
