module AddressDecoder
#(
  parameter RAM_SIZE = 256
)
(
  input write_enable, require,
  input [31: 0] address,
    
  output reg    memory_require, memory_write_enable,
  input [31: 0] memory_data,
    
  output reg    diodes_write_enable,
  input [31: 0] diodes_data,
   
  input [7: 0] keyboard_data,
  input        keyboard_valid_data,
  output reg   keyboard_readed_signal,
    
  output reg [31: 0] out_data
);

  always @(*) begin
    memory_require         <= 1'b0;
    memory_write_enable    <= 1'b0;
    diodes_write_enable    <= 1'b0;
    keyboard_readed_signal <= 1'b0;
    out_data               <= 32'b0;
    if (require) begin
      if (address >= 32'b0 && address < RAM_SIZE) begin
        memory_write_enable <= write_enable;
        memory_require      <= 1'b1;
        out_data            <= memory_data;
      end else begin
    	case(address)
    	  32'h80000009: out_data <= diodes_data;
    	  32'h80003000: out_data <= {24'b0, keyboard_data};
          32'h80003001: out_data <= {31'b0, keyboard_valid_data};
          default:      out_data <= 32'b0;
        endcase
        case(address)
    	  32'h80000009: diodes_write_enable    <= 1'b1;
    	  32'h80003000: keyboard_readed_signal <= 1'b1;
        endcase
      end
    end
  end
endmodule
