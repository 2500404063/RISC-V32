@echo off
iverilog -o rv32.out ./tb/tb.v
vvp ./rv32.out
if %0 == "w" goto show else goto end
:show
gtkwave ./wave.vcd
:end