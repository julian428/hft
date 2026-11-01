set proj_name "hft"
set proj_dir  "./vivado_work"
set part_name "xc7a100tfgg484-2"

# Tworzy czysty projekt Vivado w lokalnym katalogu ./vivado_work
create_project -force $proj_name $proj_dir -part $part_name

# Dodaje pliki RTL, jeśli jakieś istnieją w hw/rtl/
set rtl_files [glob -nocomplain ./hw/rtl/*.sv ./hw/rtl/*.v]
if {[llength $rtl_files] > 0} {
    add_files -fileset sources_1 $rtl_files
}

# Dodaje pliki przypisania pinów, jeśli istnieją w hw/constraints/
set xdc_files [glob -nocomplain ./hw/constraints/*.xdc]
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 $xdc_files
}

# Dodaje pliki testbenchy, jeśli istnieją w hw/tb/
set tb_files [glob -nocomplain ./hw/tb/*.sv]
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 $tb_files
}

update_compile_order -fileset sources_1
puts "---> Czysty projekt Vivado zostal utworzony w: $proj_dir/$proj_name.xpr"
