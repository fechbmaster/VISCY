CPU_SRC = cpu.vhd alu.vhd regfile.vhd 	# top-level must be first

# Default target
all: viscy.bit

# Elaboration targets (GHDL)
cpu_tb: alu.o regfile.o cpu.o cpu_tb.o
	ees-ghdl -e $@

# Simulation targets (GHDL)
sim-cpu_tb: cpu_tb
	./$< --wave=$<.ghw
	gtkwave -A $<.ghw &

# Synthesis & implementation (Xilinx)
cpu.ngc: ${CPU_SRC}
	ees-xst ${CPU_SRC}

viscy.bit: cpu.ngc
	ees-implement_viscy cpu.ngc

# Generic rule to analyze files
%.o: %.vhd
	ees-ghdl -a $<

# File dependences
cpu.o: alu.o regfile.o
cpu_tb.o: cpu.o

##### Clean #####
clean:
	ees-ghdl --remove
	rm -fr *.ghw *.o *.prj *.log *.ngc *.ngr *.prj *.bit *.ifn *.ipf \
		xlnx_auto_* *.xrpt xst_work implement_viscy
