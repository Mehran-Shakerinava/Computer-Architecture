module Register16(
    in,
    out,
    clk,
    rst,
    en
);

/* Parameters */
parameter DATA_WIDTH = 16;

/* Inputs */
input wire [DATA_WIDTH - 1 : 0] in;
input wire clk, rst, en;

/* Outputs */
output reg [DATA_WIDTH - 1 : 0] out;

/* Initialize */
initial
begin
    out = 0;
end

/* Behavioral Sequential Design */
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        out <= 0;
    end
    else if (en)
    begin
        out <= in;
    end
end

endmodule