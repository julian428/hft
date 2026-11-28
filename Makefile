BITSTREAM ?= bitstreams/hft_top.bit
SV_FILES  := $(shell find hw/rtl hw/tb -type f \( -name '*.sv' -o -name '*.svh' \) 2>/dev/null | sort)

.PHONY: vivado-gui bitstream flash fmt fmt-check clean

# 1. Tworzy i otwiera projekt w GUI Vivado (Linux)
vivado-gui:
	vivado -source scripts/create_project.tcl > /dev/null &

# 2. Kompiluje bitstream w trybie bezokienkowym (Linux)
bitstream:
	vivado -mode batch -source scripts/build_bitstream.tcl

# 3. Programuje płytkę Artix-7 na serwerze Dell Wyse
flash:
	openFPGALoader -c digilent_hs3 $(BITSTREAM)

# 4. Formatuje pliki SystemVerilog za pomocą Verible
fmt:
	verible-verilog-format --flagfile=.verible-format --inplace $(SV_FILES)

# 5. Sprawdza formatowanie SystemVerilog bez modyfikacji plików
fmt-check:
	@status=0; \
	for f in $(SV_FILES); do \
		verible-verilog-format --flagfile=.verible-format "$$f" | diff -u "$$f" - >/dev/null || { echo "Wymaga formatowania: $$f"; status=1; }; \
	done; \
	exit $$status

# 6. Czyści lokalne pliki robocze i artefakty Vivado/XSim
clean:
	rm -rf vivado_work *.jou *.log *.str *.pb *.wdb *.dcp .Xil xsim.dir clockInfo.txt vivado_featurestore.json webtalk* usage_statistics_webtalk.*
