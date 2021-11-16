module MicroArchitecture (
    input  clk, reset,
    input  [31:0] IN,
    output reg [31:0] OUT
);


  reg  [7:0] PC = 8'b0;
  wire [31:0] Instr;
  
  
  wire 	    B;
  wire      C;
  wire [1:0] WS;
  wire [4:0] ALU_op;
  wire [4:0] A1;
  wire [4:0] A2;
  wire [7:0] CONST;
  wire [4:0] WA;

  assign {B, C, WS, ALU_op, A1, A2, CONST, WA} = Instr;
  wire WE3 = WS[0] | WS[1];

  reg  [31:0] WD3;


  wire [31:0] RD1;                       
  wire [31:0] RD2;
  wire [31:0] ALU_result;
  wire 	      ALU_flag;
  
  assign OUT = RD1;
  
  reg [31:0] SE;
  assign SE = {9'b0, ALU_op, A1, A2, CONST};
   
  always @(*) begin
    if(WE3)
		case(WS)
            2'b01 : WD3 <= IN;
	    	2'b10 : WD3 <= SE; 
	    	2'b11 : WD3 <= ALU_result;
		endcase
  end
  
  always @(posedge clk) begin
    if (reset == 1)
      PC <= 8'h0;
    else begin
      if ((ALU_flag & C) | B) 
        PC <= PC + CONST;
      else 
        PC <= PC + 8'b1;
    end
  end
 
    DataMemory DM_connection(
    .address(PC),
    .data(Instr)
  );

  
  RegFile RF_connection(
	.clk(clk),
	
    .address_1(A1),
    .readData_1(RD1),
    
    .address_2(A2),
    .readData_2(RD2),
    
    .writeEnable_3(WE3),
    .address_3(WA),
    .writeData_3(WD3)
  );


  ALU_RiscV ALU_connection(
	.operand_A(RD1),
	.operand_B(RD2),
    .operation(ALU_op),
    .result(ALU_result),
    .flag(ALU_flag)
  );

endmodule
