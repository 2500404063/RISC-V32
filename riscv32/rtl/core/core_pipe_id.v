/***************
 * Author: Felix
 * Description: Pipe ID(Instruction Decode)  (the 2nd pipe)
 * Notes: The reson why I did not use OP Vectors is for
          extending more instructions in the future.
*******************/

module core_pipe_id (
    //Control
    input               clk,
    input               rst_n,
    input               if_validout,
    input               mem_allowin,
    output reg          id_validout,
    //inst and pc
    input[31:0]         ram_dout,
    input[31:0]         if_ram_pc,
    //Data out
    output reg[31:0]    id_pc,
    output reg[4:0]     id_rd,
    output reg[2:0]     id_func3,
    output reg[4:0]     id_rs1,
    output reg[4:0]     id_rs2,
    output reg[6:0]     id_func7,
    //OP Wires
    //Memory Instruction   8
    output              LB,
    output              LH,
    output              LW,
    output              LBU,
    output              LHU,
    output              SB,
    output              SH,
    output              SW,
    //Transfer Control     8
    output              BEQ,
    output              BNE,
    output              BLT,
    output              BGE,
    output              BLTU,
    output              BGEU,
    output              JAL,
    output              JALR,
    //Computational        19
    output              SLL,
    output              SLLI,
    output              SRL,
    output              SRLI,
    output              ADD,
    output              ADDI,
    output              SUB,
    output              LUI,
    output              AUIPC,
    output              AND,
    output              ANDI,
    output              OR,
    output              ORI,
    output              XOR,
    output              XORI,
    output              SLT,
    output              SLTU,
    output              SLTI,
    output              SLTIU
);

reg[6:0]            opcode;
reg                 decode_en;

//OP Code
wire    OP_0000011      = decode_en & ~opcode[6] & ~opcode[5]  & ~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1]  & opcode[0];
wire    OP_0100011      = decode_en & ~opcode[6] &  opcode[5]  & ~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1]  & opcode[0];
wire    OP_0110011      = decode_en & ~opcode[6] &  opcode[5]  &  opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1]  & opcode[0];
wire    OP_0010011      = decode_en & ~opcode[6] & ~opcode[5]  &  opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1]  & opcode[0];
wire    OP_0010111      = decode_en & ~opcode[6] & ~opcode[5]  &  opcode[4] & ~opcode[3] &  opcode[2] & opcode[1]  & opcode[0];
wire    OP_0110111      = decode_en & ~opcode[6] &  opcode[5]  &  opcode[4] & ~opcode[3] &  opcode[2] & opcode[1]  & opcode[0];
wire    OP_1100011      = decode_en &  opcode[6] &  opcode[5]  & ~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1]  & opcode[0];
wire    OP_1100111      = decode_en &  opcode[6] &  opcode[5]  & ~opcode[4] & ~opcode[3] &  opcode[2] & opcode[1]  & opcode[0];
wire    OP_1101111      = decode_en &  opcode[6] &  opcode[5]  & ~opcode[4] &  opcode[3] &  opcode[2] & opcode[1]  & opcode[0];
//Function Code 3
wire    FUNC3_000       = decode_en & ~id_func3[2]  & ~id_func3[1]   & ~id_func3[0];
wire    FUNC3_001       = decode_en & ~id_func3[2]  & ~id_func3[1]   &  id_func3[0];
wire    FUNC3_010       = decode_en & ~id_func3[2]  &  id_func3[1]   & ~id_func3[0];
wire    FUNC3_011       = decode_en & ~id_func3[2]  &  id_func3[1]   &  id_func3[0];
wire    FUNC3_100       = decode_en &  id_func3[2]  & ~id_func3[1]   & ~id_func3[0];
wire    FUNC3_101       = decode_en &  id_func3[2]  & ~id_func3[1]   &  id_func3[0];
wire    FUNC3_110       = decode_en &  id_func3[2]  &  id_func3[1]   & ~id_func3[0];
wire    FUNC3_111       = decode_en &  id_func3[2]  &  id_func3[1]   &  id_func3[0];
//Function Code 7
wire    FUNC7_0000000   = decode_en & ~id_func7[6]  & ~id_func7[5]   & ~id_func7[4]  & ~id_func7[3]  & ~id_func7[2]  & ~id_func7[1]  & ~id_func7[0];
wire    FUNC7_0100000   = decode_en & ~id_func7[6]  &  id_func7[5]   & ~id_func7[4]  & ~id_func7[3]  & ~id_func7[2]  & ~id_func7[1]  & ~id_func7[0];

