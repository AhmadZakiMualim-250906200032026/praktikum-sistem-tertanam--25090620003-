vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../../../Vivado/2026.1/Vivado/data/rsb/busdef" "+incdir+../../ipstatic" \
"C:/Vivado/2026.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Vivado/2026.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../modul 11.srcs/sources_1/imports/src/vga_sync.vhd" \
"../../../modul 11.srcs/sim_1/imports/sim/tb_vga_sync.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

