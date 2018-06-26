onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eval_verif_top/eval_vif/clk
add wave -noupdate /eval_verif_top/eval_vif/rst
add wave -noupdate -color Magenta /eval_verif_top/eval_vif/reg_data_in
add wave -noupdate -color Yellow /eval_verif_top/eval_vif/start_wr_in
add wave -noupdate -color Yellow /eval_verif_top/eval_vif/start_axi_out
add wave -noupdate -color Cyan /eval_verif_top/eval_vif/side_wr_in
add wave -noupdate -color Cyan /eval_verif_top/eval_vif/side_axi_out
add wave -noupdate /eval_verif_top/eval_vif/mem_data_in
add wave -noupdate /eval_verif_top/eval_vif/mem_wr_in
add wave -noupdate /eval_verif_top/eval_vif/mem_wr_addr_in
add wave -noupdate -color red -radix decimal /eval_verif_top/eval_vif/result_axi_out
add wave -noupdate -color red /eval_verif_top/eval_vif/finished_axi_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {850 ns} 0}
configure wave -namecolwidth 257
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {8671 ns}