//Memory Instruction   8
assign    LB      =   OP_0000011 & FUNC3_000;
assign    LH      =   OP_0000011 & FUNC3_001;
assign    LW      =   OP_0000011 & FUNC3_010;
assign    LBU     =   OP_0000011 & FUNC3_100;
assign    LHU     =   OP_0000011 & FUNC3_101;
assign    SB      =   OP_0100011 & FUNC3_000;
assign    SH      =   OP_0100011 & FUNC3_001;
assign    SW      =   OP_0100011 & FUNC3_010;

//Control Transfer     8
assign    BEQ     =   OP_1100011 & FUNC3_000;
assign    BNE     =   OP_1100011 & FUNC3_001;
assign    BLT     =   OP_1100011 & FUNC3_100;
assign    BGE     =   OP_1100011 & FUNC3_101;
assign    BLTU    =   OP_1100011 & FUNC3_110;
assign    BGEU    =   OP_1100011 & FUNC3_111;
assign    JAL     =   OP_1101111;
assign    JALR    =   OP_1100111;

//Computational      18
assign    SLL     =   OP_0110011 & FUNC3_001 & FUNC7_0000000;
assign    SLLI    =   OP_0010011 & FUNC3_001 & FUNC7_0000000;
assign    SRL     =   OP_0110011 & FUNC3_101 & FUNC7_0000000;
assign    SRLI    =   OP_0010011 & FUNC3_101 & FUNC7_0000000;
assign    SRA     =   OP_0110011 & FUNC3_101 & FUNC7_0100000;
assign    ADD     =   OP_0110011 & FUNC3_000 & FUNC7_0000000;
assign    ADDI    =   OP_0010011 & FUNC3_000;
assign    SUB     =   OP_0110011 & FUNC3_000 & FUNC7_0100000;
assign    LUI     =   OP_0110111;
assign    AUIPC   =   OP_0010111;
assign    AND     =   OP_0110011 & FUNC3_111 & FUNC7_0000000;
assign    ANDI    =   OP_0010011 & FUNC3_111;
assign    OR      =   OP_0110011 & FUNC3_110 & FUNC7_0000000;
assign    ORI     =   OP_0010011 & FUNC3_110;
assign    XOR     =   OP_0110011 & FUNC3_100 & FUNC7_0000000;
assign    XORI    =   OP_0010011 & FUNC3_100;
assign    SLT     =   OP_0110011 & FUNC3_010 & FUNC7_0000000;
assign    SLTU    =   OP_0110011 & FUNC3_011 & FUNC7_0000000;
assign    SLTI    =   OP_0010011 & FUNC3_010;
assign    SLTIU   =   OP_0010011 & FUNC3_011;

// assign  op_vec  = {op_LB, op_LH, op_LW, op_LBU, op_LHU, op_SB, op_SH, op_SW,
//                    op_BEQ, op_BNE, op_BLT, op_BGE, op_BLTU, op_BGEU, op_JAL, op_JALR,
//                    op_SLL, op_SRL, op_SRA, op_ADD, op_ADDI, op_SUB, op_LUI, op_AUIPC, op_AND, op_ANDI, op_OR, op_ORI, op_XOR, op_XORI, op_SLT, op_SLTU, op_SLTI, op_SLTIU};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        id_validout     <= 1'b0;
        decode_en       <= 1'b0;
    end else begin
        if (if_validout) begin
            id_pc           <= if_ram_pc;
            opcode          <= ram_dout[6:0];
            id_rd           <= ram_dout[11:7];
            id_func3        <= ram_dout[14:12];
            id_rs1          <= ram_dout[19:15];
            id_rs2          <= ram_dout[24:20];
            id_func7        <= ram_dout[31:25];
            decode_en       <= 1'b1;
            id_validout     <= 1'b1;
        end else begin
            decode_en       <= 1'b0;
            id_validout     <= 1'b0;
        end
    end
end

endmodule