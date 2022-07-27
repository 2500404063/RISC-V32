/**
 * Author: Felix
 * Description: This module is the top of CPU, to make it simple, only shows the connections of Pipes.
*/

`include "./rtl/core/core_reg_arr.v"
`include "./rtl/core/core_reg_pc.v"
`include "./rtl/core/core_pipe_if.v"
`include "./rtl/core/core_pipe_id.v"
`include "./rtl/core/core_pipe_ie.v"
`include "./rtl/core/core_pipe_mem.v"
`include "./rtl/core/core_pipe_wb.v"
`include "./rtl/core/core_mem_mux.v"
`include "./rtl/mem/sram_axi_master.v"
`include "./rtl/mem/sram_axi_slaver.v"

module core_pipe_top (
    input       clk,
    input       sram_clk,
    input       rst_n
);

/*******************************************************
                           Init
********************************************************/

always @(negedge rst_n) begin
    if (!rst_n) begin
    end
end

/***********************************************************************
                        Register Array & PC
************************************************************************/

wire        reg_done;
wire[31:0]  reg_rs1_dout;
wire[31:0]  reg_rs2_dout;

core_reg_arr reg_arr_inst (
    .rst_n(rst_n),
    .wen(wb_reg_wen),
    .rs1_addr(ie_rs1),
    .rs2_addr(ie_rs2),
    .rd_addr(wb_rd_addr),
    .rd_din(wb_rd_din),
    .rs1_dout(reg_rs1_dout),
    .rs2_dout(reg_rs2_dout),
    .done(reg_done)
);

wire            pc_en;
wire[31:0]      pc_pcout;
wire            pc_done;

core_reg_pc     reg_pc_inst(
    .rst_n(rst_n),
    .wen(wb_pc_wen),
    .pcin(wb_pcin),
    .pcout(pc_pcout),
    .done(pc_done)
);

/***********************************************************************
                            SRAM Instantitate
************************************************************************/

//SRAM Master Control
wire                ram_en;
wire                ram_wen;
wire[31:0]          ram_addr;
wire[1:0]           ram_size;
wire[31:0]          ram_din;
wire[31:0]          ram_dout;
wire                ram_done;

//SRAM MUX
core_mem_mux mem_mux_inst (
    //IF
    .if_ram_en(if_ram_en),
    .if_ram_pc(if_ram_pc),
    //MEM
    .mem_ram_en(mem_ram_en),
    .mem_ram_wen(mem_ram_wen),
    .mem_ram_addr(mem_ram_addr),
    .mem_ram_size(mem_ram_size),
    .mem_ram_din(mem_ram_din),
    //sram interface
    .ram_en(ram_en),
    .ram_wen(ram_wen),
    .ram_addr(ram_addr),
    .ram_size(ram_size),
    .ram_din(ram_din)
);

//SRAM AXI BUS
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
    .en(ram_en),
    .wen(ram_wen),
    .addr(ram_addr),
    .size(ram_size),
    .din(ram_din),
    .dout(ram_dout),
    .done(ram_done),
    //global
    .clk(sram_clk),
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
    .clk(sram_clk),
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

/*****************************************************
 *                     Pipe IF
*****************************************************/

//IF Module
wire            if_allowin;
wire            if_validout;

wire            if_ram_en;
wire[31:0]      if_ram_pc;

core_pipe_if pipe_if_inst(
    //control
    .clk(clk),
    .rst_n(rst_n),
    .if_validout(if_validout),
    .if_allowin(if_allowin),
    .wb_validout(wb_validout),
    .mem_allowin(mem_allowin),
    //IE
    .ie_result_jmp(ie_result_jmp),
    .ie_result_pc(ie_result_pc),
    .ie_result_mem_load(ie_result_mem_load),
    .ie_result_mem_store(ie_result_mem_store),
    //PC
    .pc_pcout(pc_pcout),
    //ram
    .ram_done(ram_done),
    .if_ram_en(if_ram_en),
    .if_ram_pc(if_ram_pc)
);

/*****************************************************
 *                  Pipe ID
*****************************************************/

wire[31:0]    id_pc;
wire[4:0]     id_rd;
wire[2:0]     id_func3;
wire[4:0]     id_rs1;
wire[4:0]     id_rs2;
wire[6:0]     id_func7;
//Memory Instruction   8
wire          id_LB;
wire          id_LH;
wire          id_LW;
wire          id_LBU;
wire          id_LHU;
wire          id_SB;
wire          id_SH;
wire          id_SW;
//Control Transfer     8
wire          id_BEQ;
wire          id_BNE;
wire          id_BLT;
wire          id_BGE;
wire          id_BLTU;
wire          id_BGEU;
wire          id_JAL;
wire          id_JALR;
//Computational        18
wire          id_SLL;
wire          id_SLLI;
wire          id_SRL;
wire          id_SRLI;
wire          id_ADD;
wire          id_ADDI;
wire          id_SUB;
wire          id_LUI;
wire          id_AUIPC;
wire          id_AND;
wire          id_ANDI;
wire          id_OR;
wire          id_ORI;
wire          id_XOR;
wire          id_XORI;
wire          id_SLT;
wire          id_SLTU;
wire          id_SLTI;
wire          id_SLTIU;

