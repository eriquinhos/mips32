onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fibonacci/uut/cpu/pc_out
add wave -noupdate -radix hexadecimal /tb_fibonacci/uut/cpu/instr
add wave -noupdate /tb_fibonacci/uut/cpu/ctrl_unit/next_state_r
add wave -noupdate /tb_fibonacci/uut/cpu/ctrl_unit/state_r
add wave -noupdate -radix decimal {/tb_fibonacci/uut/cpu/reg_file/registers[8]}
add wave -noupdate -radix decimal {/tb_fibonacci/uut/cpu/reg_file/registers[9]}
add wave -noupdate -radix decimal {/tb_fibonacci/uut/cpu/reg_file/registers[10]}
add wave -noupdate -radix decimal /tb_fibonacci/uut/out_mod/tmp
add wave -noupdate -radix unsigned /tb_fibonacci/uut/out_mod/seg1
add wave -noupdate -radix unsigned /tb_fibonacci/uut/out_mod/seg2
add wave -noupdate -radix unsigned /tb_fibonacci/uut/out_mod/seg3
add wave -noupdate -radix unsigned /tb_fibonacci/uut/out_mod/seg4
add wave -noupdate -radix unsigned /tb_fibonacci/uut/out_mod/seg5
add wave -noupdate /tb_fibonacci/real_clk
add wave -noupdate /tb_fibonacci/uut/real_clk
add wave -noupdate /tb_fibonacci/uut/cpu/real_clk
add wave -noupdate /tb_fibonacci/uut/cpu/clk
add wave -noupdate /tb_fibonacci/uut/cpu/ctrl_unit/ctrl_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {605000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 249
configure wave -valuecolwidth 46
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {883177 ps}
