module RegFile (
  input clk,
  input [4:0] Address_1, Address_2, Address_3,
  input  	    WriteEnable_3,
  input	     [31:0] WriteData_3,
  output reg [31:0] ReadData_1, ReadData_2
);

  reg [31:0] RAM [0:31];
  
  assign ReadData_1 = (Address_1 == 0) ? 32'b0 : RAM[Address_1];
  assign ReadData_2 = (Address_2 == 0) ? 32'b0 : RAM[Address_2];
  
  always @(posedge clk)
    if (WriteEnable_3) 
      RAM[Address_3] <= WriteData_3;

endmodule
