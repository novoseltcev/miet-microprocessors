module RAM_RiscV
#(
  parameter SIZE      = 256, // bytes
  parameter INIT_FILE = ""
)
(
  // clock, reset
  input clk,
  input reset,

  // instruction memory interface
  output logic  [31:0]  instr_data,
  input         [31:0]  instr_address,

  // data memory interface
  output logic  [31:0]  data_read,
  output logic   data_begin, data_end,  
  input                 data_require,
  input                 data_write_enable,
  input         [3:0]   data_byte_enable_map,
  input         [31:0]  data_address,
  input         [31:0]  data_write
);

  reg [31:0]    memory [0:SIZE / 4 - 1];
  //Init RAM
  integer ram_index;

  initial begin
    if(INIT_FILE != "") begin
      $readmemh(INIT_FILE, memory);
    end else
      for (ram_index = 0; ram_index < SIZE/4-1; ram_index = ram_index + 1)
        memory[ram_index] = {32{1'b0}};
  end
  
  assign instr_data = memory[(instr_address >> 2) % SIZE];
  
  reg[2: 0] work_stage = 3'd1;
  always @(posedge clk) begin
    if(!reset) begin
      data_read  <= 32'b0;
      data_begin <= 1'b0;
      data_end <= 1'b0;
    end
    else
      case(work_stage)
        3'd0: begin
          data_end <= 1'b1;
          work_stage <= work_stage + 3'd1;
        end
        
        3'd1: begin
          data_end <= 1'b0;
          if(data_require) begin
            data_begin <= 1'b1;
            work_stage <= work_stage + 3'b1;
            if (!data_write_enable)
              data_read <= memory[(data_address >> 2) % SIZE];
            else begin
              if(data_byte_enable_map[0])
                memory[data_address[31:2]][7:0]  <= data_write[7:0];

	          if(data_byte_enable_map[1])
	            memory[data_address[31:2]][15:8] <= data_write[15:8];

	          if(data_byte_enable_map[2])
	            memory[data_address[31:2]][23:16] <= data_write[23:16];

	          if(data_byte_enable_map[3])
	            memory[data_address[31:2]][31:24] <= data_write[31:24];
            end
          end 
        end
        
        3'd2: begin 
          data_begin <= 1'b0;
          work_stage <= work_stage + 3'd1;
        end
        
        default:
          work_stage <= work_stage + 3'd1;
      endcase
  end
endmodule
