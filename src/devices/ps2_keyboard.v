module ps2_keyboard (
  input areset,
  input clk_50,
  input ps2_clk,
  input ps2_dat,

  output reg    valid_data,
  output [7: 0] data
);
  function parity_calc;
    input [7: 0] a;
    parity_calc = ~(a[0] ^ a[1] ^ a[2] ^ a[3] ^ 
	            a[4] ^ a[5] ^ a[6] ^ a[7]); 
  endfunction  

  reg [1: 0] state;
  reg [9: 0] ps2_clk_detect;   
  reg [8: 0] shift_reg;
  reg [3: 0] count_bit;
  wire ps2_clk_negedge = &ps2_clk_detect[4:0] && &(~ps2_clk_detect[9:5]);
  assign data = shift_reg[7:0];

  localparam IDLE = 2'd0; 
  localparam RECEIVE_DATA = 2'd1;
  localparam CHECK_PARITY_STOP_BITS = 2'd2;
  always @ (negedge ps2_clk or posedge areset)
    if (areset)     
      state <= IDLE; 
    else case (state) 
      IDLE:                 if (!ps2_dat)
                   	      state = RECEIVE_DATA; 
      RECEIVE_DATA:         if (count_bit == 8)
			      state = CHECK_PARITY_STOP_BITS; 
      CHECK_PARITY_STOP_BITS: state = IDLE; 
      default:                state = IDLE; 
    endcase

  always @ (posedge clk_50 or posedge areset)
    if (areset) begin
      ps2_clk_detect <= 10'd0
      shift_reg      <= 9'b0;
      count_bit      <= 4'b0;
      valid_data     <= 1'b0;
    end else
      if (ps2_clk_negedge) begin 
        if (state == RECEIVE_DATA) begin
          shift_reg <= {ps2_dat, shift_reg[8:1]}; 
	  count_bit <= count_bit + 4'b1;
        end else
	  count_bit <= 4'b0;
      ps2_clk_detect <= {ps2_clk, ps2_clk_detect[9:1];}
      valid_data <= (
	     ps2_dat 
	  && parity_calc(shift_reg[7:0]) == shift_reg[8] 
          && state == CHECK_PARITY_STOP_BITS
	)
    end
endmodule
