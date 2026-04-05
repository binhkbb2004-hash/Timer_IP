##################################################################################################
#This file created by Huy Nguyen
#Updated date: 6/30/2019
#Example run string: make TESTNAME={name_of_testcase} {optional}
#		     make TESTNAME=counter_test all 
##################################################################################################
#Define variables
TESTNAME 	?= sanity_test
TB_NAME 	?= test_bench
RADIX		?= decimal
MEALY_FSM   ?= 0

#==============================
all: build run

all_wave: build run wave

all_cov: build_cov run_cov
drc:
	verilator --lint-only -Wall -f rtl.f
build:
	cp -rf ../testcases/$(TESTNAME).v run_test.v
	vlib work
	vmap work work
	vlog  -f compile.f | tee compile.log
build_cov:
	cp -rf ../testcases/$(TESTNAME).v run_test.v
	vlib work
	vmap work work
	vlog +cover=bcesft -f compile.f
run:
	vsim -debugDB -l $(TESTNAME).log -voptargs=+acc -assertdebug -c $(TB_NAME) -do "log -r /*;run -all;" -GMEALY_FSM=$(MEALY_FSM)
	cp -rf $(TESTNAME).log log/
	mv $(TESTNAME).log sim.log
run_cov:
	vsim -coverage -l $(TESTNAME).log -c $(TB_NAME) -voptargs="+cover=bcesft" -assertdebug -do "coverage save -onexit $(TESTNAME).ucdb; log -r /*;run -all"
	cp -rf $(TESTNAME).log log/
	mv $(TESTNAME).log sim.log
	mv $(TESTNAME).ucdb ucdb/
wave:
	vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &
view_cov:
	vsim -gui -viewcov IP.ucdb &
gen_cov:
	mkdir -p coverage
	vcover merge IP.ucdb ucdb/*.ucdb
	vcover report IP.ucdb -output coverage/summary_report.txt
	vcover report -zeros -details -code bcesft -annotate -All -codeAll IP.ucdb -output coverage/detail_report.txt
gen_html:
	mkdir -p coverage
	vcover merge IP.ucdb ucdb/*.ucdb
	vcover report -zeros -details -code bcesft -annotate -testhitdataAll -html IP.ucdb 
clean:
	rm -rf work
	rm -rf vsim.dbg
	rm -rf *.ini
	rm -rf *.log
	rm -rf *.wlf
	rm -rf transcript
	rm -rf *.ucdb
help:
	@echo ""
	@echo "****************************************"
	@echo "** make clean    : clean all compiled data"
	@echo "** make build    : build the design"
	@echo "** make build_cov: build the design in coverage mode"
	@echo "** make run      : run simulation"
	@echo "** make run_cov  : run simulation in coverage mode"
	@echo "** make all      : build and run simulation"
	@echo "** make all_cov  : build and run simulation in coverage mode"
	@echo "** make wave     : open waveform"
	@echo "** make gen_cov  : merge, generate coverage data base and text coverage report"
	@echo "** make gen_cov  : merge, gemerate coverage data base and html coverage report"
	@echo "****************************************"
	@echo ""


group:
	make all_cov TESTNAME=apb_pstrb
	make all_cov TESTNAME=check_interrupt
	make all_cov TESTNAME=clear_counter
	make all_cov TESTNAME=counting_control_mode_0
	make all_cov TESTNAME=counting_control_mode_diff
	make all_cov TESTNAME=counting_default_mode
	make all_cov TESTNAME=halt_mode
	make all_cov TESTNAME=reg_default_val
	make all_cov TESTNAME=rw_check
	make all_cov TESTNAME=sanity_test
	make all_cov TESTNAME=apb_pslverr
	make all_cov TESTNAME=apb_multi_data
	make all_cov TESTNAME=apb_rw
	make all_cov TESTNAME=apb_pready
	make all_cov TESTNAME=rw1c
	make all_cov TESTNAME=resv_reg
