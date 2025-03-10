#include <cctype>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

void ConvertToOpcode(string line);
string CovertOperandToRegister(string operand);
string CovertHexaToBinary(string hexa);
string ConvertOneHexa(string hexa);
string trimExceptFirst(string str);
int HexaToDecimal(string hexa);
int counter = 0;
int countermem = 0;
int flag = 0;
int flagmem = 0;
string output[4096];
string memory[4];

int main() {  // Array of strings to store lines

    for (int i = 0; i < 4096; i++) {
        output[i] = "0000000000000000";
    }
    for (int i = 0; i < 4; i++) {
        memory[i] = "0000000000000000";
    }

    ifstream inputFile("input.txt");          // Replace "input.txt" with the path to your input file
    ofstream outputFile("instructions.mem");  // Open the output file in append mode
    if (outputFile.is_open()) {
        outputFile.clear();  // Clear the contents of the output file

    } else {
        cout << "Failed to open the output file." << endl;
    }

    ofstream memFile("memory.mem");  // Open the output file in append mode
    if (memFile.is_open()) {
        memFile.clear();  // Clear the contents of the output file

    } else {
        cout << "Failed to open the memory file." << endl;
    }

    if (inputFile.is_open()) {
        string line;
        while (getline(inputFile, line)) {
            for (char& c : line) {
                c = toupper(c);
            }
            line = trimExceptFirst(line);
            ConvertToOpcode(line);
        }
        inputFile.close();
    } else {
        cout << "Failed to open the file." << endl;
        return 1;
    }

    if (outputFile.is_open()) {
        if (flag == 0) {
            outputFile << "// memory data file (do not edit the following line - required for mem load use)\n// "
                          "instance=/procuss/fetcher/Instruction_Memory_inst/ram\n// format=mti addressradix=d "
                          "dataradix=b version=1.0 wordsperline=1"
                       << endl;
            flag = 1;
        }
        for (int i = 0; i < 4096; i++) {
            outputFile << setw(4) << i << ": " << output[i] << endl;
        }

        outputFile.close();
    } else {
        cout << "Failed to open the output file." << endl;
    }

    if (memFile.is_open()) {
        if (flagmem == 0) {
            memFile << "// memory data file (do not edit the following line - required for mem load use)\n"
                       "// instance=/procuss/memory_man/umem/ram\n"
                       "// format=mti addressradix=d dataradix=s version=1.0 wordsperline=1"
                    << endl;
            flagmem = 1;
        }
        for (int i = 0; i < 4; i++) {
            memFile << setw(4) << i << ": " << memory[i] << endl;
        }
        for (int i = 4; i < 4096; i++) {
            memFile << setw(4) << i << ": " << "0000000000000000" << endl;
        }

        memFile.close();
    } else {
        cout << "Failed to open the memory file." << endl;
    }

    return 0;
}

