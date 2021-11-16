`define ALU_ADD 5'b0_0000
`define ALU_SUB 5'b0_1000

`define ALU_XOR 5'b0_0100
`define ALU_OR  5'b0_0110
`define ALU_AND 5'b0_0111

`define ALU_SRA 5'b0_1101
`define ALU_SRL 5'b0_0101
`define ALU_SLL 5'b0_0001

`define ALU_LTS 5'b1_1100
`define ALU_LTU 5'b1_1110

`define ALU_GES 5'b1_1101
`define ALU_GEU 5'b1_1111

`define ALU_EQ  5'b1_1000
`define ALU_NE  5'b1_1001


module ALU_RiscV (
  	input  [31:0]     operand_A, operand_B,
    input  [4: 0]     operation,
    output reg[31: 0] result,
    output reg        flag
);


always @(*) begin
    case(operation)
        `ALU_ADD : result = operand_A + operand_B;
        `ALU_SUB : result = operand_A - operand_B;
        
        `ALU_XOR : result = operand_A ^ operand_B;
        `ALU_OR  : result = operand_A | operand_B;
        `ALU_AND : result = operand_A & operand_B;
        
        `ALU_SRA : result = $signed(operand_A) >>> $signed(operand_B);
        `ALU_SRL : result = operand_A >> operand_B;
        `ALU_SLL : result = operand_A << operand_B;
        
        `ALU_LTS : result = $signed(operand_A) < $signed(operand_B);
        `ALU_LTU : result = operand_A < operand_B;
        `ALU_GES : result = $signed(operand_A) >= $signed(operand_B);
        `ALU_GEU : result = operand_A >= operand_B;
        `ALU_EQ  : result = operand_A == operand_B;
        `ALU_NE  : result = operand_A != operand_B;
    endcase
    flag = (operation[4] == 1'b1) ? result : 0;
end

endmodule
