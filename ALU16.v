/* RISC 16-bit ALU */
module ALU16(
    lhs,
    rhs,
    result,
    n,
    p,
    z,
    op
);

/* Parameters */
parameter DATA_WIDTH = 16;
parameter OP_WIDTH   = 4;

/* Opcodes */
parameter OP_ADD  = 4'b0000;  //0
parameter OP_ADDU = 4'b0001;  //1
parameter OP_SUB  = 4'b0010;  //2
parameter OP_SUBU = 4'b0011;  //3
parameter OP_AND  = 4'b0100;  //4
parameter OP_OR   = 4'b0101;  //5
parameter OP_XOR  = 4'b0110;  //6
parameter OP_NOR  = 4'b0111;  //7
parameter OP_SLT  = 4'b1000;  //8
parameter OP_SLTU = 4'b1001;  //9    

/* Inputs */
input [OP_WIDTH - 1 : 0] op;
input [DATA_WIDTH - 1 : 0] lhs, rhs;

/* Outputs */
output reg [DATA_WIDTH - 1 : 0] result;
output wire n, p, z;

/* Behavioral Combinational Design */
always @ (lhs or rhs or op)
begin
    case (op)
        OP_ADD  : result = $signed(lhs) + $signed(rhs);
        OP_SUB  : result = $signed(lhs) - $signed(rhs);
        OP_ADDU : result = lhs + rhs;
        OP_SUBU : result = lhs - rhs;
        OP_AND  : result = lhs & rhs;
        OP_OR   : result = lhs | rhs;
        OP_XOR  : result = lhs ^ rhs;
        OP_NOR  : result = ~(lhs | rhs);
        OP_SLT  : result = $signed(lhs) < $signed(rhs) ? 1 : 0; 
        OP_SLTU : result = lhs < rhs ? 1 : 0;
        default : result = 0;
    endcase
end

/* N/P/Z */
assign p = (!n && !z);
assign z = (result == 0);
assign n = (result[DATA_WIDTH - 1]);

endmodule