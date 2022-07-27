module core_mem_mux (
    //IF
    input                   if_ram_en,
    input[31:0]             if_ram_pc,
    //MEM
    input                   mem_ram_en,
    input                   mem_ram_wen,
    input[31:0]             mem_ram_addr,
    input[1:0]              mem_ram_size,
    input[31:0]             mem_ram_din,
    //ram interface
    output reg              ram_en,
    output reg              ram_wen,
    output reg[31:0]        ram_addr,
    output reg[1:0]         ram_size,
    output reg[31:0]        ram_din
);

always @(*) begin
    //IF
    if (if_ram_en) begin
        ram_en = 1'b1;
        ram_wen = 1'b0;
        ram_addr = if_ram_pc;
        ram_size = 2'b10;
    end else if(mem_ram_en) begin
        //MEM
        ram_en = 1'b1;
        ram_wen = mem_ram_wen;
        ram_addr = mem_ram_addr;
        ram_size = mem_ram_size;
        ram_din = mem_ram_din;
    end else begin
        ram_en = 1'b0;
    end
end

endmodule