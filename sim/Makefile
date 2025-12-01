export HOME := $(realpath ./..)
 
VCS         := vcs -full64 -licqueue -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ns -kdb -debug_access+all
SIMV        := ./simv
GTK_WAVE    := gtkwave
URG         := urg -full64 -warn none -format both
 
TEST        := svip_test
UVM_SEQ     := svip_host_dm_step_tmu_wr_vseq
all: compile simulate waveform coverage open_report
 
compile:
	${VCS}  -f ${HOME}/tb/compile.f -l compile.log -o simv 
simulate:
	${SIMV}  -l simulate.log
 
waveform:
	${GTK_WAVE} *.vcd &
 
clean:
	@find . -maxdepth 1 \( -type f -o -type d \) \( ! -name '.' -a ! -name 'Makefile' -a ! -name '*.csh' \
	-a ! -name '*.f' -a ! -name '*.pl' -a ! -name '*.py' -a ! -name '*.sh' \) -exec rm -rf {} +
 
.PHONY: all compile simulate  waveform
