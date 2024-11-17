module Bai3(
	input CLOCK_50,
	input [0:0] KEY,
	input [15:0] SW,
	output [15:0] LEDR,
	output [6:0] HEX0,
	output [6:0] HEX1
);


system Nios_system(
	.clk_clk (CLOCK_50),
	.reset_reset_n (KEY[0]),
	.red_leds_0_conduit_end_export(LEDR),
	.switches_0_conduit_end_export(SW),
	.hex_dec_0_conduit_end_export({25'd0,HEX0}),
	.hex_dec_1_conduit_end_export({25'd0,HEX1})
);



endmodule
