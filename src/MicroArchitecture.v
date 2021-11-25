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
  wire [4:0] OPERATION;
  wire [4:0] A1;
  wire [4:0] A2;
  wire [7:0] CONST;
  wire [4:0] WA;

  assign {B, C, WS, OPERATION, A1, A2, CONST, WA} = Instr;
  wire WE3 = WS[0] | WS[1];

  reg  [31:0] WD3;


  wire [31:0] RD1;                       
  wire [31:0] RD2;
  wire [31:0] ALU_Result;
  wire	      Comparator;
  
  assign OUT = RD1;
  
  reg [31:0] SE;
  assign SE = {{9{OPERATION[4]}}, OPERATION, A1, A2, CONST};
   
  always @(*) begin
    if(WE3)
      case(WS)
        2'd1 : WD3 <= IN;
  	2'd2 : WD3 <= SE; 
 	2'd3 : WD3 <= ALU_Result;
      endcase
  end
  
  always @(posedge clk) begin
    if (reset == 1)
      PC <= 0;
    else
      PC <= PC + ( (Comparator & C | B) ? $signed(CONST) : 1);
  end
 
    DataMemory DM_connection(
    .address(PC),
    .data(Instr)
  );

  RegFile RF_connection(
    .clk(clk),
	
    .Address_1(A1),
    .ReadData_1(RD1),
    
    .Address_2(A2),
    .ReadData_2(RD2),
    
    .WriteEnable_3(WE3),
    .Address_3(WA),
    .WriteData_3(WD3)
  );


  ALU_RiscV ALU_connection(
    .A(RD1),
    .B(RD2),
    .Operation(OPERATION),
    .Result(ALU_Result),
    .Flag(Comparator)
  );

endmodule
