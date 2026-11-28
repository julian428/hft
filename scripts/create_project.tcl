set proj_name "hft"
set proj_dir  "./vivado_work"
set part_name "xc7a100tfgg484-2"

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

# Tworzy czysty projekt Vivado w lokalnym katalogu ./vivado_work
create_project -force $proj_name $proj_dir -part $part_name

# Dodaje pliki RTL (rekurencyjnie), jeśli jakieś istnieją w hw/rtl/
set rtl_files [find_files "./hw/rtl" {*.sv *.v}]
if {[llength $rtl_files] > 0} {
    add_files -fileset sources_1 $rtl_files
}

# Dodaje pliki przypisania pinów (rekurencyjnie), jeśli istnieją w hw/constraints/
set xdc_files [find_files "./hw/constraints" {*.xdc}]
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 $xdc_files
}

# Dodaje pliki testbenchy (rekurencyjnie), jeśli istnieją w hw/tb/
set tb_files [find_files "./hw/tb" {*.sv *.v}]
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 $tb_files
}

update_compile_order -fileset sources_1
puts "---> Czysty projekt Vivado zostal utworzony w: $proj_dir/$proj_name.xpr"
