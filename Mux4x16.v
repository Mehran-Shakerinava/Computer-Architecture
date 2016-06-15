/* 4 x 16-bit Multiplexor */
module Mux4x16(
    in0,
    in1,
    in2,
    in3,
    out,
    sel
);

/* Parameters */
parameter DATA_WIDTH = 16;
parameter SEL_WIDTH = 2;

/* Inputs */
input wire [DATA_WIDTH - 1 : 0] in0, in1, in2, in3;
input wire [SEL_WIDTH - 1 : 0] sel;

/* Outputs */
output wire [DATA_WIDTH - 1 : 0] out;

/* Internal Wires */
wire [DATA_WIDTH - 1 : 0] out0, out1;

/* Gate-level Combinational Design */
Mux2x16 mux0(
    .in0 (in0),
    .in1 (in1),
    .out (out0),
    .sel (sel[0])
);

Mux2x16 mux1(
    .in0 (in2),
    .in1 (in3),
    .out (out1),
    .sel (sel[0])
);

Mux2x16 mux2(
    .in0 (out0),
    .in1 (out1),
    .out (out),
    .sel (sel[1])  
);

endmodule