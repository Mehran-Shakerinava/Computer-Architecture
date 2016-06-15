/**********************************
 *                                *
 *  @Date   "5/16/2016"           *
 *  @Design "Multi Cycle CPU"     *
 *  @Author "Mehran Shakerinava"  *
 *  @Lang   "Verilog"             *
 *                                *
 **********************************/
module MultiCycleCPU;

/**** Parameters ****/

/* ALU */
parameter ALU_OP_WIDTH = 4;

/* 16-bit Architecture */
parameter MEM_ADDR_WIDTH = 16;

/* RISC ISA */
parameter REG_DATA_WIDTH = 16;
parameter REG_ADDR_WIDTH = 3;

parameter INST_WIDTH = 16;

parameter OP_LE = 15;
parameter OP_RI = 12;

parameter R1_LE = 11;
parameter R1_RI = 9;

parameter R2_LE = 8;
parameter R2_RI = 6;

parameter R3_LE = 2;
parameter R3_RI = 0;

parameter IMM = 5;

parameter VALUE_LE = 4;
parameter VALUE_RI = 0;

parameter INDEX_LE = 5;
parameter INDEX_RI = 0;

parameter N = 11;
parameter Z = 10;
parameter P = 9;

parameter OFFSET_LE = 8;
parameter OFFSET_RI = 0;

parameter OP_WIDTH = OP_LE - OP_RI + 1;
parameter VALUE_WIDTH = VALUE_LE - VALUE_RI + 1;
parameter INDEX_WIDTH = INDEX_LE - INDEX_RI + 1;
parameter OFFSET_WIDTH = OFFSET_LE - OFFSET_RI + 1;

/**** Clock ****/

reg clk;

initial
begin
  clk = 1'b0;
end

always
begin
    #5 clk = ~clk;
end

/**** Cycle #1 ****/

/* PC */
wire [MEM_ADDR_WIDTH - 1 : 0] pc_in, pc_out;
wire pc_en;

