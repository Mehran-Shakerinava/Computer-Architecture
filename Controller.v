/* Multi-Cycle RISC Controller */
module Controller(
    clk,
    ir_in,
    ir_out,
    nr_out,
    pr_out,
    zr_out,
    a_en,
    b_en,
    rf_en,
    pc_en,
    ir_en,
    nr_en,
    pr_en,
    zr_en,
    mem_en,
    mdr_en,
    alur_en,
    alu_op,
    mux_pc_in_sel,
    mux_mem_read_addr_sel,
    mux_a_in_sel,
    mux_b_in_sel,
    mux_rf_read_addr1_sel,
    mux_rf_read_addr2_sel,
    mux_rf_write_addr_sel,
    mux_rf_write_data_sel,
    mux_alu_lhs_sel,
    mux_alu_rhs_sel,
    mux_alur_in_sel
);

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

parameter LINK = 11;

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

/* ALU Opcodes */
parameter OP_ADD  = 0;
parameter OP_ADDU = 1;
parameter OP_SUB  = 2;
parameter OP_SUBU = 3;
parameter OP_AND  = 4;
parameter OP_OR   = 5;
parameter OP_XOR  = 6;
parameter OP_NOR  = 7;
parameter OP_SLT  = 8;
parameter OP_SLTU = 9;
parameter OP_NOOP = 10;

/* MUX Sel Codes */
parameter MUX_PC_ADDR = 0;
parameter MUX_PC_RF   = 1;
parameter MUX_PC_ALU  = 2;

parameter MUX_MEM_READ_PC   = 0;
parameter MUX_MEM_READ_ADDR = 1;
parameter MUX_MEM_READ_ALUR = 2;

parameter MUX_A_PC = 0;
parameter MUX_A_RF = 1;

parameter MUX_B_RF    = 0;
parameter MUX_B_VAL   = 1;
parameter MUX_B_INDEX = 2;

parameter MUX_RF_READ1_7  = 0;
parameter MUX_RF_READ1_R2 = 1;
parameter MUX_RF_READ1_R1 = 2;

parameter MUX_RF_READ2_R3 = 0;
parameter MUX_RF_READ2_R2 = 1;
parameter MUX_RF_READ2_R1 = 2;

parameter MUX_RF_ADDR_7  = 0;
parameter MUX_RF_ADDR_R1 = 1;
parameter MUX_RF_ADDR_RF = 2;

parameter MUX_RF_DATA_ADDR = 0;
parameter MUX_RF_DATA_MDR  = 1;
parameter MUX_RF_DATA_ALUR = 2;
parameter MUX_RF_DATA_PC   = 3;

parameter MUX_ALU_LHS_A  = 0;
parameter MUX_ALU_LHS_PC = 1;

parameter MUX_ALU_RHS_2 = 0;
parameter MUX_ALU_RHS_B = 1;

parameter MUX_ALUR_ADDR = 0;
parameter MUX_ALUR_ALU  = 1;

/* Inputs */
input wire [INST_WIDTH - 1 : 0] ir_in, ir_out;
input wire clk, nr_out, pr_out, zr_out;

/* Outputs */
output reg a_en,
           b_en,
           rf_en,
           pc_en,
           ir_en,
           nr_en,
           pr_en,
           zr_en,
           mem_en,
           mdr_en,
           alur_en,
           mux_a_in_sel,
           mux_rf_write_addr_sel,
           mux_alu_lhs_sel,
           mux_alu_rhs_sel,
           mux_alur_in_sel;

output reg [1 : 0] mux_pc_in_sel,
                   mux_mem_read_addr_sel,
                   mux_b_in_sel,
                   mux_rf_read_addr1_sel,
                   mux_rf_read_addr2_sel,
                   mux_rf_write_data_sel;

output reg [ALU_OP_WIDTH - 1 : 0] alu_op;

/* State */
reg [2 : 0] cycle;

/* Internal Variables */
wire [INST_WIDTH - 1 : 0] inst;
wire [OP_WIDTH - 1 : 0] op;
wire link, imm, n, p, z;

assign inst = (cycle == 0 ? ir_in : ir_out);
assign op   = inst[OP_LE : OP_RI];
assign link = inst[LINK];
assign imm  = inst[IMM];
assign n    = inst[N];
assign p    = inst[P];
assign z    = inst[Z];

/* Aliasing */
wire add,
     andu,
     notu,
     ld,
     st,
     ldr,
     str,
     lea,
     jmp,
     jmpr,
     br,
     ret;

