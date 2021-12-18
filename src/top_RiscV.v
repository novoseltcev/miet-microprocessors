`include "core/CoreRiscV.v"
`include "core/RAM_RiscV.v"

module top_RiscV
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)
(
  input clk,
  input reset
);

  logic  [31:0]  core_instr_data;
  logic  [31:0]  core_instr_address;

  logic  [31:0]  core_data_read;
  logic          core_data_require;
  logic          core_data_write_enable;
  logic  [3:0]   core_data_byte_enable_map;
  logic  [31:0]  core_data_address;
  logic  [31:0]  core_data_write;

  logic  [31:0]  ram_data_read;
  logic          ram_data_begin;
  logic          ram_data_end;
  
  logic          ram_data_require;
  logic          ram_data_write_enable;
  logic  [3:0]   ram_data_byte_enable_map;
  logic  [31:0]  ram_data_address;
  logic  [31:0]  ram_data_write;

  logic  data_mem_valid;
  assign data_mem_valid = (core_data_address >= RAM_SIZE) ?  1'b0 : 1'b1;

  assign core_data_read           = (data_mem_valid) ? ram_data_read     : 1'b0;
  assign ram_data_require         = (data_mem_valid) ? core_data_require : 1'b0;
  assign ram_data_write_enable    = core_data_write_enable;
  assign ram_data_byte_enable_map = core_data_byte_enable_map;
  assign ram_data_address         = core_data_address;
  assign ram_data_write           = core_data_write;

  CoreRiscV core (
    .clk   ( clk   ),
    .reset ( !reset ),

    .instr_address ( core_instr_address ),
    .instr         ( core_instr_data    ),

    .external_data        ( core_data_read            ),
    .memory_ex_begin      ( ram_data_begin			  ),
    .memory_ex_end		  ( ram_data_end			  ),
    
    .memory_require       ( core_data_require         ),
    .memory_write_enable  ( core_data_write_enable    ),
    .memory_load_byte_map ( core_data_byte_enable_map ),
    .external_address     ( core_data_address            ),
    .internal_data        ( core_data_write           )
  );
  
  RAM_RiscV
  #(
    .SIZE      (RAM_SIZE),
    .INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk   ( clk),
    .reset (reset),

    .instr_data    ( core_instr_data ),
    .instr_address ( core_instr_address ),

    .data_read            ( ram_data_read            ),
    .data_begin           ( ram_data_begin           ),
    .data_end             ( ram_data_end             ),
    
    .data_require         ( ram_data_require         ),
    .data_write_enable    ( ram_data_write_enable    ),
    .data_byte_enable_map ( ram_data_byte_enable_map ),
    .data_address         ( ram_data_address         ),
    .data_write           ( ram_data_write           )
  );
endmodule
