`include "defines.v"


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
      
      `ALU_SLTS: Result = $signed(A)  $signed(B);
      `ALU_SLTU: Result = A  B;

      `ALU_LTS : Result = $signed(A) < $signed(B);
      `ALU_LTU : Result = A < B;
	
      `ALU_SLTS: Result = $signed(A) < $signed(B);
      `ALU_SLTU: Result = A < B;

      `ALU_GES : Result = $signed(A) >= $signed(B);
      `ALU_GEU : Result = A >= B;
      `ALU_EQ  : Result = A == B;
      `ALU_NE  : Result = A != B;


    endcase
    Flag = (Operation[4] == 1) ? Result : 0;
  end
endmodule