wire     id_validout;

core_pipe_id pipe_id_inst(
    //control
    .clk(clk),
    .rst_n(rst_n),
    .id_validout(id_validout),
    .if_validout(if_validout),
    .mem_allowin(mem_allowin),
    //inst and pc
    .ram_dout(ram_dout),
    .if_ram_pc(if_ram_pc),
    //data out
    .id_pc(id_pc),
    .id_rd(id_rd),
    .id_func3(id_func3),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),
    .id_func7(id_func7),
    //OP Wires
    //Memory Instruction   8
    .LB(id_LB),
    .LH(id_LH),
    .LW(id_LW),
    .LBU(id_LBU),
    .LHU(id_LHU),
    .SB(id_SB),
    .SH(id_SH),
    .SW(id_SW),
    //Transfer Control     8
    .BEQ(id_BEQ),
    .BNE(id_BNE),
    .BLT(id_BLT),
    .BGE(id_BGE),
    .BLTU(id_BLTU),
    .BGEU(id_BGEU),
    .JAL(id_JAL),
    .JALR(id_JALR ),
    //Computational        18
    .SLL(id_SLL),
    .SLLI(id_SLLI),
    .SRL(id_SRL),
    .SRLI(id_SRLI),
    .ADD(id_ADD),
    .ADDI(id_ADDI),
    .SUB(id_SUB),
    .LUI(id_LUI),
    .AUIPC(id_AUIPC),
    .AND(id_AND),
    .ANDI(id_ANDI),
    .OR(id_OR),
    .ORI(id_ORI),
    .XOR(id_XOR),
    .XORI(id_XORI),
    .SLT(id_SLT),
    .SLTU(id_SLTU),
    .SLTI(id_SLTI),
    .SLTIU(id_SLTIU)
);

/*****************************************************
 *                     Pipe IE
*****************************************************/
wire     ie_validout;

wire[4:0]    ie_rd;
wire[4:0]    ie_rs1;
wire[4:0]    ie_rs2;

//Memory Instruction
wire              ie_result_mem_load;
wire              ie_result_mem_store;
wire[1:0]         ie_result_mem_size;
wire[31:0]        ie_result_mem_addr;
wire[31:0]        ie_result_mem_din;
//Transfer Control
wire[31:0]        ie_result_pc;
wire              ie_result_jmp;
wire              ie_result_link;
wire[31:0]        ie_result_link_addr;
//Computational
wire[31:0]        ie_result_value;
wire              ie_result_computed;

core_pipe_ie pipe_ie_inst(
    .clk(clk),
    .rst_n(rst_n),
    .ie_validout(ie_validout),
    .mem_allowin(mem_allowin),
    .id_validout(id_validout),
    //Value
    .id_pc(id_pc),
    .id_rd(id_rd),
    .id_func3(id_func3),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),
    .id_func7(id_func7),
    //Memory Instruction
    .id_op_LB(id_LB),
    .id_op_LH(id_LH),
    .id_op_LW(id_LW),
    .id_op_LBU(id_LBU),
    .id_op_LHU(id_LHU),
    .id_op_SB(id_SB),
    .id_op_SH(id_SH),
    .id_op_SW(id_SW),
    //Transfer Control
    .id_op_BEQ(id_BEQ),
    .id_op_BNE(id_BNE),
    .id_op_BLT(id_BLT),
    .id_op_BGE(id_BGE),
    .id_op_BLTU(id_BLTU),
    .id_op_BGEU(id_BGEU),
    .id_op_JAL(id_JAL),
    .id_op_JALR(id_JALR),
    //Computational
    .id_op_SLL(id_SLL),
    .id_op_SLLI(id_SLLI),
    .id_op_SRL(id_SRL),
    .id_op_SRLI(id_SRLI),
    .id_op_ADD(id_ADD),
    .id_op_ADDI(id_ADDI),
    .id_op_SUB(id_SUB),
    .id_op_LUI(id_LUI),
    .id_op_AUIPC(id_AUIPC),
    .id_op_AND(id_AND),
    .id_op_ANDI(id_ANDI),
    .id_op_OR(id_OR),
    .id_op_ORI(id_ORI),
    .id_op_XOR(id_XOR),
    .id_op_XORI(id_XORI),
    .id_op_SLT(id_SLT),
    .id_op_SLTU(id_SLTU),
    .id_op_SLTI(id_SLTI),
    .id_op_SLTIU(id_SLTIU),
    //Result Output
    //Memory Instruction
    .result_mem_load(ie_result_mem_load),
    .result_mem_store(ie_result_mem_store),
    .result_mem_size(ie_result_mem_size),
    .result_mem_addr(ie_result_mem_addr),
    .result_mem_din(ie_result_mem_din),
    //Transfer Control
    .result_pc(ie_result_pc),
    .result_jmp(ie_result_jmp),
    .result_link(ie_result_link),
    .result_link_addr(ie_result_link_addr),
    //Computational
    .result_value(ie_result_value),
    .result_computed(ie_result_computed),
    //reg array control
    .ie_rd(ie_rd),
    .ie_rs1(ie_rs1),
    .ie_rs2(ie_rs2),
    .reg_rs1_dout_old(reg_rs1_dout),
    .reg_rs2_dout_old(reg_rs2_dout),
    //MEM Data conflict
    .mem_rd(mem_rd),
    .mem_result_mem_load(mem_result_mem_load),
    .ram_dout(ram_dout),
    .mem_result_computed(mem_result_computed),
    .mem_result_value(mem_result_value)
);

