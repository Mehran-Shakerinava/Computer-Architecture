/* 2 x 16-bit Multiplexor */
module Mux2x16(
	in0,
	in1,
	out,
	sel
);

/* Parameters */
parameter DATA_WIDTH = 16;
parameter SEL_WIDTH = 1;

/* Inputs */
input wire [DATA_WIDTH - 1 : 0] in0, in1;
input wire [SEL_WIDTH - 1 : 0] sel;

/* Outputs */
output reg [DATA_WIDTH - 1 : 0] out;

/* Behavioral Combinational Design */
always @ (in0 or in1 or sel)
begin
	case (sel)
		'b0 : out <= in0;
		'b1 : out <= in1;
	endcase
end

endmodule