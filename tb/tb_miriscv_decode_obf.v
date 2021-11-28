`timescale 1ns / 1ps
`include "defines.v"


module tb_miriscv_decode_obf();
  parameter delay = 4;
  parameter testsPerOpcode = 100; // per one opcode

  reg   [31:0]               instruction;
  wire  [1:0]                typeA;
  wire  [2:0]                typeB;
  wire  [`ALU_OP_WIDTH-1:0]  operation;
  wire                       memoryRequired;
  wire                       memoryWriteEnable;
  wire  [2:0]                memorySize;
  wire                       regFileWriteEnable;
  wire                       regFileDataType;
  wire                       illegalFlag;
  wire                       branchFlag;
  wire                       jalFlag;
  wire                       jalrFlag;
  reg  [1:0]                 copyTypeA;
  reg  [2:0]                 copyTypeB;
  reg  [`ALU_OP_WIDTH-1:0]   copyOperation;
  reg                        copyMemoryRequired;
  reg                        copyMemoryWriteEnable;
  reg  [2:0]                 copyMemorySize;
  reg                        copyRFWE;
  reg                        copyRFDataType;
  reg                        copyIllegalFlag;
  reg                        copyBranchFlag;
  reg                        copyJalFlag;
  reg                        copyJalrFlag;

  Decoder decoder( 
    .opcode_type         (instruction[1: 0]),
    .opcode              (instruction[6: 2]),
    .func3               (instruction[14: 12]),
    .func7               (instruction[31: 25]),

    .operand_A_type           (typeA),
    .operand_B_type           (typeB),
    .alu_operation            (operation),
    .memory_require           (memoryRequired),
    .memory_write_enable      (memoryWriteEnable),
    .memory_size              (memorySize),
    .reg_file_write_enable    (regFileWriteEnable),
    .reg_file_write_data_type (regFileDataType),
    .illegal_flag  (illegalFlag),
    .branch_flag         (branchFlag),
    .jal_flag            (jalFlag),
    .jalr_flag           (jalrFlag)
  );

  wire [1:0] opcodeType;
  wire [2:0] func3Value;
  wire [4:0] opcodeValue;
  wire [6:0] func7Value;
  assign opcodeType = instruction[1: 0];
  assign func3Value = instruction[14: 12];
  assign opcodeValue = instruction[6: 2];
  assign func7Value = instruction[31: 25];

  always @(*) begin
    copyBranchFlag = (&opcodeValue[4:3]) & (~|opcodeValue[2:0]);
    copyJalFlag = (&opcodeValue[4:3]) & (&(opcodeValue+4'h4));
    copyJalrFlag = (&opcodeValue[4:3]) & (&{~opcodeValue[2:1], opcodeValue[0]});
    copyRFWE = (~opcodeValue[3] & ~opcodeValue[1]) |
                   (~opcodeValue[4] &  opcodeValue[2]) |
                   ( opcodeValue[4] &  opcodeValue[0]);
    case (1'b1)
      (~|opcodeValue):
        copyMemoryWriteEnable = opcodeValue[4];
      (opcodeValue[3] & ~|{opcodeValue[4], opcodeValue[2:0]}):
        copyMemoryWriteEnable = opcodeType[0];
      default:
        copyMemoryWriteEnable = memoryWriteEnable;
    endcase

    copyMemoryRequired = ~|{opcodeValue[4], opcodeValue[2:0]};
    case (1'b1)
      ~|opcodeValue:
        copyRFDataType = 1'b1;
      ~opcodeValue[4] & opcodeValue[2] & ~opcodeValue[1],
      opcodeValue[4] & opcodeValue[3] & ~opcodeValue[2] & opcodeValue[0]:
        copyRFDataType = 1'b0;
      default: copyRFDataType = regFileDataType;
    endcase

    case (1'b1)
      (~|opcodeValue[1:0]) & (~&opcodeValue[4:2]):
        copyTypeA = opcodeValue[2] ? opcodeValue[1:0] : opcodeValue[2:1];
      &{opcodeValue[4:3], opcodeValue[0], ~opcodeValue[2]}:
        copyTypeA = opcodeValue[1] ? opcodeValue[2:1] : opcodeValue[1:0];
      ~|{opcodeValue[4], opcodeValue[1], ~opcodeValue[2], ~opcodeValue[0]}:
        copyTypeA = opcodeValue[3] ? opcodeValue[2:1] : opcodeValue[1:0];
      default:
        copyTypeA = typeA;
    endcase

    case (1'b1)
      (opcodeValue[4]^opcodeValue[2]) & (~|opcodeValue[1:0]) & opcodeValue[3]:
        copyTypeB = opcodeValue[2] ? ~{opcodeValue[3], opcodeValue[3:2]}: opcodeValue[2:0];
      ~|{opcodeValue[4:3], opcodeValue[1:0]}:
        copyTypeB = opcodeValue[4:2] + (~^opcodeValue);
      ~|{opcodeValue[4], opcodeValue[1], ~opcodeValue[2], ~opcodeValue[0]}:
        copyTypeB = ~opcodeValue[2:0];
      ~|{opcodeValue[2:0], opcodeValue[4]} & opcodeValue[3]:
        copyTypeB = {opcodeValue[1], opcodeType};
      &{opcodeValue[4:3], ~opcodeValue[2], opcodeValue[0]}:
        copyTypeB = opcodeValue[3:1] - opcodeValue[1];
      default:
        copyTypeB = typeB;
    endcase

    copyIllegalFlag = ~&opcodeType;
    case (1'b1)
      ~|{opcodeValue[2:0], opcodeValue[4]}: begin
        if (~copyIllegalFlag)
          copyIllegalFlag = opcodeValue[3] ? (func3Value[2] | (&func3Value[1:0])) :
                                   (&func3Value[1:0] | &func3Value[2:1]);
        copyMemorySize = func3Value;
      end
      default:
        copyMemorySize = memorySize;
    endcase

    casez (opcodeValue)
      5'b0?000,
      5'b110?1,
      5'b00101: begin
        copyOperation = `ALU_ADD;
        if (opcodeValue[4] & ~opcodeValue[1] & |func3Value)
          copyIllegalFlag = 1'b1;
      end

      `OPCODE_OPERATION_IMM: begin
        casez ({func7Value, func3Value})
          {7'h??, 3'h0}: copyOperation = `ALU_ADD;
          {7'h00, 3'h1}: copyOperation = `ALU_SLL;
          {7'h??, 3'h2}: copyOperation = `ALU_SLTS;
          {7'h??, 3'h3}: copyOperation = `ALU_SLTU;
          {7'h??, 3'h4}: copyOperation = `ALU_XOR;
          {7'h00, 3'h5}: copyOperation = `ALU_SRL;
          {7'h20, 3'h5}: copyOperation = `ALU_SRA;
          {7'h??, 3'h6}: copyOperation = `ALU_OR;
          {7'h??, 3'h7}: copyOperation = `ALU_AND;
          default: copyIllegalFlag = 1'b1;
        endcase
      end

      `OPCODE_OPERATION_REG: begin
        case ({func7Value, func3Value})
          {7'h00, 3'h0}: copyOperation = `ALU_ADD;
          {7'h20, 3'h0}: copyOperation = `ALU_SUB;
          {7'h00, 3'h1}: copyOperation = `ALU_SLL;
          {7'h00, 3'h2}: copyOperation = `ALU_SLTS;
          {7'h00, 3'h3}: copyOperation = `ALU_SLTU;
          {7'h00, 3'h4}: copyOperation = `ALU_XOR;
          {7'h00, 3'h5}: copyOperation = `ALU_SRL;
          {7'h20, 3'h5}: copyOperation = `ALU_SRA;
          {7'h00, 3'h6}: copyOperation = `ALU_OR;
          {7'h00, 3'h7}: copyOperation = `ALU_AND;
          default: copyIllegalFlag = 1'b1;
        endcase
        if (~copyIllegalFlag) begin
        end
      end

      `OPCODE_IMM_U_LOAD: begin
        if (~copyIllegalFlag) begin
          casez (operation)
            `ALU_ADD,
            `ALU_OR,
            `ALU_XOR:
              copyOperation = operation;
            default: copyOperation = `ALU_ADD;
          endcase
        end
      end

      `OPCODE_BRANCH: begin
        case (func3Value)
          3'h0: copyOperation = `ALU_EQ;
          3'h1: copyOperation = `ALU_NE;
          3'h4: copyOperation = `ALU_LTS;
          3'h5: copyOperation = `ALU_GES;
          3'h6: copyOperation = `ALU_LTU;
          3'h7: copyOperation = `ALU_GEU;
          default: copyIllegalFlag = 1'b1;
        endcase
      end

      `OPCODE_MISC_MEM,
      `OPCODE_SYSTEM: begin
        copyOperation = operation;
      end

      default: copyIllegalFlag = 1'b1;
    endcase

    if (copyIllegalFlag) begin
      copyTypeA = typeA;
      copyTypeB = typeB;
      copyOperation = operation;
      copyMemoryWriteEnable = memoryWriteEnable;
      copyMemoryRequired = 0;
      copyMemorySize = memorySize;
      copyRFDataType = regFileDataType;
      copyRFWE = 0;
      copyBranchFlag = 0;
      copyJalFlag = 0;
      copyJalrFlag = 0;
    end

  end

  reg [4:0] X;
  reg [$clog2(testsPerOpcode+1)-1:0] V;
  integer numErrors;

  initial begin
    $timeformat(-9, 2, " ns", 0);
    numErrors = 0;
  end


  always begin
    for (X=0; X<2**5-1; X=X+1) begin
      for (V=0; V<testsPerOpcode; V=V+1) begin
        instruction[1:0]  = 2'b11;
        instruction[6:2]  = X;
        instruction[31:7] = $random;
        #delay;
      end
    end
    for (V=0; V<testsPerOpcode; V=V+1) begin
      instruction = $random;
      #delay;
    end

    if (|numErrors)
      $display ("FAIL!\nThere are errors in the design, number of errors: %d", numErrors);
    else
      $display ("SUCCESS!");
    $finish;
  end

  always begin
    @(instruction);
    #1;
    if (comp(illegalFlag, copyIllegalFlag))
      $display ("Time: %t | Instruction: %b :: 'illegal_flag' is incorrect (Actual=%b, Expected=%b)", $time, instruction, illegalFlag, copyIllegalFlag);
    if (~illegalFlag) begin
      if (comp(typeA, copyTypeA))
        $display ("Time: %t | Instruction: %b :: 'operand_A_type' is incorrect (Actual=%b, Expected=%b)", $time, instruction, typeA, copyTypeA);  
      if (comp(typeB, copyTypeB))
        $display ("Time: %t | Instruction: %b :: 'operand_A_type' is incorrect (Actual=%b, Expected=%b)", $time, instruction, typeB, copyTypeB);
      if (comp(operation, copyOperation))
        $display ("Time: %t | Instruction: %b :: 'alu_operation' is incorrect (Actual=%b, Expected=%b)", $time, instruction, operation, copyOperation);
      if (comp(memoryWriteEnable, copyMemoryWriteEnable))
        $display ("Time: %t | Instruction: %b :: 'memory_write_enable' is incorrect (Actual=%b, Expected=%b)", $time, instruction, memoryWriteEnable, copyMemoryWriteEnable);
      if (comp(memorySize, copyMemorySize))
        $display ("Time: %t | Instruction: %b :: 'memory_size' is incorrect (Actual=%b, Expected=%b)", $time, instruction, memorySize, copyMemorySize);
      if (comp(memoryRequired, copyMemoryRequired))
        $display ("Time: %t | Instruction: %b :: 'memory_require' is incorrect (Actual=%b, Expected=%b)", $time, instruction, memoryRequired, copyMemoryRequired);
      if (comp(regFileDataType, copyRFDataType))
        $display ("Time: %t | Instruction: %b :: 'reg_file_write_data_type' is incorrect (Actual=%b, Expected=%b)", $time, instruction, regFileDataType, copyRFDataType);
      if (comp(regFileWriteEnable, copyRFWE))
        $display ("Time: %t | Instruction: %b :: 'reg_file_write_enable' is incorrect (Actual=%b, Expected=%b)", $time, instruction, regFileWriteEnable, copyRFWE);
      if (comp(branchFlag, copyBranchFlag))
        $display ("Time: %t | Instruction: %b :: 'branch_flag' is incorrect (Actual=%b, Expected=%b)", $time, instruction, branchFlag, copyBranchFlag);
      if (comp(jalFlag, copyJalFlag))
        $display ("Time: %t | Instruction: %b :: 'jal_flag' is incorrect (Actual=%b, Expected=%b)", $time, instruction, jalFlag, copyJalFlag);
      if (comp(jalrFlag, copyJalrFlag))
        $display ("Time: %t | Instruction: %b :: 'jalr_flag' is incorrect (Actual=%b, Expected=%b)", $time, instruction, jalrFlag, copyJalrFlag);
    end

    if ((typeA != `TYPE_A_RD1) &
        (typeA != `TYPE_A_PC) &
        (typeA != `TYPE_A_ZERO)) begin
      $display ("Time: %t | Instruction: %b :: 'operand_A_type' must always have a legal value", $time, instruction);
      numErrors = numErrors + 1;
    end
    if ((typeB != `TYPE_B_RD2) &
        (typeB != `TYPE_B_IMM_I) &
        (typeB != `TYPE_B_IMM_U) &
        (typeB != `TYPE_B_IMM_S) &
        (typeB != `TYPE_B_PC_INCR)) begin
      $display ("Time: %t | Instruction: %b :: 'operand_B_type' must always have a legal value", $time, instruction);
      numErrors = numErrors + 1;
    end
    if ((operation != `ALU_ADD)  & (operation != `ALU_SUB) &
        (operation != `ALU_XOR)  & (operation != `ALU_OR)  &
        (operation != `ALU_AND)  & (operation != `ALU_SRA) &
        (operation != `ALU_SRL)  & (operation != `ALU_SLL) &
        (operation != `ALU_LTS)  & (operation != `ALU_LTU) &
        (operation != `ALU_GES)  & (operation != `ALU_GEU) &
        (operation != `ALU_EQ)   & (operation != `ALU_NE)  &
        (operation != `ALU_SLTS) & (operation != `ALU_SLTU)) begin
      $display ("Time: %t | Instruction: %b ::  'alu_operation' must always have a legal value", $time, instruction);
      numErrors = numErrors + 1;
    end
    if ((memorySize != `DATA_SIZE_BYTE) &
        (memorySize != `DATA_SIZE_HALF_WORD) &
        (memorySize != `DATA_SIZE_WORD) &
        (memorySize != `DATA_SIZE_U_BYTE) &
        (memorySize != `DATA_SIZE_U_HALF_WORD)) begin
      $display ("Time: %t | Instruction: %b :: 'memory_size' must always have a legal value", $time, instruction);
      numErrors = numErrors + 1;
    end
    if ((regFileDataType != `WRITEBACK_FROM_RESULT) &
        (regFileDataType != `WRITEBACK_FROM_DATA)) begin
      $display ("Time: %t | Instruction: %b :: 'reg_file_write_data_type' must always have a legal value", $time, instruction);
      numErrors = numErrors + 1;
    end
  end

  function comp;
    input [31:0] firstValue, secondValue;
    if (firstValue === secondValue)
      comp = 1'b0;
    else begin
      comp = 1'b1;
      numErrors = numErrors + 1;
    end
  endfunction

endmodule
