module Diode ( 
  input clk, areset,
  
  input              write_enable, 
  input      [3:  0] byte_enable,
  input      [31: 0] write_data, address,
  output reg [31: 0] data  
);
  always @(posedge clk)
    if(areset)
      data <= 32'b0;
    else if(write_enable 
      && byte_enable[1] 
      && address[3: 2] == 2'b10)
      data <= write_data;
endmodule
