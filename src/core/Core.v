`include "defines.v"
`include "ALU.v"
`include "RegFile.v"
`include "Decoder.v"
`include "LSU.v"

module Core (
  input  clk,
  input  areset,

  // instr interface
  input logic [31: 0] instr,
  output      [31: 0] instr_address,

  // data interface
  input logic [31: 0] external_data,
  output      [31: 0] internal_data,
  output      [31: 0] external_address,
  output      [3:  0] memory_load_byte_map,
  output       memory_require, memory_write_enable
);
  
    
  reg [31: 0] pc;
  assign instr_address = pc;
  
  // DECODE
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
  wire interrupted_signal, illegal_signal;
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
    .stop_signal(interrupted_signal),
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
  
  ALU ALU_connection(
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
    //instr_address <= pc;
  end

  wire en_pc;
  always @(posedge clk) begin
    if (areset) begin
      pc <= `RESET_ADDR;
    end else 
      if (!en_pc)
        pc <= pre_pc;
      else
        $display("interrupted");
    //instr_address <= pc;
    //;
  end
  // END FETCH INSTRUCTRION
  
  // MEMORY
  LSU LSU_connection(
    .clk(clk),
    .areset(areset),
    
    .core_address(alu_result),
    .core_write_data(rd2),
    .core_require(memory_require_signal),
    .core_write_enable(memory_write_enable_signal),
    .core_size(memory_size_signal),

    .core_read_data(readed_data),
    .core_stall_signal(en_pc),
    
    .memory_read_data(external_data),
    
    .memory_begin_signal(data_gnt_i),
    .memory_end_signal(data_rvalid_i),
    .memory_require(memory_require),
    .memory_write_enable(memory_write_enable),
    .memory_byte_enable_map(memory_load_byte_map),
    .memory_address(external_address),
    .memory_write_data(internal_data)
  );
  // END MEMORY
  

  // WRITEBACK
  always @(*)
    wd3 <= ((reg_file_write_data_type_signal) ? readed_data : alu_result);
  // END WRITEBACK
endmodule

