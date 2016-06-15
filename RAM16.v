/* 16-bit RAM */ 
module RAM16(
    read_addr,
    read_data,
    write_addr,
    write_data,
    en,
    clk
);

/* Parameters */
parameter BYTE_WIDTH = 8;
parameter WORD_WIDTH = 16;
parameter ADDR_WIDTH = 16;
parameter RAM_DEPTH  = 1 << ADDR_WIDTH;
parameter BUS_BYTE_SIZE = WORD_WIDTH / BYTE_WIDTH;

/* Inputs */
input wire [ADDR_WIDTH - 1 : 0] read_addr, write_addr;
input wire [WORD_WIDTH - 1 : 0] write_data;
input wire clk, en;

/* Outputs */
output wire [WORD_WIDTH - 1 : 0] read_data;

/* Internal Variables */
reg [BYTE_WIDTH - 1 : 0] mem [0 : RAM_DEPTH - 1];
integer i = 0;

initial
begin
    /* Initialize */
    for (i = 0; i < RAM_DEPTH; i = i + 1)
    begin
        mem[i] = 0;
    end

    /* Load Code */
    $readmemh("code.txt", mem);

    /* Wait */
    #10000000;
    
    /* Display */
    $display(" === MEMORY === ");
    for (i = 0; i < RAM_DEPTH; i = i + 1)
    begin
        $display("MEM[%4d] = %d", i, mem[i]);
    end
end

/* Read */
assign read_data = {mem[read_addr + 0], mem[read_addr + 1]};

/* Write */
always @(posedge clk)
begin
    if (en)
    begin
        /* TOASK : Why do I have to write it like this? */
        {mem[write_addr + 0], mem[write_addr + 1]} = write_data;
    end
end

endmodule