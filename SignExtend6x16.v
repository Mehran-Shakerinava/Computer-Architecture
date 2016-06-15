/* 6-bit to 16-bit Sign Extender */
module SignExtend6x16(
    in,
    out
);

/* Parameters */
parameter INPUT_WIDTH = 6;
parameter OUTPUT_WIDTH = 16;

/* Inputs */
input wire [INPUT_WIDTH - 1 : 0] in;

/* Outputs */
output wire [OUTPUT_WIDTH - 1 : 0] out;

/* Behavioral Combinational Design */
assign out = $signed(in) + $signed(16'b0);

endmodule