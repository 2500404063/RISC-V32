/**
 * Author: Felix
 * Description: Pipe IE(Instruction Execute)  (the 3rd pipe)
 * Notes: This is the most complicated part of CPU.
          In this part we need to compute the valud that MEM and WB need.
          Designing this part, needs a good understanding of RISC-V Instrctions.
          My comprehension will be displayed below.
          1. Read Memory: e.g. LB(Load Byte), [offset, rs1, 000, rd, 0000011]
                          the memory address is x[rs1] + offset,  read memory at MEM peiord.
                          At WB peiord, write the Value at x[rd]
                          Now that, we need to compute the address(x[rs1] + offset) at IE and save it.
          2. Write Memory: e.g. SB(Store Byte), [offset, rs2, rs1, 000, offset, 0100011]
                           the memory address is x[rs1] + offset, the data is x[rs2] (The reg value)
          3. Alter Register: e.g. XOR, [7'd0, rs2, rs1, 100, 0110011]
                             x[rd] = x[rs1] xor x[rs2]
          By these three examples, we can know what information that instructions need.
          So we can compute the parameters better for MEM and WB periord.

          Unfortunately, at IE stage there is a problem needing to be solved.
          It is frequent to update registers so that we cannot wait for the WB.
          The solution is to save the last result. Luckyly, 5 pipes design only need to save once.
*/

module core_pipe_ie (
    input               clk,
    input               rst_n,
    output reg          ie_validout,
    input               mem_allowin,
    input               id_validout,
    //Value
    input[31:0]         id_pc,
    input[4:0]          id_rd,
    input[2:0]          id_func3,
    input[4:0]          id_rs1,
    input[4:0]          id_rs2,
    input[6:0]          id_func7,
    //Memory Instruction
    input               id_op_LB,
    input               id_op_LH,
    input               id_op_LW,
    input               id_op_LBU,
    input               id_op_LHU,
    input               id_op_SB,
    input               id_op_SH,
    input               id_op_SW,
    //Transfer Control
    input               id_op_BEQ,
    input               id_op_BNE,
    input               id_op_BLT,
    input               id_op_BGE,
    input               id_op_BLTU,
    input               id_op_BGEU,
    input               id_op_JAL,
    input               id_op_JALR,
    //Computational
    input               id_op_AND,
    input               id_op_ANDI,
    input               id_op_OR,
    input               id_op_ORI,
    input               id_op_XOR,
    input               id_op_XORI,

    input               id_op_ADD,
    input               id_op_ADDI,
    input               id_op_SUB,

    input               id_op_SLL,
    input               id_op_SLLI,
    input               id_op_SRL,
    input               id_op_SRLI,
    input               id_op_LUI,
    input               id_op_AUIPC,
    input               id_op_SLT,
    input               id_op_SLTU,
    input               id_op_SLTI,
    input               id_op_SLTIU,
    //Result Output
    //Memory Instruction
    output              result_mem_load,
    output              result_mem_store,
    output[1:0]         result_mem_size,
    output[31:0]        result_mem_addr,
    output[31:0]        result_mem_din,
    //Transfer Control
    output[31:0]        result_pc,
    output              result_jmp,
    output              result_link,
    output[31:0]        result_link_addr,
    //Computational
    output[31:0]        result_value,
    output              result_computed,
    //Reg arrary
    output reg[4:0]     ie_rd,
    output reg[4:0]     ie_rs1,
    output reg[4:0]     ie_rs2,
    input[31:0]         reg_rs1_dout_old,
    input[31:0]         reg_rs2_dout_old,
    //MEM Data conflict
    input[4:0]          mem_rd,
    input               mem_result_mem_load,
    input[31:0]         ram_dout,
    input               mem_result_computed,
    input[31:0]         mem_result_value
);

reg[31:0]    ie_pc;
reg[2:0]     ie_func3;
reg[6:0]     ie_func7;
reg          execute_en;

reg op_LB;
reg op_LH;
reg op_LW;
reg op_LBU;
reg op_LHU;
reg op_SB;
reg op_SH;
reg op_SW;

reg op_BEQ;
reg op_BNE;
reg op_BLT;
reg op_BGE;
reg op_BLTU;
reg op_BGEU;
reg op_JAL;
reg op_JALR;

reg op_AND;
reg op_ANDI;
reg op_OR;
reg op_ORI;
reg op_XOR;
reg op_XORI;

