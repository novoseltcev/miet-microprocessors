module RAM
#(
  parameter SIZE      = 256, // bytes
  parameter INIT_FILE = ""
)
(
  // clock, reset
  input clk,
  input reset,

  // instruction memory interface
  output logic  [31:0]  instruction,
  input         [31:0]  instr_address,

  // data memory interface
  output logic  [31: 0]  data,
  input                  data_require,
  input                  data_write_enable,
  input         [3:  0]  data_byte_enable,
  input         [31: 0]  data_address,
  input         [31: 0]  write_data
);

  reg [31: 0] memory [0: SIZE / 4 - 1];
  //Init RAM
  integer ram_index;

  initial begin
    if(INIT_FILE != "") begin
      $readmemh(INIT_FILE, memory);
    end else
      for (ram_index = 0; ram_index < SIZE / 4 - 1; ram_index = ram_index + 1)
        memory[ram_index] = {32{1'b0}};
  end
  
  assign instruction = memory[(instr_address >> 2) % SIZE];
 
  always @(posedge clk)
    if(!reset)
      data  <= 32'b0;
    else
      if(data_require)
        if(!data_write_enable)
          data <= memory[(data_address >> 2) % SIZE];
        else begin
          if(data_byte_enable[0])
            memory[data_address[31:2]][7:0]  <= write_data[7:0];
	  
          if(data_byte_enable[1])
	    memory[data_address[31:2]][15:8] <= write_data[15:8];

	  if(data_byte_enable[2])
	    memory[data_address[31:2]][23:16] <= write_data[23:16];

	  if(data_byte_enable[3])
	    memory[data_address[31:2]][31:24] <= write_data[31:24];
        end
endmodule

