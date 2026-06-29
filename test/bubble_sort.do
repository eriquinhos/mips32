onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_bubble_sort/real_clk
add wave -noupdate /tb_bubble_sort/uut/real_clk
add wave -noupdate /tb_bubble_sort/uut/cpu/real_clk
add wave -noupdate /tb_bubble_sort/uut/cpu/clk
add wave -noupdate -radix binary /tb_bubble_sort/uut/cpu/instr
add wave -noupdate /tb_bubble_sort/uut/cpu/zero
add wave -noupdate -radix decimal /tb_bubble_sort/uut/out_mod/tmp
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[1]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[2]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[3]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[4]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[5]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[6]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[8]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/reg_file/registers[9]}
add wave -noupdate -radix unsigned /tb_bubble_sort/uut/out_mod/seg1
add wave -noupdate -radix unsigned /tb_bubble_sort/uut/out_mod/seg2
add wave -noupdate -radix unsigned /tb_bubble_sort/uut/out_mod/seg3
add wave -noupdate -radix unsigned /tb_bubble_sort/uut/out_mod/seg4
add wave -noupdate -radix unsigned /tb_bubble_sort/uut/out_mod/seg5
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/mem_inst/ram[361]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/mem_inst/ram[362]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/mem_inst/ram[363]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/mem_inst/ram[364]}
add wave -noupdate -radix unsigned {/tb_bubble_sort/uut/cpu/mem_inst/ram[365]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4998955869 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
configure wave -valuecolwidth 40
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
WaveRestoreZoom {92487479 ps} {93158554 ps}