Register16 pc(
    .in  (pc_in),
    .out (pc_out),
    .clk (clk),
    .rst (1'b0),
    .en  (pc_en)
);

/* RAM */
wire [MEM_ADDR_WIDTH - 1 : 0] mem_read_addr, mem_write_addr;
wire [REG_DATA_WIDTH - 1 : 0] mem_read_data, mem_write_data;
wire mem_en;

RAM16 mem(
    .read_addr  (mem_read_addr),
    .read_data  (mem_read_data),
    .write_addr (mem_write_addr),
    .write_data (mem_write_data),
    .clk        (clk),
    .en         (mem_en)
);

/* IR */
wire [INST_WIDTH - 1 : 0] ir_in, ir_out;
wire ir_en;

Register16 ir(
    .in  (ir_in),
    .out (ir_out),
    .clk (clk),
    .rst (1'b0),
    .en  (ir_en)
);

/* Instruction Fetch */
// buf (mem_read_addr, pc_out);
buf buf_ir_in [INST_WIDTH - 1 : 0] (ir_in, mem_read_data);

/* Address */
wire [MEM_ADDR_WIDTH - 1 : 0] addr;

// buf buf_addr0 [OFFSET_WIDTH - 1 : 0] (addr[OFFSET_WIDTH - 1 : 0], ir_out[OFFSET_LE : OFFSET_RI]);
// buf buf_addr1 [MEM_ADDR_WIDTH - OFFSET_WIDTH - 1 : 0] (addr[MEM_ADDR_WIDTH - 1 : OFFSET_WIDTH], pc_out[MEM_ADDR_WIDTH - 1 : OFFSET_WIDTH]);

wire [INST_WIDTH - 1 : 0] inst;
assign inst = (ctrl.cycle == 0 ? ir_in : ir_out);

assign addr = {pc_out[MEM_ADDR_WIDTH - 1 : OFFSET_WIDTH], inst[OFFSET_LE : OFFSET_RI]};

/* A */
wire [REG_DATA_WIDTH - 1 : 0] a_in, a_out;
wire a_en;

Register16 a(
    .in  (a_in),
    .out (a_out),
    .clk (clk),
    .rst (1'b0),
    .en  (a_en)
);

/* JMP */
// buf (pc_in, addr);
// buf (a_in, pc_out)

/**** Cycle #2 ****/

/* Instruction Decode */
wire [REG_ADDR_WIDTH - 1 : 0] r1, r2, r3;

buf buf_r1 [REG_ADDR_WIDTH - 1 : 0] (r1, ir_out[R1_LE : R1_RI]);
buf buf_r2 [REG_ADDR_WIDTH - 1 : 0] (r2, ir_out[R2_LE : R2_RI]);
buf buf_r3 [REG_ADDR_WIDTH - 1 : 0] (r3, ir_out[R3_LE : R3_RI]);

/* B */
wire [REG_DATA_WIDTH - 1 : 0] b_in, b_out;
wire b_en;

Register16 b(
    .in  (b_in),
    .out (b_out),
    .clk (clk),
    .rst (1'b0),
    .en  (b_en)
);

/* Register File */
wire [REG_ADDR_WIDTH - 1 : 0] rf_read_addr1, rf_read_addr2, rf_write_addr;
wire [REG_DATA_WIDTH - 1 : 0] rf_read_data1, rf_read_data2, rf_write_data;
wire rf_en;

RegisterFile8x16 rf(
    .read_addr1 (rf_read_addr1),
    .read_addr2 (rf_read_addr2),
    .read_data1 (rf_read_data1),
    .read_data2 (rf_read_data2),
    .write_addr (rf_write_addr),
    .write_data (rf_write_data),
    .write_en   (rf_en),
    .clk        (clk)
);

/* ADD/AND */
// buf (rf_read_addr1, r2);
// buf (a_in, rf_read_data1);

// buf (rf_read_addr2, r3);
// buf (b_in, rf_read_data2);

/* MDR */
wire [REG_DATA_WIDTH - 1 : 0] mdr_in, mdr_out;
wire mdr_en;

Register16 mdr(
    .in  (mdr_in),
    .out (mdr_out),
    .clk (clk),
    .rst (1'b0),
    .en  (mdr_en)
);

/* LD */
// buf (mem_read_addr, addr);
buf buf_mdr_in [REG_DATA_WIDTH - 1 : 0] (mdr_in, mem_read_data);

/* LEA */
// buf (rf_write_addr, r1);
// buf (rf_write_data, addr);

/* ALU */
wire [REG_DATA_WIDTH - 1 : 0] alu_lhs, alu_rhs, alu_out;
wire [ALU_OP_WIDTH - 1 : 0] alu_op;
wire alu_n, alu_p, alu_z;

ALU16 alu(
    .lhs    (alu_lhs),
    .rhs    (alu_rhs),
    .result (alu_out),
    .n      (alu_n),
    .p      (alu_p),
    .z      (alu_z),
    .op     (alu_op)
);

/* PC Increment */
// buf (alu_lhs, pc_out);
// buf (alu_rhs, 16'b10);

/* Sign Extend 5 x 16 */
wire [VALUE_WIDTH - 1 : 0] se5_in;
wire [REG_DATA_WIDTH - 1 : 0] se5_out;

SignExtend5x16 se5(
    .in  (se5_in),
    .out (se5_out)
);

/* Sign Extend 6 x 16 */
wire [INDEX_WIDTH - 1 : 0] se6_in;
wire [REG_DATA_WIDTH - 1 : 0] se6_out;

SignExtend6x16 se6(
    .in  (se6_in),
    .out (se6_out)
);

/* Immediate */
wire [VALUE_WIDTH - 1 : 0] value;
wire [INDEX_WIDTH - 1 : 0] index;

buf buf_value [VALUE_WIDTH - 1 : 0] (value, ir_out[VALUE_LE : VALUE_RI]);
buf buf_index [INDEX_WIDTH - 1 : 0] (index, ir_out[INDEX_LE : INDEX_RI]);

wire [REG_DATA_WIDTH - 1 : 0] value_ext,
                              index_ext;

buf buf_se5_in [VALUE_WIDTH - 1 : 0] (se5_in, value);
buf buf_value_ext [REG_DATA_WIDTH - 1 : 0] (value_ext, se5_out);

buf buf_se6_in [INDEX_WIDTH - 1 : 0] (se6_in, index);
buf buf_index_ext [REG_DATA_WIDTH - 1 : 0] (index_ext, se6_out);

// buf (b_in, value_ext);
// buf (b_in, index_ext);

/* ALU Out */
wire [REG_DATA_WIDTH - 1 : 0] alur_in, alur_out;
wire alur_en;

Register16 alur(
    .in  (alur_in),
    .out (alur_out),
    .clk (clk),
    .rst (1'b0),
    .en  (alur_en)
);

/* ST */
// buf (rf_read_addr2, r1);
// buf (b_in, rf_read_data2);
// buf (alur_in, addr);

/* RET */
// buf (rf_read_addr1, 3'b111);
// buf (pc_in, rf_read_data1);

/* Link */
// buf (alu_lhs, a_out);
// buf (alu_rhs, 16'b10);
// buf (alur_in, alu_out);

/* N */
wire nr_in, nr_out, nr_en;

Register nr(
    .in  (nr_in),
    .out (nr_out),
    .clk (clk),
    .rst (1'b0),
    .en  (nr_en)
);

/* P */
wire pr_in, pr_out, pr_en;

Register pr(
    .in  (pr_in),
    .out (pr_out),
    .clk (clk),
    .rst (1'b0),
    .en  (pr_en)
);

/* Z */
wire zr_in, zr_out, zr_en;

Register zr(
    .in  (zr_in),
    .out (zr_out),
    .clk (clk),
    .rst (1'b0),
    .en  (zr_en)
);

/* Condition */
// wire n, z, p;

// buf (n, ir_out[N]);
// buf (z, ir_out[Z]);
// buf (p, ir_out[P]);

/* BR */
// buf (pc_in, addr);

/**** Cycle #3 ****/

/* ADD/AND/NOT */
// buf (alu_lhs, a_out);
// buf (alu_rhs, b_out);
// buf (alur, alu_out);
buf buf_nr_in (nr_in, alu_n);
buf buf_pr_in (pr_in, alu_p);
buf buf_zr_in (zr_in, alu_z);

/* JMPR */
// buf (pc_in, alu_out);

/* LD */
// buf (rf_write_addr, r1);
// buf (rf_write_data, mdr_out);

/* ST */
buf buf_mem_write_addr [MEM_ADDR_WIDTH - 1 : 0] (mem_write_addr, alur_out);
buf buf_mem_write_data [REG_DATA_WIDTH - 1 : 0] (mem_write_data, b_out);

/* STR */
// buf (rf_read_addr2, r2);
// buf (b_in, rf_read_data2);

/* Link */
// buf (rf_write_addr, 3'b111);
// buf (rf_write_data, alur_out);

/**** Cycle #4 ****/

/* ADD/AND/NOT */
// buf (rf_write_addr, r1);
// buf (rf_write_data, alur_out);

/* LDR */
// buf (mem_read_addr, alur_out);
// buf (mdr_in, mem_read_data);

/* STR */
// buf (mem_write_addr, alur_out);
// buf (mem_write_data, b_out);

/**** Cycle #5 ****/

/* LDR */
// buf (rf_write_addr, r1);
// buf (rf_write_data, mdr_out);

/**** Controller ****/

wire mux_a_in_sel,
     mux_rf_write_addr_sel,
     mux_alu_lhs_sel,
     mux_alu_rhs_sel,
     mux_alur_in_sel;

wire [1 : 0] mux_pc_in_sel,
             mux_mem_read_addr_sel,
             mux_b_in_sel,
             mux_rf_read_addr1_sel,
             mux_rf_read_addr2_sel,
             mux_rf_write_data_sel;

Controller ctrl(
    .clk                   (clk),
    .ir_in                 (ir_in),
    .ir_out                (ir_out),
    .nr_out                (nr_out),
    .pr_out                (pr_out),
    .zr_out                (zr_out),
    .a_en                  (a_en),
    .b_en                  (b_en),
    .rf_en                 (rf_en),
    .pc_en                 (pc_en),
    .ir_en                 (ir_en),
    .nr_en                 (nr_en),
    .pr_en                 (pr_en),
    .zr_en                 (zr_en),
    .mem_en                (mem_en),
    .mdr_en                (mdr_en),
    .alur_en               (alur_en),
    .alu_op                (alu_op),
    .mux_pc_in_sel         (mux_pc_in_sel),
    .mux_mem_read_addr_sel (mux_mem_read_addr_sel),
    .mux_a_in_sel          (mux_a_in_sel),
    .mux_b_in_sel          (mux_b_in_sel),
    .mux_rf_read_addr1_sel (mux_rf_read_addr1_sel),
    .mux_rf_read_addr2_sel (mux_rf_read_addr2_sel),
    .mux_rf_write_addr_sel (mux_rf_write_addr_sel),
    .mux_rf_write_data_sel (mux_rf_write_data_sel),
    .mux_alu_lhs_sel       (mux_alu_lhs_sel),
    .mux_alu_rhs_sel       (mux_alu_rhs_sel),
    .mux_alur_in_sel       (mux_alur_in_sel)
);

/**** Multiplexors ****/

Mux4x16 mux_pc_in(
    .in0 (addr),
    .in1 (rf_read_data1),
    .in2 (alu_out),
    .in3 (16'bx),
    .out (pc_in),
    .sel (mux_pc_in_sel)
);

Mux4x16 mux_mem_read_addr(
    .in0 (pc_out),
    .in1 (addr),
    .in2 (alur_out),
    .in3 (16'bx),
    .out (mem_read_addr),
    .sel (mux_mem_read_addr_sel)
);

Mux2x16 mux_a_in(
    .in0 (pc_out),
    .in1 (rf_read_data1),
    .out (a_in),
    .sel (mux_a_in_sel)
);

Mux4x16 mux_b_in(
    .in0 (rf_read_data2),
    .in1 (value_ext),
    .in2 (index_ext),
    .in3 (16'bx),
    .out (b_in),
    .sel (mux_b_in_sel)
);

Mux4x3 mux_rf_read_addr1(
    .in0 (3'b111),
    .in1 (r2),
    .in2 (r1),
    .in3 (3'bx),
    .out (rf_read_addr1),
    .sel (mux_rf_read_addr1_sel)
);

Mux4x3 mux_rf_read_addr2(
    .in0 (r3),
    .in1 (r2),
    .in2 (r1),
    .in3 (3'bx),
    .out (rf_read_addr2),
    .sel (mux_rf_read_addr2_sel)
);

Mux2x3 mux_rf_write_addr(
    .in0 (3'b111),
    .in1 (r1),
    .out (rf_write_addr),
    .sel (mux_rf_write_addr_sel)
);

Mux4x16 mux_rf_write_data(
    .in0 (addr),
    .in1 (mdr_out),
    .in2 (alur_out),
    .in3 (pc_out),
    .out (rf_write_data),
    .sel (mux_rf_write_data_sel)
);

Mux2x16 mux_alu_lhs(
    .in0 (a_out),
    .in1 (pc_out),
    .out (alu_lhs),
    .sel (mux_alu_lhs_sel)
);

Mux2x16 mux_alu_rhs(
    .in0 (16'b10),
    .in1 (b_out),
    .out (alu_rhs),
    .sel (mux_alu_rhs_sel)
);

Mux2x16 mux_alur_in(
    .in0 (addr),
    .in1 (alu_out),
    .out (alur_in),
    .sel (mux_alur_in_sel)
);

endmodule