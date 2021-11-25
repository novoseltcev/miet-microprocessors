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
  input  [31:0]     A, B,
  input  [4: 0]     Operation,
  output reg[31: 0] Result,
  output reg        Flag
);
  always @(*) begin
    case(Operation)
      `ALU_ADD : Result = A + B;
      `ALU_SUB : Result = A - B;
        
      `ALU_XOR : Result = A ^ B;
      `ALU_OR  : Result = A | B;
      `ALU_AND : Result = A & B;
        
      `ALU_SRA : Result = $signed(A) >>> $signed(B);
      `ALU_SRL : Result = A >> B;
      `ALU_SLL : Result = A << B;
        
      `ALU_LTS : Result = $signed(A) < $signed(B);
      `ALU_LTU : Result = A < B;
      `ALU_GES : Result = $signed(A) >= $signed(B);
      `ALU_GEU : Result = A >= B;
      `ALU_EQ  : Result = A == B;
      `ALU_NE  : Result = A != B;
    endcase
    Flag = (Operation[4] == 1) ? Result : 0;
  end
endmodule
