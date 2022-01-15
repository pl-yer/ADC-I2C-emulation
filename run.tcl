set project ADC_I2C_emulation
set top_module i2c_master
set target xc7z020clg400
set bitstream_file build/${project}.runs/impl_1/${top_module}.bit

proc usage {} {
    puts "usage: vivado -mode tcl -source [info script] -tclargs \[simulation/bitstream/program\]"
    exit 1
}

if {($argc != 1) || ([lindex $argv 0] ni {"simulation" "bitstream" "program" "gooey"})} {
    usage
}

if {[lindex $argv 0] == "program"} {
    open_hw_manager
    connect_hw_server
    current_hw_target [get_hw_targets *]
    open_hw_target
    current_hw_device [lindex [get_hw_devices] 0]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

    set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
    set_property FULL_PROBES.FILE {} [lindex [get_hw_devices] 0]
    set_property PROGRAM.FILE ${bitstream_file} [lindex [get_hw_devices] 0]

    program_hw_devices [lindex [get_hw_devices] 0]
    refresh_hw_device [lindex [get_hw_devices] 0]
    
    exit
} else {
    file mkdir build
    create_project ${project} build -part ${target} -force
}

# read_xdc {
# }

# read_vhdl {
# }

# read_mem {
# }

add_files -fileset sim_1 {
	sim/i2c_master.vhd
	sim/tb_i2c_master.vhd
	sim/testbench.vhd
	sim/stimulus.vhd
	sim/rng.vhd
    sim/adc.vhd
}

set_property top ${top_module} [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

if {[lindex $argv 0] == "simulation"} {
    launch_simulation
    start_gui
}
if {[lindex $argv 0] == "bitstream"} {
	
	
	
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1

    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
    exit
}
if {[lindex $argv 0] == "gooey"} {
    start_gui
}

