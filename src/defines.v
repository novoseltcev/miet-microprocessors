//base
`define RESET_ADDR 32'h00000000
`define ALU_OP_WIDTH 5
`define OPCODE_32_TYPE 2'b11

//alu operations
`define ALU_ADD  5'b0_0000
`define ALU_SUB  5'b0_1000

`define ALU_XOR  5'b0_0100
`define ALU_OR   5'b0_0110
`define ALU_AND  5'b0_0111

`define ALU_SRA  5'b0_1101
`define ALU_SRL  5'b0_0101
`define ALU_SLL  5'b0_0001

`define ALU_LTS  5'b1_1100
`define ALU_LTU  5'b1_1110

`define ALU_SLTS 5'b0_0010
`define ALU_SLTU 5'b0_0011

`define ALU_GES  5'b1_1101
`define ALU_GEU  5'b1_1111

`define ALU_EQ   5'b1_1000
`define ALU_NE   5'b1_1001


// opcodes
`define OPCODE_OPERATION_REG 5'b01_100 
`define OPCODE_OPERATION_IMM 5'b00_100

`define OPCODE_IMM_U_LOAD 5'b01_101 
`define OPCODE_IMM_U_PC   5'b00_101

`define OPCODE_STORE 5'b01_000
`define OPCODE_LOAD  5'b00_000 

`define OPCODE_BRANCH 5'b11_000

`define OPCODE_JUMP_LINK_REG 5'b11_001       
`define OPCODE_JUMP_LINK_IMM 5'b11_011 

`define OPCODE_MISC_MEM 5'b00_011 
`define OPCODE_SYSTEM   5'b11_100


//FUNC3
`define FUNC3_ADD_SUB  3'h0
`define FUNC3_XOR      3'h4
`define FUNC3_OR       3'h6
`define FUNC3_AND      3'h7
`define FUNC3_SLL      3'h1
`define FUNC3_SRL_SRA  3'h5
`define FUNC3_SLTS     3'h2
`define FUNC3_SLTU     3'h3

`define FUNC3_LB  3'h0
`define FUNC3_LH  3'h1
`define FUNC3_LW  3'h2
`define FUNC3_LBU 3'h4
`define FUNC3_LHU 3'h5

`define FUNC3_SB 3'h0
`define FUNC3_SH 3'h1
`define FUNC3_SW 3'h2

`define FUNC3_BEQ  3'h0
`define FUNC3_BNE  3'h1
`define FUNC3_BLT  3'h4
`define FUNC3_BGE  3'h5
`define FUNC3_BLTU 3'h6
`define FUNC3_BGEU 3'h7

`define FUNC3_JALR 3'h0


//FUNC7
`define FUNC7_ADD  7'h0
`define FUNC7_SUB  7'h20 
`define FUNC7_XOR  7'h0 
`define FUNC7_OR   7'h0
`define FUNC7_AND  7'h0
`define FUNC7_SLL  7'h0
`define FUNC7_SRL  7'h0
`define FUNC7_SRA  7'h20
`define FUNC7_SLTS 7'h0
`define FUNC7_SLTU 7'h0

//loaded data size
`define DATA_SIZE_BYTE        3'd0
`define DATA_SIZE_HALF_WORD   3'd1
`define DATA_SIZE_WORD        3'd2
`define DATA_SIZE_U_BYTE      3'd4
`define DATA_SIZE_U_HALF_WORD 3'd5


//type alu operand A
`define TYPE_A_RD1  2'd0
`define TYPE_A_PC   2'd1
`define TYPE_A_ZERO 2'd2


//type alu operand B
`define TYPE_B_RD2     3'd0
`define TYPE_B_IMM_I   3'd1
`define TYPE_B_IMM_U   3'd2
`define TYPE_B_IMM_S   3'd3
`define TYPE_B_PC_INCR 3'd4


//writeback from data memore or alu result
`define WRITEBACK_FROM_RESULT 1'd0
`define WRITEBACK_FROM_DATA   1'd1
