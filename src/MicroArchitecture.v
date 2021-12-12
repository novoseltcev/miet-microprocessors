`include "defines.v";
`include "ALU_RiscV.v";
`include "RegFile.v";
`include "InstrMemory.v";
`include "DataMemory.v";
`include "Decoder.v";


module MicroArchitecture (
  input  clk, reset,
);
  wire [31:0] instr;

  wire [1: 0] opcode_type
  wire [4: 0] opcode;
  wire [2: 0] func3;
  wire [4: 0] rs1, rs2, rd3;
  wire [6: 0] func7;

  wire [11: 0] imm_I, imm_S, imm_B;
  wire [20: 0] imm_J;
  wire [19: 0] imm_U;

  assign {func7, rs2, rs1, func3, rd3, opcode, opcode_type} = instr; 
  assign imm_I = {{20{instr[31]}}, instr[31: 20]};
  assign imm_U = {  instr[31: 12], {12{0}}};
  assign imm_S = {{20{instr[31]}}, instr[31: 25], instr[11: 7]};
  assign imm_B = {{20{instr[31]}}, instr[7], instr[30: 25], instr[11: 8], 0};
  assign imm_J = {{12{instr[31]}}, instr[19: 12], instr[20], instr[30: 21], 0};

 
  wire memory_require_signal, memory_write_enable_signal;
  wire reg_file_write_enable_signal, reg_file_write_data_type_signal;
  wire branch_signal, jal_signal, jalr_signal, update_pc_signal;
  wire [2: 0] operand_A_type_signal, memeory_size_signal;
  wire [1: 0] operand_B_type_signal;
  wire [`ALU_OP_WIDTH - 1: 0] alu_operation_signal;

  reg  [31:0] wd3, operand_A, operand_B;
  wire [31:0] rd1, rd2, alu_result, readed_data;
  wire comparator; 


  reg [31: 0] pc = 32'b0; 
  reg [31: 0] pc_increment;

  always @(*) begin
    casez({jal_signal | branch & comparator, branch})
      {0, 1'b?}: pc_increment <= 3'd4;
      {1, 0}:    pc_increment <= imm_J;
      {1, 0}:    pc_increment <= imm_B;
    endcase
    pre_pc <= ( (jalr_signal) ? rd1 : pc + pc_increment  );
  end

  always @(posedge clk)
    if (update_pc_signal)
      pc <= pre_pc;

  InstrMemory IM_connection(
    .address(pc),
    .read_data(instr);
  );
	

  RegFile RF_connection(
    .clk(clk),

    .address_1(rs1),
    .read_data_1(rd1),

    .address_2(rs2),
    .read_data_2(rd2),

    .address_3(rd3),
    .write_data_3(wd3),
    .write_enable_3(reg_file_write_enable_signal)
  );


  always @(*) begin
    case(operand_A_type_signal)
      `TYPE_A_RD1:  operand_A <= rd1;
      `TYPE_A_PC:   operand_A <= pc;
      `TYPE_A_ZERO: operand_A <= 0;
    endcase
    case(operand_B_type_signal)
      `TYPE_B_RD2:     operand_B <= rd2;
      `TYPE_B_IMM_I:   operand_B <= imm_I;
      `TYPE_B_IMM_U:   operand_B <= imm_U;
      `TYPE_B_IMM_S:   operand_B <= imm_S;
      `TYPE_B_PC_INCR: operand_B <= 4;
    endcase
  end


  ALU_riscV ALU_connection(
    .A(operand_A),
    .B(operand_B),
    .operation(alu_operation_signal),
    
    .result(alu_result),
    .flag(comparator)
  );
  
  
  DataMemory DM_connection(
    .clk(clk),

    .address(alu_result),
    .write_data(rd2),
    .write_enable(memory_write_enable_signal),
    .access(memory_require),
    .size(memory_size_signal),

    .read_data(readed_data)
  );

  always @(*)
    wd3 <= ((reg_file_write_data_type_signal) ? readed_data : alu_result);
  
  
  Decoder Decoder_connection(
    .opcode_type(opcode_type),
    .opcode(opcode),
    .func3(func3),
    .func7(func7),
    
    .alu_operation(alu_operation_signal),
    .operand_A_type(operand_A_type_signal),
    .operand_B_type(operand_B_type_signal),

    .memory_require(memory_require_signal),
    .memory_write_enable(memory_write_enable_signal),
    .memory_size(memory_size_signal),

    .reg_file_write_enable(reg_file_write_enabler_signal),
    .reg_file_write_data_type(reg_file_write_data_type_signal),

    .branch_flag(branch_signal),
    .jal_flag(jal_signal),
    .jalr_flag(jalr_signal),
    .stop_signal(not(update_pc_signal))
  );
  
endmodule