reg op_ADD;
reg op_ADDI;
reg op_SUB;

reg op_SLL;
reg op_SLLI;
reg op_SRL;
reg op_SRLI;
reg op_LUI;
reg op_AUIPC;
reg op_SLT;
reg op_SLTU;
reg op_SLTI;
reg op_SLTIU;

wire[31:0]    reg_rs1_dout;
wire[31:0]    reg_rs2_dout;

assign reg_rs1_dout = mem_result_mem_load && ie_rs1 == mem_rd ? ram_dout:
                      mem_result_computed && ie_rs1 == mem_rd ? mem_result_value : reg_rs1_dout_old;

assign reg_rs2_dout = mem_result_mem_load && ie_rs2 == mem_rd ? ram_dout:
                      mem_result_computed && ie_rs2 == mem_rd ? mem_result_value : reg_rs2_dout_old;
/*
Description: This is ALU, but combined in IE.
             Sacrifice Power Consumption, to reduce area.
*/

//Memory Instructions
assign result_mem_size = op_LB | op_LBU | op_SB ? 2'b00 :
                         op_LH | op_LHU | op_SH ? 2'b01 :
                         op_LW | op_SW          ? 2'b10 : 2'b10;
assign result_mem_load  = (op_LB | op_LH | op_LW | op_LBU | op_LHU) & execute_en;
assign result_mem_store = (op_SB | op_SH | op_SW) & execute_en;
assign result_mem_addr  = result_mem_store ? $signed(reg_rs1_dout) + $signed({ie_func7,ie_rd}) : 
                                             $signed(reg_rs1_dout) + $signed({ie_func7,ie_rs2});
assign result_mem_din   = reg_rs2_dout;

//Transfer Control
wire   rs1_eq_rs2               =   reg_rs1_dout == reg_rs2_dout;
wire   rs1_lt_rs2_signed        =   $signed(reg_rs1_dout) < $signed(reg_rs2_dout);
wire   rs1_ge_rs2_signed        =   $signed(reg_rs1_dout) >= $signed(reg_rs2_dout);
wire   rs1_lt_rs2_unsigned      =   reg_rs1_dout < reg_rs2_dout;
wire   rs1_ge_rs2_unsigned      =   reg_rs1_dout >= reg_rs2_dout;

assign result_jmp       =  ((op_BEQ & rs1_eq_rs2)             |
                            (op_BNE & ~rs1_eq_rs2)            |
                            (op_BLT & rs1_lt_rs2_signed)      |
                            (op_BGE & rs1_ge_rs2_signed)      |
                            (op_BLTU & rs1_lt_rs2_unsigned)   |
                            (op_BGEU & rs1_ge_rs2_unsigned)   |
                            (op_JAL | op_JALR)) & execute_en;