/*****************************************************
 *                  Pipe MEM
*****************************************************/

wire        mem_validout;
wire        mem_allowin;

wire[4:0]     mem_rd;
wire[4:0]     mem_rs1;
wire[4:0]     mem_rs2;

wire          mem_result_mem_load;
wire          mem_write_rd;

wire[31:0]    mem_result_pc;
wire          mem_result_jmp;
wire          mem_result_link;
wire[31:0]    mem_result_link_addr;

wire[31:0]    mem_result_value;
wire          mem_result_computed;

wire          mem_ram_en;
wire          mem_ram_wen;
wire[31:0]    mem_ram_addr;
wire[1:0]     mem_ram_size;
wire[31:0]    mem_ram_din;

core_pipe_mem pipe_mem_inst(
    .clk(clk),
    .rst_n(rst_n),
    .mem_validout(mem_validout),
    .mem_allowin(mem_allowin),
    .ie_validout(ie_validout),
    .wb_allowin(wb_allowin),
    //reg
    .ie_rd(ie_rd),
    .ie_rs1(ie_rs1),
    .ie_rs2(ie_rs2),
    //results
    //Memory Instruction
    .ie_result_mem_size(ie_result_mem_size),
    .ie_result_mem_load(ie_result_mem_load),
    .ie_result_mem_store(ie_result_mem_store),
    .ie_result_mem_addr(ie_result_mem_addr),
    .ie_result_mem_din(ie_result_mem_din),
    //Transfer Control
    .ie_result_pc(ie_result_pc),
    .ie_result_jmp(ie_result_jmp),
    .ie_result_link(ie_result_link),
    .ie_result_link_addr(ie_result_link_addr),
    //Computational
    .ie_result_value(ie_result_value),
    .ie_result_computed(ie_result_computed),
    //keep for wb
    //regs
    .mem_rd(mem_rd),
    .mem_rs1(mem_rs1),
    .mem_rs2(mem_rs2),
    //memory read
    .mem_result_mem_load(mem_result_mem_load),
    .mem_write_rd(mem_write_rd),
    //Transfer Control
    .mem_result_pc(mem_result_pc),
    .mem_result_jmp(mem_result_jmp),
    .mem_result_link(mem_result_link),
    .mem_result_link_addr(mem_result_link_addr),
    //Computational
    .mem_result_value(mem_result_value),
    .mem_result_computed(mem_result_computed),
    //ram control
    .ram_done(ram_done),
    .ram_dout(ram_dout),
    .mem_ram_en(mem_ram_en),
    .mem_ram_wen(mem_ram_wen),
    .mem_ram_addr(mem_ram_addr),
    .mem_ram_size(mem_ram_size),
    .mem_ram_din(mem_ram_din)
);

/*****************************************************
 *                  Pipe WB
*****************************************************/
wire            wb_allowin;
wire            wb_validout;
//ram
wire            wb_ram_en;
wire[31:0]      wb_pc;
//register control
wire            wb_reg_wen;
wire[4:0]       wb_rd_addr;
wire[31:0]      wb_rd_din;
//PC control
wire            wb_pc_wen;
wire[31:0]      wb_pcin;

core_pipe_wb pipe_wb_inst(
    .clk(clk),
    .rst_n(rst_n),
    .wb_allowin(wb_allowin),
    .wb_validout(wb_validout),
    .if_allowin(if_allowin),
    .mem_validout(mem_validout),
    //regs
    .mem_rd(mem_rd),
    .mem_rs1(mem_rs1),
    .mem_rs2(mem_rs2),
    //memory
    .mem_write_rd(mem_write_rd),
    .ram_dout(ram_dout),
    //transfer
    .mem_result_pc(mem_result_pc),
    .mem_result_jmp(mem_result_jmp),
    .mem_result_link(mem_result_link),
    .mem_result_link_addr(mem_result_link_addr),
    //Computational
    .mem_result_value(mem_result_value),
    .mem_result_computed(mem_result_computed),
    //register control
    .wb_reg_done(reg_done),
    .wb_reg_wen(wb_reg_wen),
    .wb_rd_addr(wb_rd_addr),
    .wb_rd_din(wb_rd_din),
    //PC control
    .pc_done(pc_done),
    .pc_pcout(pc_pcout),
    .wb_pc_wen(wb_pc_wen),
    .wb_pcin(wb_pcin)
);

endmodule