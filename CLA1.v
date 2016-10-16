/* 1-bit Carry Look-ahead Adder */
module CLA1(
  lhs,
  rhs,
  cin,
  inv,
  
  res,
  cout,
  of,
  p,
  g
);

// Parameters
parameter DATA_WIDTH = 1;

// Inputs
input wire [DATA_WIDTH - 1 : 0] lhs, rhs;
input wire cin, inv;

// Outputs
output wire [DATA_WIDTH - 1 : 0] res;
output wire cout, of, p, g;

// Internal Connections
wire rhs_xor_inv;
wire p_and_cin;

// Gate-level Combinational Logic Design
xor #(1) xor0 (rhs_xor_inv, rhs, inv);
xor #(1) xor1 (res, lhs, rhs_xor_inv, cin);
and #(1) and0 (p_and_cin, p, cin);
or  #(1) or1  (p, lhs, rhs_xor_inv);
and #(1) and1 (g, lhs, rhs_xor_inv);
or  #(1) or0  (cout, g, p_and_cin);
xor #(1) xor2 (of, cin, cout);

endmodule