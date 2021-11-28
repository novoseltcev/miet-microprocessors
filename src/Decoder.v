`include "defines.v"


module Decoder (
  input	[1: 0] opcode_type,
  input [4: 0] opcode,
  input [2: 0] func3,
  input [6: 0] func7,

  output reg [`ALU_OP_WIDTH - 1: 0] alu_operation,
  output reg [1: 0]                 operand_A_type,
  output reg [2: 0]                 operand_B_type,

  output reg		memory_require,
  output reg            memory_write_enable,
  output reg [2: 0]     memory_size,

  output reg		reg_file_write_enable,
  output reg            reg_file_write_data_type,

  output reg            branch_flag,
  output reg            jal_flag,
  output reg            jalr_flag,
  output reg            stop_signal,
  output reg            illegal_flag
)

  always @(*) begin
    alu_operation 	     <= `ALU_ADD
    operand_A_type           <= `TYPE_A_RD1;
    operand_B_type           <= `TYPE_B_RD2;       
    memory_require           <= 0;       
    memory_write_enable      <= 0;       
    memory_size              <= `DATA_SIZE_BYTE;       
    reg_file_write_enable    <= 0;       
    reg_file_write_data_type <= `WRITEBACK_FROM_RESULT;       
    branch_flag              <= 0;          
    jal_flag                 <= 0;       
    jalr_flag                <= 0;                        
    stop_signal              <= 0;       
    illegal_flag      <= 0;

    if (opcode_type != `OPCODE_32_TYPE) 
      illegal_flag <= 1;
    else begin      
      case(opcode)
	`OPCODE_OPERATION_REG: begin  //DONE
          reg_file_write_enable <= 1;  
	  casez({func3, func7})
	    {`FUNC3_ADD_SUB, `FUNC7_ADD}:  alu_operation <= `ALU_ADD;
	    {`FUNC3_ADD_SUB, `FUNC7_SUB}:  alu_operation <= `ALU_SUB; 
	    {`FUNC3_XOR,     `FUNC7_XOR}:  alu_operation <= `ALU_XOR;
	    {`FUNC3_OR,      `FUNC7_OR }:  alu_operation <= `ALU_OR;
	    {`FUNC3_AND,     `FUNC7_AND}:  alu_operation <= `ALU_AND;
	    {`FUNC3_SLL,     `FUNC7_SLL}:  alu_operation <= `ALU_SLL;
	    {`FUNC3_SRL_SRA, `FUNC7_SRL}:  alu_operation <= `ALU_SRL;
	    {`FUNC3_SRL_SRA, `FUNC7_SRA}:  alu_operation <= `ALU_SRA;
	    {`FUNC3_SLTS,    `FUNC7_SLTS}: alu_operation <= `ALU_SLTS;
	    {`FUNC3_SLTU,    `FUNC7_SLTU}: alu_operation <= `ALU_SLTU;
	    default: illegal_flag <= 1;
	  endcase
	end
	
	`OPCODE_OPERATION_IMM: begin  //DONE
	  reg_file_write_enable <= 1;
	  operand_B_type        <= `TYPE_B_IMM_I;
	  casez({func3, func7})  
            {`FUNC3_ADD_SUB, `FUNC7_ADD}:  alu_operation <= `ALU_ADD;  
            {`FUNC3_XOR,     `FUNC7_XOR}:  alu_operation <= `ALU_XOR;  
            {`FUNC3_OR,      `FUNC7_OR }:  alu_operation <= `ALU_OR;   
            {`FUNC3_AND,     `FUNC7_AND}:  alu_operation <= `ALU_AND;     
            {`FUNC3_SLL,     `FUNC7_SLL}:  alu_operation <= `ALU_SLL;     
            {`FUNC3_SRL_SRA, `FUNC7_SRL}:  alu_operation <= `ALU_SRL;      
            {`FUNC3_SRL_SRA, `FUNC7_SRA}:  alu_operation <= `ALU_SRA;      
            {`FUNC3_SLTS,    `FUNC7_SLTS}: alu_operation <= `ALU_SLTS;  
            {`FUNC3_SLTU,    `FUNC7_SLTU}: alu_operation <= `ALU_SLTU;  
            default: illegal_flag <= 1;  
          endcase            
  	end
	
	`OPCODE_IMM_U_LOAD: begin  //DONE
	  reg_file_write_enable <= 1;
	  operand_A_type        <= `TYPE_A_ZERO;
          operand_B_type        <= `TYPE_B_IMM_U;
  	end
	
	`OPCODE_IMM_U_PC: begin  //DONE
	  reg_file_write_enable <= 1;
	  operand_A_type        <= `TYPE_A_PC;
          operand_B_type        <= `TYPE_B_IMM_U;
	end
	
	`OPCODE_STORE: begin  //DONE
	  memory_require      <= 1;
	  memory_write_enable <= 1;
	  operand_B_type      <= `TYPE_B_IMM_S;
	  case(func3)
	    `FUNC3_SB: memory_size <= `DATA_SIZE_BYTE;
	    `FUNC3_SH: memory_size <= `DATA_SIZE_HALF_WORD;
	    `FUNC3_SW: memory_size <= `DATA_SIZE_WORD;
  	    default: illegal_flag <= 1;
	  endcase
	end
	
	`OPCODE_LOAD: begin  //DONE
	  reg_file_write_enable <= 1;
	  operand_B_type        <= `TYPE_B_IMM_I;
	  case(func3)
            `FUNC3_LB:  memory_size <= `DATA_SIZE_BYTE;
            `FUNC3_LH:  memory_size <= `DATA_SIZE_HALF_WORD;
            `FUNC3_LW:  memory_size <= `DATA_SIZE_WORD;
	    `FUNC3_LBU: memory_size <= `DATA_SIZE_U_BYTE;
            `FUNC3_LHU: memory_size <= `DATA_SIZE_U_HALF_WORD;
            default: illegal_flag <= 1;
          endcase
  	end
	
	`OPCODE_BRANCH: begin  //DONE
	  branch_flag <= 1;
	  case(func3)
	    `FUNC3_BEQ:  alu_operation <= `ALU_EQ;
	    `FUNC3_BNE:  alu_operation <= `ALU_NEQ;
	    `FUNC3_BLT:  alu_operation <= `ALU_LTS;
	    `FUNC3_BGE:  alu_operation <= `ALU_GES;
	    `FUNC3_BLTU: alu_operation <= `ALU_LTU;
    	    `FUNC3_BGEU: alu_operation <= `ALU_GEU;
	    default: illegal_flag <= 1;
	  endcase
  	end
	
	`OPCODE_JUMP_LINK_IMM:  //DONE
	  case(func3)
	    `FUNC3_JALR: begin
	      reg_file_write_enable <= 1;
              jal_flag              <= 1;
              operand_A_type        <= `TYPE_A_PC;
              operand_B_type        <= `TYPE_B_PC_INCR;
            end
	    default: illegal_flag <= 1;
          endcase
	
	`OPCODE_JUMP_LINK_REG: begin  //DONE
	  reg_file_write_enable <= 1;
	  jalr_flag		<= 1;
	  operand_A_type        <= `TYPE_A_PC;
          operand_B_type        <= `TYPE_B_PC_INCR;
  	end
	
	`OPCODE_MISC_MEM, `OPCODE_SYSTEM:
	  illegal_flag <= 0;

	default: 
  	  illegal_flag <= 1;

      endcase
    end
  end


