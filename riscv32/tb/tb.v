`include "./rtl/core/core_clk.v"
`include "./rtl/core/core_pipe_top.v"

`timescale 1ns/1ns
module rv32_tb (

);

//50 Mhz = 1/50 us = 20 ns
reg clk;
reg rst_n;

wire pipe_clk;
wire sram_clk;

core_clk core_clk_inst(
    .clk(clk),
    .rst_n(rst_n),
    .pipe_clk(pipe_clk),
    .sram_clk(sram_clk)
);

core_pipe_top pipe_top_inst(
    .clk(pipe_clk),
    .sram_clk(sram_clk),
    .rst_n(rst_n)
);

initial begin
    $display("Hello, have a good day~");
    $dumpfile("wave.vcd");
    $dumpvars;
    clk         <= 1'b0;
    rst_n       <= 1'b1;
    #10 rst_n   <= 1'b0;
    #20 rst_n   <= 1'b1;

    #100_0000 $finish;
end

always begin
    #10
    clk <= ~clk;
end

endmodule