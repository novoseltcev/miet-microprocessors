module InstrMemory (
  input  [31: 0] address,
  output [31: 0] data
);

  reg [31: 0] RAM [0: 31];
  assign data = RAM[address];
  initial $readmemh("task.hex", RAM);
endmodule
