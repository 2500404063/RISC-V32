`include "./rtl/mem/rom.v"

module mem_rom2ram_axi (
    input                   rst_n;
    input[31:0]             addr_start,
    input[31:0]             addr_end,
    //sram_axi_master control
    input                   done,
    output reg              en,
    output reg              wen,
    output reg[31:0]        addr,
    output reg[1:0]         size,
    output reg[31:0]        din
);

reg[31:0]       rom_addr;
wire[31:0]      rom_dout;

mem_rom rom(
    .addr(rom_addr),
    .dout(rom_dout)
);

always @(negedge rst_n) begin
    if(!rst_n) begin
        rom_addr <= addr_start;
    end
end

always @(*) begin
    if(done) begin
        en = 1'b0;
    end else begin
        if(rom_addr <= addr_end) begin
            rom_addr = rom_addr + 1'b4;
            addr     = rom_addr;
        end
    end
end

endmodule