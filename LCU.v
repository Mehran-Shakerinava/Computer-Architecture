/* Lookahead Carry Unit (LCU) */
module LCU(
  input wire c0,
  
  input wire p0,
  input wire p1,
  input wire p2,
  input wire p3,
  
  input wire g0,
  input wire g1,
  input wire g2,
  input wire g3,
  
  output wire c1,
  output wire c2,
  output wire c3,
  output wire c4,
  
  output wire p,
  output wire g
);

// Internal Connections
wire c0p0, c0p0p1, c0p0p1p2, c0p0p1p2p3;
wire g0p1, g0p1p2, g0p1p2p3;
wire g1p2, g1p2p3;
wire g2p3;

// Gate-level Combinational Logic Design
and #(1) and0 (c0p0, c0, p0);
and #(1) and1 (c0p0p1, c0, p0, p1);
and #(1) and2 (c0p0p1p2, c0, p0, p1, p2);
and #(1) and3 (c0p0p1p2p3, c0, p0, p1, p2, p3);

and #(1) and4 (g0p1, g0, p1);
and #(1) and5 (g0p1p2, g0, p1, p2);
and #(1) and6 (g0p1p2p3, g0, p1, p2, p3);

and #(1) and7 (g1p2, g1, p2);
and #(1) and8 (g1p2p3, g1, p2, p3);

and #(1) and9 (g2p3, g2, p3);

or  #(1) or0  (c1, g0, c0p0);
or  #(1) or1  (c2, g1, g0p1, c0p0p1);
or  #(1) or2  (c3, g2, g1p2, g0p1p2, c0p0p1p2);
or  #(1) or3  (c4, g3, g2p3, g1p2p3, g0p1p2p3, c0p0p1p2p3);

and #(1) andA (p, p0, p1, p2, p3);
or  #(1) or4  (g, g3, g2p3, g1p2p3, g0p1p2p3);

endmodule