void ConvertToOpcode(string line) {
    string Inst1 = "";
    vector<string> operands, Insts, Mem;
    string delimiter = " ,(#";
    size_t pos = 0;
    string token;

    while ((pos = line.find_first_of(delimiter)) != string::npos) {
        token = line.substr(0, pos);
        operands.push_back(token);
        line.erase(0, pos + 1);
    }
    operands.push_back(line);
    if (operands[0][0] == '#') {
        return;
    }
    if (operands[0] == ".ORG") {
        if (HexaToDecimal(operands[1].c_str()) < 3) {
            counter = HexaToDecimal(operands[1].c_str());
            countermem = HexaToDecimal(operands[1].c_str());
        } else {
            counter = HexaToDecimal(operands[1].c_str());
        }
    } else if (operands[0] == "ADD") {
        Inst1 += "100000";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "SUB") {
        Inst1 += "100001";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "AND") {
        Inst1 += "100010";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "OR") {
        Inst1 += "100011";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "XOR") {
        Inst1 += "100100";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "MOV") {
        Inst1 += "100101";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += "000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
    } else if (operands[0] == "SWAP") {
        Inst1 += "101001";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "CMP") {
        Inst1 += "101010";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "NOP") {
        Inst1 += "0000000000000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "NOT") {
        Inst1 += "000001";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "NEG") {
        Inst1 += "000010";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
        Insts.push_back(Inst1);
    } else if (operands[0] == "INC") {
        Inst1 += "000011";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "DEC") {
        Inst1 += "000100";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "IN") {
        Inst1 += "000101";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "OUT") {
        Inst1 += "000110";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "POP") {
        Inst1 += "000111";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "PUSH") {
        Inst1 += "001000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "PROTECT") {
        Inst1 += "001001";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "FREE") {
        Inst1 += "001010";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "JZ") {
        Inst1 += "110000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "JMP") {
        Inst1 += "110001";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "CALL") {
        Inst1 += "110010";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "RET") {
        Inst1 += "1100110000000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "RTI") {
        Inst1 += "1101000000000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "RESET") {
        Inst1 += "1101010000000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "INTERRUPT") {
        Inst1 += "1101100000000000";
        Insts.push_back(Inst1);
    } else if (operands[0] == "ADDI") {
        Inst1 += "010000";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += "000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
        Insts.push_back(CovertHexaToBinary(operands[3]));
    } else if (operands[0] == "SUBI") {
        Inst1 += "010001";
        Inst1 += CovertOperandToRegister(operands[2]);
        Inst1 += "000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
        Insts.push_back(CovertHexaToBinary(operands[3]));
    } else if (operands[0] == "LDM") {
        Inst1 += "010100000000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
        Insts.push_back(CovertHexaToBinary(operands[2]));
    } else if (operands[0] == "LDD") {
        Inst1 += "010010";
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += "000";
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0";
        Insts.push_back(Inst1);
        Insts.push_back(CovertHexaToBinary(operands[2]));
    } else if (operands[0] == "STD") {
        Inst1 += "010011";
        Inst1 += CovertOperandToRegister(operands[3]);
        Inst1 += CovertOperandToRegister(operands[1]);
        Inst1 += "0000";
        Insts.push_back(Inst1);
        Insts.push_back(CovertHexaToBinary(operands[2]));
    } else if (isdigit(operands[0][0]) || operands[0][0] == 'A' || operands[0][0] == 'B' || operands[0][0] == 'C' ||
               operands[0][0] == 'D' || operands[0][0] == 'E' || operands[0][0] == 'F') {
        Insts.push_back(CovertHexaToBinary(operands[0]));
        // Mem.push_back(CovertHexaToBinary(operands[0]));
        memory[countermem] = CovertHexaToBinary(operands[0]);
        countermem++;
    }
    for (int i = 0; i < Insts.size(); i++) {
        output[counter] = Insts[i];
        counter++;
    }
    return;
}

string CovertOperandToRegister(string operand) {
    if (operand[1] == '0') {
        return "000";
    } else if (operand[1] == '1') {
        return "001";
    } else if (operand[1] == '2') {
        return "010";
    } else if (operand[1] == '3') {
        return "011";
    } else if (operand[1] == '4') {
        return "100";
    } else if (operand[1] == '5') {
        return "101";
    } else if (operand[1] == '6') {
        return "110";
    } else if (operand[1] == '7') {
        return "111";
    } else {
        return "000";
    }
}
string CovertHexaToBinary(string hexa) {
    while (hexa.length() < 4) {
        hexa = "0" + hexa;
    }
    string binary = "";
    for (int i = 0; i < 4; i++) {
        binary += ConvertOneHexa(hexa.substr(i, 1));
    }
    return binary;
}
string ConvertOneHexa(string hexa) {
    if (hexa == "0") {
        return "0000";
    } else if (hexa == "1") {
        return "0001";
    } else if (hexa == "2") {
        return "0010";
    } else if (hexa == "3") {
        return "0011";
    } else if (hexa == "4") {
        return "0100";
    } else if (hexa == "5") {
        return "0101";
    } else if (hexa == "6") {
        return "0110";
    } else if (hexa == "7") {
        return "0111";
    } else if (hexa == "8") {
        return "1000";
    } else if (hexa == "9") {
        return "1001";
    } else if (hexa == "A") {
        return "1010";
    } else if (hexa == "B") {
        return "1011";
    } else if (hexa == "C") {
        return "1100";
    } else if (hexa == "D") {
        return "1101";
    } else if (hexa == "E") {
        return "1110";
    } else if (hexa == "F") {
        return "1111";
    } else {
        return "0000";
    }
}
#include <algorithm>

string trimExceptFirst(string str) {
    std::string::size_type firstSpace = str.find(' ');
    if (firstSpace != std::string::npos) {
        str.erase(std::remove_if(str.begin() + firstSpace + 1, str.end(), [](char c) { return c == ' '; }), str.end());
    }
    return str;
}

int HexaToDecimal(string hexa) {
    int decimal = 0;
    int base = 1;
    while (hexa.length() < 4) {
        hexa = "0" + hexa;
    }
    for (int i = hexa.length() - 1; i >= 0; i--) {
        if (hexa[i] >= '0' && hexa[i] <= '9') {
            decimal += (hexa[i] - 48) * base;
            base = base * 16;
        } else if (hexa[i] >= 'A' && hexa[i] <= 'F') {
            decimal += (hexa[i] - 55) * base;
            base = base * 16;
        }
    }
    return decimal;
}