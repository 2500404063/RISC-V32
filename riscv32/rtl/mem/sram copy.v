module mem_sram_8k #(
    parameter           sel = 8'd0
)(
    //control
    input               clk,
    input               rst_n,
    input               en,
    input               wen,
    input[2:0]          cs,
    input[10:0]         addr,
    input[1:0]          size,
    input[31:0]         din,
    //output
    output reg[31:0]    dout
);

//8KB, Address=[0000H, 3200H]
reg[31:0]       sram[2047:0];
reg[10:0]       real_index;

initial begin
    $readmemh("./program.bin",sram,0,9);
end

//Async Write
always @(posedge clk) begin
    if (clk) begin
        if (en) begin
            if (cs == sel) begin
                if (wen) begin
                    case (size)
                        2'b00: sram[addr][7:0]  <= din[7:0];    //1 Byte
                        2'b01: sram[addr][15:0] <= din[15:0];   //2 Bytes
                        2'b10: sram[addr] <= din;               //4 Bytes
                        default: sram[addr][23:0] <= din[31:0]; //4 Bytes
                    endcase
                end
            end
        end
    end
end

//Reuse
wire gnd;
assign gnd = 1'b0;

//Sync Read
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dout <= {32{gnd}};
    end else begin
        if (en) begin
            if (cs == sel) begin
                if (~wen) begin
                    case (size)
                        2'b00: dout <= {{24{gnd}},sram[addr][7:0]};
                        2'b01: dout <= {{16{gnd}},sram[addr][15:0]};
                        2'b10: dout <= sram[addr];
                        default: dout <= sram[addr];
                    endcase
                end
            end
        end
    end
end

endmodule