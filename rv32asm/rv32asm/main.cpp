#include <string>
#include <regex>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <stdio.h>
#include <algorithm>

#include "rv32.h"

using namespace std;

size_t	cur_line = 0;

inline Number decode_value(string&& val) {
	char flag = tolower(val.at(val.size() - 1));
	string num = val.substr(0, val.size() - 1);
	stringstream ss;
	Number dec_val = 0;
	switch (flag)
	{
	case 'h':
		ss << hex << num;
		ss >> dec_val;
		break;
	case 'd':
		ss << dec << num;
		ss >> dec_val;
		break;
	default:
		cout << "Error: " << "at[" << cur_line << "]" << "Wrong Value Format" << endl;
		break;
	}
	return dec_val;
}

inline void param_split(string&& str, vector<Number>& des, const char delim) {
	size_t start_pos = 0;
	size_t end_pos = 0;
	str.push_back(',');
	while ((end_pos = str.find_first_of(delim, start_pos)) != SIZE_MAX)
	{

		des.push_back(
			decode_value(
				str.substr(start_pos, end_pos - start_pos)
			)
		);
		start_pos = end_pos + 1;
	}
}

void dispatcher(string& line, ostream& out) {
	static regex reg_para("\\(.*?\\)", regex_constants::ECMAScript);
	static regex reg_space("\\s", regex_constants::ECMAScript);
	static regex reg_inst(".*?\\(", regex_constants::ECMAScript);

	//Preprocess
	line = regex_replace(line, reg_space, "");
	if (line[0] == '\0' || line[0] == '/')
	{
		return;
	}
	//Get Instruction
	smatch reg_result;
	string instruction;
	bool search_ok = regex_search(line, reg_result, reg_inst);
	if (search_ok) {
		instruction = reg_result[0].str();
		instruction.pop_back();
		transform(instruction.cbegin(), instruction.cend(), instruction.begin(), ::tolower);
	}
	else {
		cout << "Error: " << "at[" << cur_line << "]" << "Wrong Instruction Format" << endl;
	}

	//Get Parameters
	vector<Number>	params;
	search_ok = regex_search(line, reg_result, reg_para);
	if (search_ok) {
		string param_str = reg_result[0].str();
		param_split(param_str.substr(1, param_str.size() - 2), params, ',');
	}
	else {
		cout << "Error: " << "at[" << cur_line << "]" << "Wrong Parameter Format" << endl;
	}

	//Check Instructions
	string machine_code;
	if (instruction == "lb") generate_LB(params, machine_code);
	else if (instruction == "lh") generate_LH(params, machine_code);
	else if (instruction == "lw") generate_LW(params, machine_code);
	else if (instruction == "lbu") generate_LBU(params, machine_code);
	else if (instruction == "lhu") generate_LHU(params, machine_code);
	else if (instruction == "sb") generate_SB(params, machine_code);
	else if (instruction == "sh") generate_SH(params, machine_code);
	else if (instruction == "sw") generate_SW(params, machine_code);

	else if (instruction == "beq") generate_BEQ(params, machine_code);
	else if (instruction == "bne") generate_BNE(params, machine_code);
	else if (instruction == "blt") generate_BLT(params, machine_code);
	else if (instruction == "bge") generate_BGE(params, machine_code);
	else if (instruction == "bltu") generate_BLTU(params, machine_code);
	else if (instruction == "bgeu") generate_BGEU(params, machine_code);
	else if (instruction == "jal") generate_JAL(params, machine_code);
	else if (instruction == "jalr") generate_JALR(params, machine_code);
	else if (instruction == "and") generate_AND(params, machine_code);
	else if (instruction == "andi") generate_ANDI(params, machine_code);
	else if (instruction == "or") generate_OR(params, machine_code);
	else if (instruction == "ori") generate_ORI(params, machine_code);
	else if (instruction == "xor") generate_XOR(params, machine_code);
	else if (instruction == "xori") generate_XORI(params, machine_code);

	else if (instruction == "add") generate_ADD(params, machine_code);
	else if (instruction == "addi") generate_ADDI(params, machine_code);
	else if (instruction == "sub") generate_SUB(params, machine_code);

	else if (instruction == "sll") generate_SLL(params, machine_code);
	else if (instruction == "slli") generate_SLLI(params, machine_code);
	else if (instruction == "srl") generate_SRL(params, machine_code);
	else if (instruction == "srli") generate_SRLI(params, machine_code);
	else if (instruction == "lui") generate_LUI(params, machine_code);
	else if (instruction == "auipc") generate_AUIPC(params, machine_code);
	else if (instruction == "slt") generate_SLT(params, machine_code);
	else if (instruction == "sltu") generate_SLTU(params, machine_code);
	else if (instruction == "slti") generate_SLTI(params, machine_code);
	else if (instruction == "sltiu") generate_SLTIU(params, machine_code);
	else cout << "Unknown Instruction, " << "at[" << cur_line << "]" << endl;
	if (!machine_code.empty())
	{
		out << machine_code << endl;
	}
}

int main(int argc, char* argv[]) {
	string file_asm = argv[1];
	string file_bin = argv[2];
	ifstream file_in(file_asm, ios::in);
	ofstream file_out(file_bin, ios::out);
	if (!file_out.is_open())
	{
		cout << "File_Out Open Error" << endl;
	}
	if (file_in.is_open())
	{
		string	asm_buffer(1024, '\0');
		while (!file_in.eof()) {
			file_in.getline(&asm_buffer.at(0), 1024);
			cur_line++;
			dispatcher(asm_buffer, file_out);
		}
	}
	file_in.close();
	file_out.close();
	return 0;
}