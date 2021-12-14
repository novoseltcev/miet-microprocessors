`include "defines.v"
`include "ALU_RiscV.v"
`include "RegFile.v"
`include "InstrMemory.v"
`include "DataMemory.v"
`include "Decoder.v"

module CoreRiscV (
  input  clk,
  input reset,

  input [31: 0] instr,
  output reg [31: 0] pc
);
  
  // DECODE
  assign pc = 32'b0; 
  
  wire [1: 0] opcode_type;
  wire [4: 0] opcode;
  wire [2: 0] func3;
  wire [4: 0] rs1, rs2, rd3;
  wire [6: 0] func7;

  assign {func7, rs2, rs1, func3, rd3, opcode, opcode_type} = instr; 
  
  wire [31: 0] imm_I = {{20{instr[31]}}, instr[31: 20]};
  wire [31: 0] imm_S = {{20{instr[31]}}, instr[31: 25], instr[11: 7]};
  wire [31: 0] imm_U = {  instr[31: 12], 12'b0};
  wire [31: 0] imm_B = {{20{instr[31]}}, instr[7], instr[30: 25], instr[11: 8], 1'b0};
  wire [31: 0] imm_J = {{12{instr[31]}}, instr[19: 12], instr[20], instr[30: 21], 1'b0};
  // END DECODE
  
  
  // GENERATE CONTROL SIGNALS
  wire memory_require_signal, memory_write_enable_signal;
  wire reg_file_write_enable_signal, reg_file_write_data_type_signal;
  wire branch_signal, jal_signal, jalr_signal; 
  wire inverse_update_pc_signal, illegal_signal;
  wire [1: 0] operand_A_type_signal;
  wire [2: 0] operand_B_type_signal, memory_size_signal;
  wire [`ALU_OP_WIDTH - 1: 0] alu_operation_signal;
  
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

    .reg_file_write_enable(reg_file_write_enable_signal),
    .reg_file_write_data_type(reg_file_write_data_type_signal),

    .branch_flag(branch_signal),
    .jal_flag(jal_signal),
    .jalr_flag(jalr_signal),
    .stop_signal(inverse_update_pc_signal),
    .illegal_flag(illegal_signal)
  );
  // END GENERATE CONTROL SIGNALS

  
  // EXECUTE
  wire [31: 0] rd1, rd2; 
  reg  [31: 0] wd3, operand_A, operand_B;
  wire [31: 0] alu_result, readed_data;
  wire comparator;
 
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
  
  ALU_RiscV ALU_connection(
    .A(operand_A),
    .B(operand_B),
    .operation(alu_operation_signal),
    
    .result(alu_result),
    .flag(comparator)
  );
  // END EXECUTE 
  
  
  // FETCH INSTRUCTRION
  reg [31: 0] pc_increment, pre_pc;
  always @(*) begin
    casez({jal_signal | branch_signal & comparator, branch_signal})
      {1'b0, 1'b?}: pc_increment <= 3'd4;
      {1'b1, 1'b0}: pc_increment <= imm_J;
      {1'b1, 1'b1}: pc_increment <= imm_B;
    endcase
    pre_pc <= ( (jalr_signal) ? rd1 + imm_I : pc + pc_increment  );
  end

  always @(posedge clk)
    if (!inverse_update_pc_signal)
      pc <= pre_pc;
  // END FETCH INSTRUCTRION
  

  // MEMORY
  DataMemory DM_connection(
    .clk(clk),

    .address(alu_result),
    .write_data(rd2),
    .write_enable(memory_write_enable_signal),
    .access(memory_require_signal),
    .size(memory_size_signal),

    .read_data(readed_data)
  );
  // END MEMORY
  

  // WRITEBACK
  always @(*)
    wd3 <= ((reg_file_write_data_type_signal) ? readed_data : alu_result);
  // END WRITEBACK
endmodule
