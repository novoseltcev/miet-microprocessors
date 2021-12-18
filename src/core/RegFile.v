module RegFile (
  input       clk,
  input      [4:0] address_1, address_2, address_3,
  input  	  write_enable_3,
  input	     [31:0] write_data_3,
  output reg [31:0] read_data_1, read_data_2
);

  reg [31:0] RAM [0:31];
  
  assign read_data_1 = (address_1 == 0) ? 32'b0 : RAM[address_1];
  assign read_data_2 = (address_2 == 0) ? 32'b0 : RAM[address_2];
  
  always @(posedge clk)
    if (write_enable_3) 
      RAM[address_3] <= write_data_3;

endmodule
