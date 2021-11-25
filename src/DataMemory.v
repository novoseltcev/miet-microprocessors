module DataMemory (
  input  [7:0]  address,
  output [31:0] data
);

  reg [31:0] RAM [0:7];
  assign data = RAM[address];
 
  initial $readmemb("reverseBin.binary", RAM);

endmodule
