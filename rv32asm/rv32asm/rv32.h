#pragma once

#include <vector>
#include <string>

extern size_t	cur_line;


#define OPCODE_0000011  0x3
#define OPCODE_0100011  0x23
#define OPCODE_0110011  0x33
#define OPCODE_0010011  0x13
#define OPCODE_0010111  0x17
#define OPCODE_0110111  0x37
#define OPCODE_1100011  0x63
#define OPCODE_1100111  0x67
#define OPCODE_1101111  0x6F

#define FUNC3_000		0x0
#define FUNC3_001		0x1
#define FUNC3_010		0x2
#define FUNC3_011		0x3
#define FUNC3_100		0x4
#define FUNC3_101		0x5
#define FUNC3_110		0x6
#define FUNC3_111		0x7

#define FUNC7_0000000   0x0
#define FUNC7_0100000   0x20

#define	INSTRUCTION_WIDTH		8

typedef long            Number;

//Memory instruction
void generate_LB(std::vector<Number>& params, std::string& code_str);
void generate_LH(std::vector<Number>& params, std::string& code_str);
void generate_LW(std::vector<Number>& params, std::string& code_str);
void generate_LBU(std::vector<Number>& params, std::string& code_str);
void generate_LHU(std::vector<Number>& params, std::string& code_str);
void generate_SB(std::vector<Number>& params, std::string& code_str);
void generate_SH(std::vector<Number>& params, std::string& code_str);
void generate_SW(std::vector<Number>& params, std::string& code_str);

//Transfer control
void generate_BEQ(std::vector<Number>& params, std::string& code_str);
void generate_BNE(std::vector<Number>& params, std::string& code_str);
void generate_BLT(std::vector<Number>& params, std::string& code_str);
void generate_BGE(std::vector<Number>& params, std::string& code_str);
void generate_BLTU(std::vector<Number>& params, std::string& code_str);
void generate_BGEU(std::vector<Number>& params, std::string& code_str);
void generate_JAL(std::vector<Number>& params, std::string& code_str);
void generate_JALR(std::vector<Number>& params, std::string& code_str);

//Computational
void generate_SLL(std::vector<Number>& params, std::string& code_str);
void generate_SLLI(std::vector<Number>& params, std::string& code_str);
void generate_SRL(std::vector<Number>& params, std::string& code_str);
void generate_SRLI(std::vector<Number>& params, std::string& code_str);
void generate_ADD(std::vector<Number>& params, std::string& code_str);
void generate_ADDI(std::vector<Number>& params, std::string& code_str);
void generate_SUB(std::vector<Number>& params, std::string& code_str);
void generate_LUI(std::vector<Number>& params, std::string& code_str);
void generate_AUIPC(std::vector<Number>& params, std::string& code_str);
void generate_AND(std::vector<Number>& params, std::string& code_str);
void generate_ANDI(std::vector<Number>& params, std::string& code_str);
void generate_OR(std::vector<Number>& params, std::string& code_str);
void generate_ORI(std::vector<Number>& params, std::string& code_str);
void generate_XOR(std::vector<Number>& params, std::string& code_str);
void generate_XORI(std::vector<Number>& params, std::string& code_str);
void generate_SLT(std::vector<Number>& params, std::string& code_str);
void generate_SLTU(std::vector<Number>& params, std::string& code_str);
void generate_SLTI(std::vector<Number>& params, std::string& code_str);
void generate_SLTIU(std::vector<Number>& params, std::string& code_str);