assign add  = (op == 4'b0001);
assign andu = (op == 4'b0101);
assign notu = (op == 4'b1001);
assign ld   = (op == 4'b0010);
assign ldr  = (op == 4'b0110);
assign lea  = (op == 4'b1110);
assign st   = (op == 4'b0011);
assign str  = (op == 4'b0111);
assign br   = (op == 4'b0000);
assign jmp  = (op == 4'b0100);
assign jmpr = (op == 4'b1100);
assign ret  = (op == 4'b1101);

wire aluinst;

assign aluinst = (add || andu || notu);

/* Initial State */
initial
begin
    cycle = 0;
end

/* Behavioral Combinational Design */
always @ (*)
begin
    /* Default Control Signals */
    a_en    = 1;
    b_en    = 1;
    rf_en   = 0;
    pc_en   = 0;
    ir_en   = 0;
    nr_en   = 0;
    pr_en   = 0;
    zr_en   = 0;
    mem_en  = 0;
    mdr_en  = 1;
    alur_en = 1;
    
    alu_op = OP_ADD;
    mux_pc_in_sel = MUX_PC_ALU;
    mux_mem_read_addr_sel = MUX_MEM_READ_PC;
    
    mux_a_in_sel = MUX_A_RF;
    mux_b_in_sel = MUX_B_RF;
    
    mux_alu_lhs_sel = MUX_ALU_LHS_A;
    mux_alu_rhs_sel = MUX_ALU_RHS_B;
    mux_alur_in_sel = MUX_ALUR_ALU;
    
    mux_rf_read_addr1_sel = MUX_RF_READ1_R2;
    mux_rf_read_addr2_sel = MUX_RF_READ2_R3;
    mux_rf_write_data_sel = MUX_RF_DATA_ALUR;
    mux_rf_write_addr_sel = MUX_RF_ADDR_R1;
    
    if (cycle == 0)
    begin
        /* Instruction Fetch */
        ir_en = 1;
        
        /* ALUR = PC + 2 */
        mux_alu_lhs_sel = MUX_ALU_LHS_PC;
        mux_alu_rhs_sel = MUX_ALU_RHS_2;

        /* JMP */
        if (jmp)
        begin
            pc_en = 1;
            mux_pc_in_sel = MUX_PC_ADDR;
        end

        /* BR */
        if (br)
        begin
            pc_en = 1;
            if ((n & nr_out) | (p & pr_out) | (z & zr_out))
            begin
                /* Taken */
                mux_pc_in_sel = MUX_PC_ADDR;    
            end
            else
            begin
                /* Not Taken */
                mux_pc_in_sel = MUX_PC_ALU;    
            end
        end
    end
    else if (cycle == 1)
    begin
        /* ALU Instructions */
        if (aluinst && imm)
        begin
            mux_b_in_sel = MUX_B_VAL;
        end
        
        /* LD */
        if (ld)
        begin
            mux_mem_read_addr_sel = MUX_MEM_READ_ADDR;
        end
        
        /* STR */
        if (str)
        begin
            mux_rf_read_addr1_sel = MUX_RF_READ1_R1;
            mux_b_in_sel = MUX_B_INDEX;
        end

        /* ST */
        if (st)
        begin
           mux_rf_read_addr2_sel = MUX_RF_READ2_R1;
        end

        /* LEA */
        if (lea)
        begin
            rf_en = 1;
            mux_rf_write_data_sel = MUX_RF_DATA_ADDR;    
        end
        
        /* PC = PC + 2 */
        if (!jmp && !jmpr)
        begin
            mux_alu_lhs_sel = MUX_ALU_LHS_PC;
            mux_alu_rhs_sel = MUX_ALU_RHS_2;
            pc_en = 1;
        end

        /* LINK */
        if ((jmp || jmpr) && link)
        begin
            rf_en = 1;
            mux_rf_write_addr_sel = MUX_RF_ADDR_7;
            mux_rf_write_data_sel = MUX_RF_DATA_ALUR;
        end

        /* ALUR = ADDR */
        alur_en = 1;
        mux_alur_in_sel = MUX_ALUR_ADDR;

        /* RET */
        if (ret)
        begin
            pc_en = 1;
            mux_pc_in_sel = MUX_PC_RF;
            mux_rf_read_addr1_sel = MUX_RF_READ1_7;
        end

        /* LDR/STR/JMPR */
        if (ldr || jmpr)
        begin
            mux_b_in_sel = MUX_B_INDEX;
        end
    end
    else if (cycle == 2)
    begin
        /* ADD/AND/NOT */
        if (aluinst)
        begin
            nr_en = 1;
            pr_en = 1;
            zr_en = 1;
            alur_en = 1;
        end

        /* ADD */
        if (add)
        begin
            alu_op = OP_ADD;
        end
        
        /* NOT */
        if (notu)
        begin
            /* nice! */
            alu_op = OP_XOR;
        end
        
        /* AND */
        if (andu)
        begin
            alu_op = OP_AND;
        end

        /* JMPR */
        if (jmpr)
        begin
            alu_op = OP_ADD;
            mux_pc_in_sel = MUX_PC_ALU;
            pc_en = 1;
        end

        /* LD */
        if (ld)
        begin
            rf_en = 1;
            mux_rf_write_addr_sel = MUX_RF_ADDR_R1;
            mux_rf_write_data_sel = MUX_RF_DATA_MDR;
        end

        /* ST */
        if (st)
        begin
            mem_en = 1;
        end

        /* STR */
        if (str)
        begin
            mux_rf_read_addr2_sel = MUX_RF_READ2_R2;
        end
    end
    else if (cycle == 3)
    begin
        if (ldr)
        begin
            mux_mem_read_addr_sel = MUX_MEM_READ_ALUR;
            mdr_en = 1;
        end
        else if (str)
        begin
            mem_en = 1;
        end
        else
        begin
            rf_en = 1;
        end
    end
    else if (cycle == 4)
    begin
        /* LDR */
        rf_en = 1;
        mux_rf_write_addr_sel = MUX_RF_ADDR_R1;
        mux_rf_write_data_sel = MUX_RF_DATA_MDR;
    end
end

/* Behavioral Sequential Design */
always @(posedge clk)
begin
    if ((cycle == 0 && (br   || (jmp && !link)))
     || (cycle == 1 && (jmp  || ret || lea))
     || (cycle == 2 && (jmpr || ld  || st))
     || (cycle == 3 && (str  || aluinst ))
     || (cycle == 4 && (ldr)))
    begin
        cycle = 0;
    end
    else
    begin
        cycle = cycle + 1;
    end
end

endmodule