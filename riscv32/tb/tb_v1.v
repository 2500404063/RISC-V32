`include "./rtl/core/core_clk.v"
`include "./rtl/mem/sram_axi_master.v"
`include "./rtl/mem/sram_axi_slaver.v"
`include "./rtl/core_pipe_if.v"

`timescale 1ns/1ns
module rv32_tb (

);

//50 Mhz = 1/50 us = 20 ns
reg clk;
reg rst_n;

reg                 en;
reg                 wen;
reg[31:0]           addr;
reg[1:0]            size;
reg[31:0]           din;
wire[31:0]          dout;
wire                done;

//Write Address
wire[31:0]          awaddr;
wire[1:0]           awsize;
wire                awvalid;
wire                awready;
//Write Data
wire[31:0]          wdata;
wire                wvalid;
wire                wready;
//Write Response
wire                bvalid;
wire                bready;
//Read Address
wire[31:0]          araddr;
wire[1:0]           arsize;
wire                arvalid;
wire                arready;
//Read Data
wire[31:0]          rdata;
wire                rvalid;
wire                rready;

mem_sram_axi_master sram_master(
    //control
    .en(en),
    .wen(wen),
    .addr(addr),
    .size(size),
    .din(din),
    .dout(dout),
    .done(done),
    //global
    .clk(clk),
    .rst_n(rst_n),
    //axi read address
    .araddr(araddr),
    .arsize(arsize),
    .arvalid(arvalid),
    .arready(arready),
    //axi read data
    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready),
    //axi write address
    .awaddr(awaddr),
    .awsize(awsize),
    .awvalid(awvalid),
    .awready(awready),
    //axi write data
    .wdata(wdata),
    .wvalid(wvalid),
    .wready(wready),
    //axi write response
    .bvalid(bvalid),
    .bready(bready)
);

mem_sram_axi_slaver sram_slaver(
    //global
    .clk(clk),
    .rst_n(rst_n),
    //axi read address
    .araddr(araddr),
    .arsize(arsize),
    .arvalid(arvalid),
    .arready(arready),
    //axi read data
    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready),
    //axi write address
    .awaddr(awaddr),
    .awsize(awsize),
    .awvalid(awvalid),
    .awready(awready),
    //axi write data
    .wdata(wdata),
    .wvalid(wvalid),
    .wready(wready),
    //axi write response
    .bvalid(bvalid),
    .bready(bready)
);

initial begin
    $display("Hello, have a good day~");
    $dumpfile("wave.vcd");
    $dumpvars;
    clk         <= 1'b0;
    rst_n       <= 1'b1;
    #10 rst_n   <= 1'b0;
    #20 rst_n   <= 1'b1;

    wen <= 1'b1;
    addr <= 32'd0;
    size <= 2'b10;
    din <=32'b11110000_00001111_11001100_10101010;
    en <= 1;

    #200;

    wen <= 1'b0;
    addr <= 32'd8;
    size <= 2'b10;
    en <= 1'b1;

    #100_0000 $finish; //10 ms
end

always @(*) begin
    if (done) begin
        en <= 1'b0;
    end
end


always begin
    #10
    clk <= ~clk;
end

endmodule