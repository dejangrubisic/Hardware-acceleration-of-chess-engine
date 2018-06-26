################################################################################
#    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
#    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
#    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
#
#    FILE            run
#
#    DESCRIPTION
#
################################################################################

# Create the library.
if [ file exists work] {
    vdel -all
}

vlib work

# compile DUT				

vcom ../../dut/common.vhd 
vcom ../../dut/adder.vhd
vcom ../../dut/b_eval_king.vhd
vcom ../../dut/b_eval_pawn.vhd
vcom ../../dut/w_eval_king.vhd
vcom ../../dut/w_eval_pawn.vhd
vcom ../../dut/choose_king.vhd
vcom ../../dut/reduction_coder.vhd
vcom ../../dut/fifo_reg.vhd
vcom ../../dut/fifo_top.vhd
vcom ../../dut/material_of_pieces.vhd
vcom ../../dut/memory_table.vhd
vcom ../../dut/memory_subsystem.vhd
vcom ../../dut/pawn_rank.vhd
vcom ../../dut/rank.vhd
vcom ../../dut/select_piece.vhd
vcom ../../dut/top_module.vhd
vcom ../../dut/top_with_memory.vhd
		
# compile testbench
vlog -sv \
    +incdir+$env(UVM_HOME) \
    +incdir+../sv \
    ../sv/eval_verif_pkg.sv \
    ../sv/eval_verif_top.sv

# run simulation
vopt eval_verif_top -o opttop +cover
vsim eval_verif_top -novopt +UVM_TESTNAME=test_eval_my_1 +UVM_VERBOSITY=UVM_LOW -sv_seed random
vsim -coverage opttop
coverage save eval_verif_top.ucdb

do wave.do 
run -all
