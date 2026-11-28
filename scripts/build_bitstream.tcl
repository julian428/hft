set top_module "hft_top"
set part_name  "xc7a100tfgg484-2"

proc find_files {dir patterns} {
    set result {}
    if {![file isdirectory $dir]} {
        return $result
    }
    foreach pattern $patterns {
        foreach f [glob -nocomplain -type f -directory $dir $pattern] {
            lappend result $f
        }
    }
    foreach subdir [glob -nocomplain -type d -directory $dir *] {
        set result [concat $result [find_files $subdir $patterns]]
    }
    return [lsort $result]
}

set rtl_files [find_files "./hw/rtl" {*.sv *.v}]
if {[llength $rtl_files] == 0} {
    puts "BLAD: Brak plikow .sv/.v w katalogu ./hw/rtl/!"
    exit 1
}

read_verilog -sv $rtl_files

set xdc_files [find_files "./hw/constraints" {*.xdc}]
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
