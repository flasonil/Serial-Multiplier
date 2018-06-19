rm -rf work
vlib work

vlog -sv -work work -quiet RTL/multiplier.sv

vlog -sv -work work -quiet TB/tb_multiplier.sv
