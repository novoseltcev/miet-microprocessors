`include "core/Core.v"
`include "AddressDecoder.v"
`include "controller/RAM.v"
`include "controller/Diode.v"
`include "controller/PS2Keyboard.v"


module Motherboard
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)
(
  input clk, reset,
  input ps2_data, ps2_clk,
  output reg [31: 0] diodes
);

  logic  [31: 0] instr_data;
  logic  [31: 0] instr_address;

  logic  [31: 0] data_bus;  
  logic          require, write_enable;
  logic  [3:  0] byte_enable;
  logic  [31: 0] write_data;
  logic  [31: 0] data_address;
  
  logic ram_require;
  logic ram_write_enable, diodes_write_enable, keyboard_readed_signal;
  logic [1:  0] data_selector;
  logic [31: 0] ram_data, diodes_data;
  logic [7:  0] keyboard_data;
  logic keyboard_valid_data;
  assign diodes = diodes_data;
  
  
  Core core_socket (
    .clk(clk), 
    .areset(!reset),

    .instr_address ( instr_address ),
    .instr         ( instr_data    ),
    
    .memory_require       ( require      ),
    .memory_write_enable  ( write_enable ),
    .memory_load_byte_map ( byte_enable  ),
    .external_address     ( data_address ),
    .internal_data        ( write_data   ),
    
    .external_data        ( data_bus )
  );
  
  
  AddressDecoder 
  #(
    .RAM_SIZE(RAM_SIZE)
  ) address_decoder (
    .write_enable(write_enable),
    .require(require),
    .address(data_address),
    
    .memory_require(ram_require),
    .memory_write_enable(ram_write_enable),
    .memory_data(ram_data),
    
    .diodes_write_enable(diodes_write_enable),
    .diodes_data(diodes_data),
   
    .keyboard_data(keyboard_data),
    .keyboard_valid_data(keyboard_valid_data),
    .keyboard_readed_signal(keyboard_readed_signal),
    
    .out_data(data_bus)
  );
 
  
  RAM
  #(
    .SIZE      (RAM_SIZE),
    .INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk (clk), .reset (reset),

    .instruction          ( instr_data    ),
    .instr_address        ( instr_address ),
	.data_byte_enable     ( byte_enable   ),
    .data_address         ( data_address  ),
    .write_data           ( write_data    ),
    
    .data_require         ( ram_require      ),
    .data_write_enable    ( ram_write_enable ),
    
    .data                 ( ram_data )    
  );
  
  
  Diode diodes_controller (
    .clk(clk), .areset(!reset),
    
    .write_enable(diodes_write_enable), 
    .byte_enable(byte_enable),
    .address(data_address),
    .write_data(write_data),
    
    .data(diodes_data)
  );
  
  
  PS2Keyboard keyboard_controller (
    .clk_50(clk), .areset(!reset | !keyboard_readed_signal),
    
    .ps2_clk(ps2_clk), 
    .ps2_data(ps2_data),

    .valid_data(keyboard_valid_data),
    .data(keyboard_data)
  );
  
endmodule
