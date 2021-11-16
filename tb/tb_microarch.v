`timescale 1ns / 1ps


module tb_microarch();
  
  reg [31: 0] SW = 32'b0;
  reg [31: 0] HEX;
  reg clk = 1;
  reg reset = 1;
  
  integer i = 0;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_microarch);
    
    #100;
    clk = 0;
    #100;
    clk = 1;
    
    while (i < 1100)
    begin
      #100;
      reset = 0;
      clk = ~clk;
      if (clk == 1'b1) begin
        $display("PC=%d :: Instr=%32b :: OUT = %10d", 
                 tb_microarch.archx32.PC, tb_microarch.archx32.Instr, HEX);
        if (tb_microarch.archx32.B | tb_microarch.archx32.C)
          $display("TRY JUMP to PC: %2d", tb_microarch.archx32.PC + $signed(tb_microarch.archx32.CONST));
        else begin
          case (tb_microarch.archx32.WS)
            2'b00 : $display("CALCULATE: %5b(x%d = %2d, x%d = %2d) = %2d",
                             tb_microarch.archx32.ALU_op, 
                             tb_microarch.archx32.A1, tb_microarch.archx32.RD1,
                             tb_microarch.archx32.A2, tb_microarch.archx32.RD2,
                             tb_microarch.archx32.ALU_result
                            );

            2'b01 : $display("SAVE FROM IO: %2d as x%1d = %2d", 
                             tb_microarch.archx32.IN, 
                             tb_microarch.archx32.WA, tb_microarch.archx32.WD3
                            );

            2'b10 : $display("SAVE CONST: %2d as x%1d = %2d", 
                             tb_microarch.archx32.SE,
                             tb_microarch.archx32.WA, tb_microarch.archx32.WD3
                            );

            2'b11 : $display("SAVE RESULT: x%d = %5b(x%d as %2d, x%d as %2d) = %2d", 
                             tb_microarch.archx32.WA, tb_microarch.archx32.ALU_op, 
                             tb_microarch.archx32.A1, tb_microarch.archx32.RD1,
                             tb_microarch.archx32.A2, tb_microarch.archx32.RD2,
                             tb_microarch.archx32.WD3
                            );
          endcase
        end
      end
      i = i + 1;
      if (tb_microarch.archx32.PC == 32)
        break;
      
	end
  	$finish;
  end
  
  MicroArchitecture archx32 (
    .clk(clk),
    .reset(reset),
    .IN(SW),
    .OUT(HEX)    
  );
  
endmodule
