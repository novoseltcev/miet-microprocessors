module DataMemory (
  input clk, write_enable, access,
  input [31: 0] address,
  input [31: 0] write_data,
  input [2: 0]  size,

  output [31: 0] read_data
);

  reg [31: 0] RAM [0: 31];
  
  always @(*)
    if (access) begin
      if (write_enable) 
        case()
		  `DATA_SIZE_BYTE:      RAM[address][7:0]  <= write_data[7: 0; 
		  `DATA_SIZE_HALF_WORD: RAM[address][15:0] <= write_data[15: 0];
		  `DATA_SIZE_WORD:      RAM[address]       <= write_data;
        endcase
      else
        case()
		  `DATA_SIZE_BYTE:        read_data <= {{24{RAM[address][7]}},  RAM[address][7: 0]}; 
		  `DATA_SIZE_HALF_WORD:   read_data <= {{16{RAM[address][15]}}, RAM[address][15: 0]};
		  `DATA_SIZE_WORD:        read_data <= RAM[address];
		  `DATA_SIZE_U_BYTE:      read_data <= {24'b0, RAM[address][7: 0]};
		  `DATA_SIZE_U_HALF_WORD: read_data <= {16'b0, RAM[address][15: 0]};
        endcase
 
endmodule
