`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2021 08:09:50 PM
// Design Name: 
// Module Name: tb_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ALU_ADD  6'b01_10_00
`define ALU_SUB  6'b01_10_01

`define ALU_XOR  6'b10_11_11
`define ALU_OR   6'b10_11_10

`define ALU_AND  6'b01_01_01

`define ALU_SRA  6'b10_01_00
`define ALU_SRL  6'b10_01_01
`define ALU_SLL  6'b10_01_11

`define ALU_LTS  6'b00_00_00
`define ALU_LTU  6'b00_00_01

`define ALU_GES  6'b00_10_10
`define ALU_GEU  6'b00_10_11

`define ALU_EQ   6'b00_11_00
`define ALU_NE   6'b00_11_01


module tb_alu();
    
reg [31: 0]  A, B;
reg [5: 0]   Operation;
wire [31: 0] Result;
wire         flag;

integer seed,i;
initial begin 
    for (i = 0; i < 6; i = i + 1) begin
        $display("\nTest %0d:", i);
        A = $random; 
        B = $random;
        
        Operation = `ALU_ADD; #10; 
        $display("%0d  + %0d = %0d, flag = %u", A, B, Result, flag);
        
        Operation = `ALU_SUB; #10; 
        $display("%0d  - %0d = %0d, flag = %u", A, B, Result, flag);
       
        Operation = `ALU_XOR; #10; 
        $display("%b  ^ %b = %b, flag = %u", A, B, Result, flag);
        
        Operation = `ALU_OR; #10; 
        $display("%b  | %b = %b, flag = %u", A, B, Result, flag);
        
        Operation = `ALU_AND; #10; 
        $display("%b  & %b = %b, flag = %u", A, B, Result, flag);
        
        Operation = `ALU_SRA; #10; 
        $display("%b  >>> %0d = %b, flag = %u", $signed(A), $signed(B), $signed(Result), flag);
        
        Operation = `ALU_SRL; #10; 
        $display("%b  >> %0d = %b, flag = %u", A, B, Result, flag);
       
        Operation = `ALU_SLL; #10; 
        $display("%b  << %0d = %b, flag = %u", A, B, Result, flag);
        
        Operation = `ALU_LTS; #10; 
        $display("%0d  < %0d = %u, flag = %u", $signed(A), $signed(B), Result[0], flag);
        
        Operation = `ALU_LTU; #10; 
        $display("%0d  < %0d = %u, flag = %u", A, B, Result[0], flag);
        
        Operation = `ALU_GES; #10; 
        $display("%0d  >= %0d = %u, flag = %u", $signed(A), $signed(B), Result[0], flag);
        
        Operation = `ALU_GEU; #10; 
        $display("%0d  >= %0d = %u, flag = %u", A, B, Result[0], flag);
        
        Operation = `ALU_EQ; #10; 
        $display("%0d  == %0d = %u, flag = %u", A, B, Result[0], flag);
        
        Operation = `ALU_NE; #10; 
        $display("%0d  =! %0d = %u, flag = %u", A, B, Result[0], flag);
    end 
    $finish;
end

alu_mirisc_v alu_inst0 (
    .operand_A(A),
    .operand_B(B),
    .operation(Operation),
    .result(Result),
    .flag(flag)
);

endmodule
