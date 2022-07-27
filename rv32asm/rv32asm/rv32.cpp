#include "rv32.h"
#include <sstream>
#include <iostream>

using namespace std;

Number combine_i(
	Number opcode,
	Number rd,
	Number func3,
	Number rs1,
	Number imm
) {
	if (rd > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-31" << endl;
	}
	if (rs1 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs1 is over the limit of 0-31" << endl;
	}
	if (imm > 4095)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "imm is over the limit of 0-FFFh" << endl;
	}
	Number code = 0;
	code += imm;
	code <<= 5;
	code += rs1;
	code <<= 3;
	code += func3;
	code <<= 5;
	code += rd;
	code <<= 7;
	code += opcode;
	return code;
}

Number combine_s(
	Number opcode,
	Number func3,
	Number rs1,
	Number rs2,
	Number imm
) {
	if (rs1 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs1 is over the limit of 0-31d" << endl;
	}
	if (rs2 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs2 is over the limit of 0-31d" << endl;
	}
	if (imm > 4095)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "imm is over the limit of 0-FFFh" << endl;
	}
	Number code = 0;
	code += (imm & 0xFE0) >> 5;
	code <<= 5;
	code += rs2;
	code <<= 5;
	code += rs1;
	code <<= 3;
	code += func3;
	code <<= 5;
	code += imm & 0x1F;
	code <<= 7;
	code += opcode;
	return code;
}

Number combine_r(
	Number opcode,
	Number rd,
	Number func3,
	Number rs1,
	Number rs2,
	Number func7
) {
	if (rd > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-31" << endl;
	}
	if (rs1 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs1 is over the limit of 0-31" << endl;
	}
	if (rs2 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs2 is over the limit of 0-31" << endl;
	}
	Number code = 0;
	code += func7;
	code <<= 5;
	code += rs2;
	code <<= 5;
	code += rs1;
	code <<= 3;
	code += func3;
	code <<= 5;
	code += rd;
	code <<= 7;
	code += opcode;
	return code;
}

Number combine_b(
	Number opcode,
	Number func3,
	Number rs1,
	Number rs2,
	Number imm
) {
	if (rs1 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs1 is over the limit of 0-31d" << endl;
	}
	if (rs2 > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rs2 is over the limit of 0-31d" << endl;
	}
	if (imm > 4095)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "imm is over the limit of 0-FFFFh" << endl;
	}
	Number code = 0;
	code += imm & 0x800;
	code <<= 6;
	code += imm & 0x3F0;
	code <<= 5;
	code += rs2;
	code <<= 5;
	code += rs1;
	code <<= 3;
	code += func3;
	code <<= 4;
	code += imm & 0xF;
	code <<= 1;
	code += imm & 0x400;
	code <<= 7;
	code += opcode;
	return code;
}

Number combine_u(
	Number opcode,
	Number rd,
	Number imm
) {
	if (rd > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-31d" << endl;
		return 0;
	}
	if (imm > 1048575)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-FFFFFh" << endl;
		return 0;
	}
	Number code = 0;
	code += imm;
	code <<= 5;
	code += rd;
	code <<= 7;
	code += opcode;
	return code;
}

Number combine_j(
	Number opcode,
	Number rd,
	Number imm
) {
	if (rd > 31)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-31d" << endl;
		return 0;
	}
	if (imm > 1048575)
	{
		cout << "Error: " << "at[" << cur_line << "]" << "rd is over the limit of 0-FFFFFh" << endl;
		return 0;
	}
	Number code = 0;
	code += imm;
	/*imm = imm & 0xFFFFF;
	code += imm & 0x80000;
	code <<= 10;
	code += imm & 0x3FF;
	code <<= 1;
	code += imm & 0x400;
	code <<= 8;
	code += imm & 0x7F800;*/
	code <<= 5;
	code += rd;
	code <<= 7;
	code += opcode;
	return code;
}

void fill_width(std::string& code_str, Number width) {
	code_str.insert(0, width - code_str.size(), '0');
}

void generate_inst(Number code, std::string& code_str) {
	stringstream ss;
	ss << hex << code;
	ss >> code_str;
	fill_width(code_str, INSTRUCTION_WIDTH);
}

void generate_LB(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0000011,
		params[0],
		FUNC3_000,
		params[1],
		params[2]);
	generate_inst(code, code_str);
}

void generate_LH(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0000011,
		params[0],
		FUNC3_001,
		params[1],
		params[2]);
	generate_inst(code, code_str);
}

void generate_LW(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0000011,
		params[0],
		FUNC3_010,
		params[1],
		params[2]);
	generate_inst(code, code_str);
}

void generate_LBU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0000011,
		params[0],
		FUNC3_100,
		params[1],
		params[2]);
	generate_inst(code, code_str);
}

void generate_LHU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0000011,
		params[0],
		FUNC3_101,
		params[1],
		params[2]);
	generate_inst(code, code_str);
}

void generate_SB(vector<Number>& params, std::string& code_str)
{
	Number code = combine_s(
		OPCODE_0100011,
		FUNC3_000,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SH(vector<Number>& params, std::string& code_str)
{
	Number code = combine_s(
		OPCODE_0100011,
		FUNC3_001,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SW(vector<Number>& params, std::string& code_str)
{
	Number code = combine_s(
		OPCODE_0100011,
		FUNC3_010,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BEQ(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_000,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BNE(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_001,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BLT(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_100,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BGE(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_101,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BLTU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_110,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_BGEU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_b(
		OPCODE_1100011,
		FUNC3_111,
		params[0],
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_JAL(vector<Number>& params, std::string& code_str)
{
	Number code = combine_j(
		OPCODE_1101111,
		params[0],
		params[1]
	);
	generate_inst(code, code_str);
}

void generate_JALR(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_1100111,
		params[0],
		FUNC3_010,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SLL(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_001,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_SLLI(vector<Number>& params, std::string& code_str)
{
	//In RV32 This is special
	Number code = combine_r(
		OPCODE_0010011,
		params[0],
		FUNC3_001,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_SRL(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_101,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_SRLI(vector<Number>& params, std::string& code_str)
{
	//In RV32 This is special
	Number code = combine_r(
		OPCODE_0010011,
		params[0],
		FUNC3_101,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_ADD(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_000,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_ADDI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_000,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SUB(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_000,
		params[1],
		params[2],
		FUNC7_0100000
	);
	generate_inst(code, code_str);
}

void generate_LUI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_u(
		OPCODE_0110111,
		params[0],
		params[1]
	);
	generate_inst(code, code_str);
}

void generate_AUIPC(vector<Number>& params, std::string& code_str)
{
	Number code = combine_u(
		OPCODE_0010111,
		params[0],
		params[1]
	);
	generate_inst(code, code_str);
}

void generate_AND(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_111,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_ANDI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_111,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_OR(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_110,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_ORI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_110,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_XOR(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_100,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_XORI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_100,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SLT(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_010,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_SLTU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_r(
		OPCODE_0110011,
		params[0],
		FUNC3_011,
		params[1],
		params[2],
		FUNC7_0000000
	);
	generate_inst(code, code_str);
}

void generate_SLTI(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_010,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}

void generate_SLTIU(vector<Number>& params, std::string& code_str)
{
	Number code = combine_i(
		OPCODE_0010011,
		params[0],
		FUNC3_011,
		params[1],
		params[2]
	);
	generate_inst(code, code_str);
}
