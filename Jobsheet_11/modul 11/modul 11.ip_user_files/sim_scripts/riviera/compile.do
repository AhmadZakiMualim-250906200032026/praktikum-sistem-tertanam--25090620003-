transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../../../../../Vivado/2026.1/Vivado/data/rsb/busdef" "+incdir+../../ipstatic" -l xpm -l xil_defaultlib \
"C:/Vivado/2026.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"C:/Vivado/2026.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../modul 11.srcs/sources_1/imports/src/vga_sync.vhd" \
"../../../modul 11.srcs/sim_1/imports/sim/tb_vga_sync.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

