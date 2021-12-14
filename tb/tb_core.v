`timescale 1ns / 1ps
`include "CoreRiscV.v"

module tb_core();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 512;       // in 32-bit words

  // clock, reset
  reg clk;
  reg rst_n;

  CoreRiscV core(clk);
  
  integer i = 0;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_core);
    
    clk   = 1'b0;
    rst_n = 1'b0;
    # RST_WAIT;
    rst_n = 1'b1;
    
    while (1) begin
      # HF_CYCLE;
      clk = ~clk;
      i = i + 1;
      if (tb_core.core.opcode == `OPCODE_SYSTEM) begin
        $display("RESULT FOUNDED:%10d", tb_core.core.RF_connection.RAM[10]);
        break;
      end
      
      if (clk == 1'b1) begin
        $display("Takt=%3d :: PC=%2d :: Instr=%8h", i / 2 + 1, tb_core.core.pc , tb_core.core.instr);
        case(tb_core.core.opcode)
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
            break;
          end

        endcase
        if (tb_core.core.jal_signal)
          $display("\tJUMP TO %10d", tb_core.core.pc + tb_core.core.imm_J);
        else if (tb_core.core.jalr_signal)
          $display("\tJUMP TO %10d", tb_core.core.rd1 + tb_core.core.imm_I);
        else if (tb_core.core.branch_signal)
          $display("\tTRY JUMP TO %10d", tb_core.core.pc + tb_core.core.imm_B);
        else if (tb_core.core.memory_write_enable_signal)
          $display("\tMem[%10d] = %10d", tb_core.core.alu_result, tb_core.core.imm_S);
        else if (tb_core.core.memory_require_signal)
          $display("\tx%2d = Mem[%10d] = %10d", tb_core.core.rd3, tb_core.core.alu_result, tb_core.core.readed_data);
        else
          $display("\t%5b(%10d, %10d) = %10d", tb_core.core.alu_operation_signal,  tb_core.core.rd1, tb_core.core.rd2, tb_core.core.wd3);
      end
    end
    $finish;
  end

endmodule
