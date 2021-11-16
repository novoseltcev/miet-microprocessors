module RegFile (
    input clk,
  	input [4:0] address_1, address_2, address_3,
    input 	     writeEnable_3,
    input [31:0] writeData_3,
  	output reg [31:0] readData_1, readData_2
);

  reg [31:0] RAM [0:31];
  
  assign readData_1 = (address_1 == 0) ? 32'b0 : RAM[address_1];
  assign readData_2 = (address_2 == 0) ? 32'b0 : RAM[address_2];
  
  always @(posedge clk)
    if (writeEnable_3) 
      RAM[address_3] <= writeData_3;

endmodule