// wire[20:0]  test_pc = {ie_func7[6],ie_rs1,ie_func3,ie_rs2[0],ie_func7[5:0],ie_rs2[4:1],1'b0};
// wire[31:0]  test_pc_1 = $signed({ie_func7,ie_rs2,ie_rs1,ie_func3});
// wire[31:0]  test_pc_1 = $signed({ie_func7[6],ie_rs1,ie_func3,ie_rs2[0],ie_func7[5:0],ie_rs2[4:1],1'b0});
assign result_pc        =   op_JAL  ? $signed({ie_func7,ie_rs2,ie_rs1,ie_func3,1'b0}) + $signed(ie_pc) :
                            op_JALR ? $signed(reg_rs1_dout) + $signed({ie_func7,ie_rs2}) :
                            $signed(ie_pc) + $signed({ie_func7[6],ie_rd[0],ie_func7[5:0],ie_rd[4:1],1'b0});
assign result_link      =   (op_JAL | op_JALR) & execute_en;
assign result_link_addr =   ie_pc + 32'd4;

//Computational

assign result_value =   op_AND      ? reg_rs1_dout & reg_rs2_dout       : 
                        op_ANDI     ? reg_rs1_dout & {ie_func7, ie_rs2} :
                        op_OR       ? reg_rs1_dout | reg_rs2_dout       :
                        op_ORI      ? reg_rs1_dout | {ie_func7, ie_rs2} :
                        op_XOR      ? reg_rs1_dout ^ reg_rs2_dout       :
                        op_XORI     ? reg_rs1_dout ^ {ie_func7, ie_rs2} :

                        op_ADD      ? reg_rs1_dout + reg_rs2_dout       :
                        op_ADDI     ? reg_rs1_dout + {ie_func7, ie_rs2} :
                        op_SUB      ? reg_rs1_dout - reg_rs2_dout       :

                        op_SLL      ? reg_rs1_dout << reg_rs2_dout[4:0] :
                        op_SLLI     ? reg_rs1_dout << ie_rs2            :
                        op_SRL      ? reg_rs1_dout >> reg_rs2_dout[4:0] :
                        op_SRLI     ? reg_rs1_dout >> ie_rs2            :
                        op_LUI      ? $signed({ie_func7, ie_rs2,ie_rs1,ie_func3}) << 4'd12                  :
                        op_AUIPC    ? $signed({ie_func7, ie_rs2,ie_rs1,ie_func3}) << 4'd12 + ie_pc          :
                        op_SLT      ? rs1_lt_rs2_signed ? 32'd1 : 32'd0                                     :
                        op_SLTU     ? rs1_lt_rs2_unsigned ? 32'd1 : 32'd0                                   :
                        op_SLTI     ? $signed(reg_rs1_dout) < $signed({ie_func7, ie_rs2}) ? 32'd1 : 32'd0   :
                        op_SLTIU    ? reg_rs1_dout < {ie_func7, ie_rs2} ? 32'd1 : 32'd0                     : 32'd0;

assign result_computed =   (op_AND   |
                            op_ANDI  |
                            op_OR    |
                            op_ORI   |
                            op_XOR   |
                            op_XORI  |

                            op_ADD   |
                            op_ADDI  |
                            op_SUB   |

                            op_SLL   |
                            op_SLLI  |
                            op_SRL   |
                            op_SRLI  |
                            op_LUI   |
                            op_AUIPC |
                            op_SLT   |
                            op_SLTU  |
                            op_SLTI  |
                            op_SLTIU ) & execute_en;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ie_validout     <= 1'b0;
        execute_en      <= 1'b0;
    end else begin
        if (mem_allowin) begin
            if (id_validout) begin
                //1. ie_result_jmp == 0
                //2. ie_result_jmp == 1 and id_pc == ie_result_pc
                if (!result_jmp || (result_jmp && id_pc == result_pc)) begin
                    ie_validout <= 1'b1;
                    ie_pc       <= id_pc;
                    ie_rd       <= id_rd;
                    ie_func3    <= id_func3;
                    ie_rs1      <= id_rs1;
                    ie_rs2      <= id_rs2;
                    ie_func7    <= id_func7;

                    op_LB       <= id_op_LB;
                    op_LH       <= id_op_LH;
                    op_LW       <= id_op_LW;
                    op_LBU      <= id_op_LBU;
                    op_LHU      <= id_op_LHU;
                    op_SB       <= id_op_SB;
                    op_SH       <= id_op_SH;
                    op_SW       <= id_op_SW;

                    op_BEQ      <= id_op_BEQ;
                    op_BNE      <= id_op_BNE;
                    op_BLT      <= id_op_BLT;
                    op_BGE      <= id_op_BGE;
                    op_BLTU     <= id_op_BLTU;
                    op_BGEU     <= id_op_BGEU;
                    op_JAL      <= id_op_JAL;
                    op_JALR     <= id_op_JALR;

                    op_AND      <= id_op_AND;
                    op_ANDI     <= id_op_ANDI;
                    op_OR       <= id_op_OR;
                    op_ORI      <= id_op_ORI;
                    op_XOR      <= id_op_XOR;
                    op_XORI     <= id_op_XORI;

                    op_ADD      <= id_op_ADD;
                    op_ADDI     <= id_op_ADDI;
                    op_SUB      <= id_op_SUB;

                    op_SLL      <= id_op_SLL;
                    op_SLLI     <= id_op_SLLI;
                    op_SRL      <= id_op_SRL;
                    op_SRLI     <= id_op_SRLI;
                    op_LUI      <= id_op_LUI;
                    op_AUIPC    <= id_op_AUIPC;
                    op_SLT      <= id_op_SLT;
                    op_SLTU     <= id_op_SLTU;
                    op_SLTI     <= id_op_SLTI;
                    op_SLTIU    <= id_op_SLTIU;
                    execute_en  <= 1'b1;
                end else begin
                    ie_validout <= 1'b0;
                end
            end else begin
                execute_en  <= 1'b0;
                ie_validout <= 1'b0;
            end
        end
    end
end

endmodule