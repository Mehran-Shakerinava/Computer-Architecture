/* 4-bit Carry Look-ahead Adder */
module CLA4(
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
parameter DATA_WIDTH = 4;

// Inputs
input wire [DATA_WIDTH - 1 : 0] lhs, rhs;
input wire cin, inv;

// Outputs
output wire [DATA_WIDTH - 1 : 0] res;
output wire cout, of, p, g;

// Internal Connections
wire p0, p1, p2, p3;
wire g0, g1, g2, g3;
wire c1, c2, c3;

LCU LCU0(
  .c0   (cin),
  .p0   (p0),
  .p1   (p1),
  .p2   (p2),
  .p3   (p3),
  .g0   (g0),
  .g1   (g1),
  .g2   (g2),
  .g3   (g3), 
  .c1   (c1),
  .c2   (c2),
  .c3   (c3),
  .c4   (cout), 
  .p    (p),
  .g    (g)
);

CLA1 CLA1_0(
  .lhs  (lhs [DATA_WIDTH * 1 / 4 - 1 : DATA_WIDTH * 0 / 4]),
  .rhs  (rhs [DATA_WIDTH * 1 / 4 - 1 : DATA_WIDTH * 0 / 4]),
  .cin  (cin),
  .inv  (inv),
  .res  (res [DATA_WIDTH * 1 / 4 - 1 : DATA_WIDTH * 0 / 4]),
  .cout (),
  .of   (),
  .p    (p0),
  .g    (g0)
);

CLA1 CLA1_1(
  .lhs  (lhs [DATA_WIDTH * 2 / 4 - 1 : DATA_WIDTH * 1 / 4]),
  .rhs  (rhs [DATA_WIDTH * 2 / 4 - 1 : DATA_WIDTH * 1 / 4]),
  .cin  (c1),
  .inv  (inv),
  .res  (res [DATA_WIDTH * 2 / 4 - 1 : DATA_WIDTH * 1 / 4]),
  .cout (),
  .of   (),
  .p    (p1),
  .g    (g1)
);

CLA1 CLA1_2(
  .lhs  (lhs [DATA_WIDTH * 3 / 4 - 1 : DATA_WIDTH * 2 / 4]),
  .rhs  (rhs [DATA_WIDTH * 3 / 4 - 1 : DATA_WIDTH * 2 / 4]),
  .cin  (c2),
  .inv  (inv),
  .res  (res [DATA_WIDTH * 3 / 4 - 1 : DATA_WIDTH * 2 / 4]),
  .cout (),
  .of   (),
  .p    (p2),
  .g    (g2)
);

CLA1 CLA1_3(
  .lhs  (lhs [DATA_WIDTH * 4 / 4 - 1 : DATA_WIDTH * 3 / 4]),
  .rhs  (rhs [DATA_WIDTH * 4 / 4 - 1 : DATA_WIDTH * 3 / 4]),
  .cin  (c3),
  .inv  (inv),
  .res  (res [DATA_WIDTH * 4 / 4 - 1 : DATA_WIDTH * 3 / 4]),
  .cout (cout),
  .of   (of),
  .p    (p3),
  .g    (g3)
);

endmodule