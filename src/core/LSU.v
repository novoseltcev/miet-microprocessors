`include "defines.v"

module LSU(
  input clk, reset,

  // core protocol
  input      [31: 0] core_address, core_write_data,
  input       core_require, core_write_enable, 
  input      [2:  0] core_size,
  output reg  core_stall_signal,
  output reg [31: 0] core_read_data,
  
  // memory protocol
  input      [31: 0] memory_read_data,
  input       memory_end_signal, memory_begin_signal,
  output reg  memory_require, memory_write_enable, 
  output reg [3:  0] memory_byte_enable_map,
  output reg [31: 0] memory_address, memory_write_data
);
  
  always @(*)
    if (reset) begin
      core_read_data       <= 32'b0;
      memory_write_data    <= 32'b0;
      memory_address       <= 32'b0;
      memory_byte_enable_map  <= 4'b0;
      memory_require       	  <= 1'b0;
      memory_write_enable     <= 1'b0;
      //core_stall_signal       <= 1'b0;
    end else begin
      memory_address <= core_address;
      memory_write_enable <= core_write_enable;
      if (core_require) begin
        memory_require <= 1'b1;
        if (core_write_enable) begin
          case(core_size)
            `DATA_SIZE_BYTE:      memory_write_data <= {4{core_write_data[7: 0]}};
            `DATA_SIZE_HALF_WORD: memory_write_data <= {2{core_write_data[15: 0]}};
            `DATA_SIZE_WORD:      memory_write_data <= core_write_data;
          endcase
          casez({core_size, core_address[1: 0]})
            {`DATA_SIZE_BYTE, 2'b00}: memory_byte_enable_map <= 4'b0001;
            {`DATA_SIZE_BYTE, 2'b01}: memory_byte_enable_map <= 4'b0010;
            {`DATA_SIZE_BYTE, 2'b10}: memory_byte_enable_map <= 4'b0100;
            {`DATA_SIZE_BYTE, 2'b11}: memory_byte_enable_map <= 4'b1000;

            {`DATA_SIZE_HALF_WORD, 2'b0?}: memory_byte_enable_map <= 4'b0011;
            {`DATA_SIZE_HALF_WORD, 2'b1?}: memory_byte_enable_map <= 4'b1100;

            {`DATA_SIZE_WORD, 2'b??}: memory_byte_enable_map <= 4'b1111;
          endcase
        end else
          casez({core_size, core_address[1: 0]})
            {`DATA_SIZE_BYTE, 2'b00}: core_read_data <= {{24{memory_read_data[7]}}, memory_read_data[7: 0]};    
            {`DATA_SIZE_BYTE, 2'b01}: core_read_data <= {{24{memory_read_data[15]}}, memory_read_data[15: 8]};    
            {`DATA_SIZE_BYTE, 2'b10}: core_read_data <= {{24{memory_read_data[23]}}, memory_read_data[23: 16]};    
            {`DATA_SIZE_BYTE, 2'b11}: core_read_data <= {{24{memory_read_data[31]}}, memory_read_data[31: 24]};

            {`DATA_SIZE_U_BYTE, 2'b00}: core_read_data <= {24'b0, memory_read_data[7: 0]};    
            {`DATA_SIZE_U_BYTE, 2'b01}: core_read_data <= {24'b0, memory_read_data[15: 8]};    
            {`DATA_SIZE_U_BYTE, 2'b10}: core_read_data <= {24'b0, memory_read_data[23: 16]};    
            {`DATA_SIZE_U_BYTE, 2'b11}: core_read_data <= {24'b0, memory_read_data[31: 24]};

            {`DATA_SIZE_HALF_WORD, 2'b0?}: core_read_data <= {{16{memory_read_data[15]}}, memory_read_data[15: 0]};  
            {`DATA_SIZE_HALF_WORD, 2'b1?}: core_read_data <= {{16{memory_read_data[31]}}, memory_read_data[31: 16]};

            {`DATA_SIZE_U_HALF_WORD, 2'b0?}: core_read_data <= {16'b0, memory_read_data[15: 0]};  
            {`DATA_SIZE_U_HALF_WORD, 2'b1?}: core_read_data <= {16'b0, memory_read_data[31: 16]}; 

            {`DATA_SIZE_WORD, 2'b??}: core_read_data <= memory_read_data;   
          endcase
      end //core_req
    end
    
  reg working;
  always@(posedge clk)
    working = ~core_stall_signal;
    
  assign core_stall_signal = working && core_require;
    
endmodule
