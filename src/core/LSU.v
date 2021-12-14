`include "defines.v"

module LSU(
  input clk, reset,

  // core protocol
  input      [31: 0] core_address, core_write_data,
  input       core_require, core_write_enable, 
  input      [3:  0] core_size,
  output reg  core_stall_signal
  output reg [31: 0] core_read_data,
  
  // memory protocol
  input      [31: 0] memory_read_data
  output reg  memory_require, memory_write_enable,
  output reg [3:  0] memory_bytes_enable_map,
  output reg [31: 0] memory_address, memory_write_data
);

  assign core_address      = memory_address;

  always @(posedge clk)
    core_stall_signal <= 0
    if (!reset) begin
      tmp_read_data <=       0;
      tmp_write_data <=      0;
      memory_require <=      0;
      memory_write_enable <= 0;
    end else 
    if (core_require) begin
      memory_require    <= 1;
      core_stall_signal <= 1;
      memory_write_enable <= core_write_enable;
      if (core_write_enable)
	case(core_size)
	  `DATA_SIZE_BYTE: begin      
	    memory_write_data <= {4{core_write_data[7: 0]}};
	    case(core_address[1: 0])
   	      2'b00: memory_bytes_enable_map <= 4'b0001;
   	      2'b01: memory_bytes_enable_map <= 4'b0010;
   	      2'b10: memory_bytes_enable_map <= 4'b0100;
   	      2'b11: memory_bytes_enable_map <= 4'b1000;
	    endcase
          end
	  
	  `DATA_SIZE_HALF_WORD: begin
	    memory_write_data <= {2{core_write_data[15: 0]}};
	    case(core_address[1: 0])
              2'b0?: memory_bytes_enable_map <= 4'b0011;
              2'b1?: memory_bytes_enable_map <= 4'b1100;
	    endcase
          end

	  `DATA_SIZE_WORD: begin
	    memory_write_data <= core_write_data;
	    memory_bytes_enable_map <= 4'b1111;
	  end
	endcase
      else
	case({core_size, core_address[1: 0]})
	  {`DATA_SIZE_BYTE, 2'b00}: core_read_data <= {24{memory_read_data[7]}, memory_read_data[7: 0]};    
	  {`DATA_SIZE_BYTE, 2'b01}: core_read_data <= {24{memory_read_data[15]}, memory_read_data[15: 8]};    
	  {`DATA_SIZE_BYTE, 2'b10}: core_read_data <= {24{memory_read_data[23]}, memory_read_data[23: 16]};    
	  {`DATA_SIZE_BYTE, 2'b11}: core_read_data <= {24{memory_read_data[31]}, memory_read_data[31: 24]};

	  {`DATA_SIZE_U_BYTE, 2'b00}: core_read_data <= {24'b0, memory_read_data[7: 0]};    
	  {`DATA_SIZE_U_BYTE, 2'b01}: core_read_data <= {24'b0, memory_read_data[15: 8]};    
	  {`DATA_SIZE_U_BYTE, 2'b10}: core_read_data <= {24'b0, memory_read_data[23: 16]};    
	  {`DATA_SIZE_U_BYTE, 2'b11}: core_read_data <= {24'b0, memory_read_data[31: 24]};

          {`DATA_SIZE_HALF_WORD, 2'b0?}: core_read_data <= {16{memory_read_data[15]}, memory_read_data[15: 0]};  
          {`DATA_SIZE_HALF_WORD, 2'b1?}: core_read_data <= {16{memory_read_data[31]}, memory_read_data[31: 16]};
	  
          {`DATA_SIZE_U_HALF_WORD, 2'b0?}: core_read_data <= {16'b0, memory_read_data[15: 0]};  
          {`DATA_SIZE_U_HALF_WORD, 2'b1?}: core_read_data <= {16'b0, memory_read_data[31: 16]}; 

          {`DATA_SIZE_WORD, 2'b??}: core_read_data <= memory_read_data;   
	endcase
    end
  end
endmodule
