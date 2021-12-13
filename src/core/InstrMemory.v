module InstrMemory (
  input  [31: 0] address,
  output [31: 0] data
);

  reg [31: 0] RAM [0: 163839];
  assign data = RAM[address[31: 2]];
  initial $readmemh("task.hex", RAM);
endmodule
