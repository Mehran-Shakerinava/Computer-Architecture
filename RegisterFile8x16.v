/* 8 x 16-bit RISC Register File */
module RegisterFile8x16(
    read_addr1,
    read_addr2,
    read_data1,
    read_data2,
    write_addr,
    write_data,
    write_en,
    clk
);

/* Parameters */
parameter DATA_WIDTH = 16;
parameter ADDRESS_WIDTH = 3;
parameter RAM_DEPTH = 1 << ADDRESS_WIDTH;

/* Inputs */
input [ADDRESS_WIDTH - 1 : 0] read_addr1, read_addr2, write_addr;
input [DATA_WIDTH - 1 : 0] write_data;
input clk, write_en;

/* Outputs */
output [DATA_WIDTH - 1 : 0] read_data1, read_data2;

/* Internal variables */
reg [DATA_WIDTH - 1 : 0] register [RAM_DEPTH - 1 : 0];
integer i = 0;

initial
begin
    /* Initialize */
    for (i = 0; i < RAM_DEPTH; i = i + 1)
    begin
        register[i] = 0;
    end
    
    /* Wait */
    #10000000;
    
    /* Display */
    $display(" === REGISTERS === ");
    for (i = 0; i < RAM_DEPTH; i = i + 1)
    begin
        $display("REG[%2d] = %d", i, register[i]);
    end
end

/* Read */
assign read_data1 = register[read_addr1];
assign read_data2 = register[read_addr2];

/* Write */
always @(posedge clk)
begin
    if (write_en)
    begin
        register[write_addr] <= write_data;
    end
end

endmodule