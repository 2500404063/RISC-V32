//ROM: 64KB
module mem_rom (
    input[31:0]      addr,
    output reg[31:0] dout
);

reg[31:0]           rom[16383:0]
wire[16383:0]       real_index; 
assign              real_index  =  addr / 4;

initial begin
    $readmemh("./program.bin",rom,0,9);
end

always @(*) begin
    dout <= rom[real_index]
end
endmodule