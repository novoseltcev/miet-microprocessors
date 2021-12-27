`timescale 1ns / 1ps
//`include "PS2Keyboard.v"
`include "Motherboard.v"


module tb_devices();
  parameter     HF_CYCLE = 2.5;       // 100 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 1024;       // in 32-bit words

  reg clk;
  reg reset;
  reg keyboard_clk = 1'b1;
  reg keyboard_data = 1'b1;
  reg [31: 0] diodes;

  Motherboard #(
    .RAM_SIZE(RAM_SIZE),
    .RAM_INIT_FILE("task.hex")
  ) motherboard (
    .clk(clk), 
    .reset(reset),
    .ps2_clk(keyboard_clk),
    .ps2_data(keyboard_data),
    .diodes(diodes)
  );
  
  integer i = 0;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_devices);
    
    clk   = 1'b0;
    reset = 1'b0;
    keyboard_clk = 1'b1;
    keyboard_data = 1'b1;
    # RST_WAIT;
    clk = 1'b1;
    # RST_WAIT;
    reset = 1'b1;
    
    while (1) begin
      # HF_CYCLE;
      clk = ~clk;
      i = i + 1;
      if (tb_devices.motherboard.core_socket.opcode == `OPCODE_SYSTEM) begin
        $display("RESULT: a0 = %8h", tb_devices.motherboard.core_socket.RF_connection.RAM[10]);
        break;
      end
      
      if (i > 1000) begin
        $display("STACK OVERFLOW");
        break;
      end
      
      if (clk == 1'b1) begin
        $display("Takt=%3d :: PC=%2d :: Instr=%8h", i / 2 + 1, tb_devices.motherboard.core_socket.pc , tb_devices.motherboard.core_socket.instr);
        case(tb_devices.motherboard.core_socket.opcode)
          `OPCODE_OPERATION_REG : $display("\t OPERATION_REG");
          `OPCODE_OPERATION_IMM : $display("\t OPERATION_IMM");
          `OPCODE_IMM_U_LOAD	: $display("\t IMM_U_LOAD");
          `OPCODE_IMM_U_PC		: $display("\t IMM_U_PC	");
          `OPCODE_STORE			: $display("\t STORE");
          `OPCODE_LOAD 			: $display("\t LOAD");
          `OPCODE_BRANCH		: $display("\t BRANCH");
          `OPCODE_JUMP_LINK_REG : $display("\t JUMP_LINK_REG");
          `OPCODE_JUMP_LINK_IMM : $display("\t JUMP_LINK_IMM");
          `OPCODE_MISC_MEM		: $display("\t MISC_MEM");
          `OPCODE_SYSTEM		: $display("\t SYSTEM");
          default: begin
            $display("\n!!!OPCODE: UNKNOWN!!!");
          end

        endcase
        if (tb_devices.motherboard.core_socket.jal_signal)
          $display("\tJUMP TO %10d", tb_devices.motherboard.core_socket.pc + tb_devices.motherboard.core_socket.imm_J);
        else if (tb_devices.motherboard.core_socket.jalr_signal)
          $display("\tJUMP TO %10d", tb_devices.motherboard.core_socket.rd1 + tb_devices.motherboard.core_socket.imm_I);
        else if (tb_devices.motherboard.core_socket.branch_signal)
          $display("\tRESULT OF(%10d, %10d) TRY JUMP TO %10d", tb_devices.motherboard.core_socket.operand_A,  tb_devices.motherboard.core_socket.operand_B, tb_devices.motherboard.core_socket.pc + tb_devices.motherboard.core_socket.imm_B);
        else if (tb_devices.motherboard.core_socket.memory_write_enable_signal)
          $display("\tMem[%8h] = %8h", tb_devices.motherboard.core_socket.alu_result, tb_devices.motherboard.core_socket.rd2 );
        else if (tb_devices.motherboard.core_socket.memory_require_signal)
          $display("\tx%2d = Mem[%8h] = %8h", tb_devices.motherboard.core_socket.rd3, tb_devices.motherboard.core_socket.alu_result, tb_devices.motherboard.core_socket.wd3);
        else
          $display("\t%5b(%10d, %10d) = %10d", tb_devices.motherboard.core_socket.alu_operation_signal,  tb_devices.motherboard.core_socket.operand_A, tb_devices.motherboard.core_socket.operand_B, tb_devices.motherboard.core_socket.wd3);
      end
    end 
    $finish;
  end
endmodule
