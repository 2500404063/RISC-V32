module core_reg_arr (
    input           rst_n,
    input           wen,
    input[4:0]      rs1_addr,
    input[4:0]      rs2_addr,
    input[4:0]      rd_addr,
    input[31:0]     rd_din,
    output[31:0]    rs1_dout,
    output[31:0]    rs2_dout,
    output reg      done,
    output[31:0]    test1,
    output[31:0]    test2,
    output[31:0]    test3
);

reg[31:0]   reg_array[31:0];

assign test1 = reg_array[1];
assign test2 = reg_array[2];
assign test3 = reg_array[3];

initial begin
    reg_array[0] = 32'd0;
end

always @(*) begin
    if(wen) begin
        if (rd_addr == 5'd0) begin
            reg_array[rd_addr]  = 32'd0;
        end else begin
            reg_array[rd_addr]  = rd_din;
        end
        done    = 1'b1;
    end else begin
        done    = 1'b0;
    end
end

assign  rs1_dout    =   reg_array[rs1_addr];
assign  rs2_dout    =   reg_array[rs2_addr];

endmodule