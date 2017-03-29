# makefile

help:
	@echo "HELP"
	@echo ""
	@echo "burn:       Flash/burn the board"
	@echo "compile:    Compile the emulator"
	@echo "run:        Run the emulator - will compile first if necessary"

run: install compile
	@echo Running:
	@vvp em.vvp

install: /usr/local/bin/iverilog

/usr/local/bin/iverilog:
	@echo Installing iverilog
	@brew install icarus-verilog

compile: em.vvp

burn: em.vvp
	python3 ../el.py /dev/ttyACM0 mymodule.bin

em.vvp: emulator.v
	@echo Compiling emulator
	iverilog -o em.vvp emulator.v
