BITSTREAM ?= bitstreams/hft_top.bit

.PHONY: vivado-gui bitstream flash clean

# 1. Tworzy i otwiera projekt w GUI Vivado (Linux)
vivado-gui:
	vivado -source scripts/create_project.tcl &

# 2. Kompiluje bitstream w trybie bezokienkowym (Linux)
bitstream:
	vivado -mode batch -source scripts/build_bitstream.tcl

# 3. Programuje płytkę Artix-7 na serwerze Dell Wyse
flash:
	openFPGALoader -c digilent_hs3 $(BITSTREAM)

# 4. Czyści lokalne pliki robocze Vivado
clean:
	rm -rf vivado_work *.jou *.log *.str .Xil
