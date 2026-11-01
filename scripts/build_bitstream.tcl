set top_module "hft_top"
set part_name  "xc7a100tfgg484-2"

set rtl_files [glob -nocomplain ./hw/rtl/*.sv ./hw/rtl/*.v]
if {[llength $rtl_files] == 0} {
    puts "BLAD: Brak plikow .sv w katalogu ./hw/rtl/!"
    exit 1
}

read_verilog -sv $rtl_files

set xdc_files [glob -nocomplain ./hw/constraints/*.xdc]
if {[llength $xdc_files] > 0} {
    read_xdc $xdc_files
}

synth_design -top $top_module -part $part_name
opt_design
place_design
route_design

file mkdir ./bitstreams
write_bitstream -force ./bitstreams/${top_module}.bit
puts "---> Wygenerowano bitstream: ./bitstreams/${top_module}.bit"
