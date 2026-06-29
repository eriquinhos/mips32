onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fibonacci_io/uut/cpu/pc_out
add wave -noupdate -radix hexadecimal /tb_fibonacci_io/uut/cpu/instr
add wave -noupdate /tb_fibonacci_io/uut/cpu/ctrl_unit/next_state_r
add wave -noupdate /tb_fibonacci_io/uut/cpu/ctrl_unit/state_r
add wave -noupdate -radix decimal {/tb_fibonacci_io/uut/cpu/reg_file/registers[8]}
add wave -noupdate -radix decimal {/tb_fibonacci_io/uut/cpu/reg_file/registers[9]}
add wave -noupdate -radix decimal {/tb_fibonacci_io/uut/cpu/reg_file/registers[10]}
add wave -noupdate -radix unsigned {/tb_fibonacci_io/uut/cpu/reg_file/registers[11]}
add wave -noupdate -radix decimal /tb_fibonacci_io/uut/out_mod/tmp
add wave -noupdate -radix unsigned /tb_fibonacci_io/uut/out_mod/seg1
add wave -noupdate -radix unsigned /tb_fibonacci_io/uut/out_mod/seg2
add wave -noupdate -radix unsigned /tb_fibonacci_io/uut/out_mod/seg3
add wave -noupdate -radix unsigned /tb_fibonacci_io/uut/out_mod/seg4
add wave -noupdate -radix unsigned /tb_fibonacci_io/uut/out_mod/seg5
add wave -noupdate /tb_fibonacci_io/real_clk
add wave -noupdate /tb_fibonacci_io/uut/real_clk
add wave -noupdate /tb_fibonacci_io/uut/cpu/real_clk
add wave -noupdate /tb_fibonacci_io/uut/cpu/clk
add wave -noupdate /tb_fibonacci_io/uut/cpu/ctrl_unit/ctrl_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {213724 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
configure wave -valuecolwidth 75
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
WaveRestoreZoom {0 ps} {356413 ps}
