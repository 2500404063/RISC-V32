module core_reg_pc (
    input               rst_n,
    input               wen,
    input[31:0]         pcin,
    output[31:0]        pcout,
    output reg          done
);

reg[31:0]   pc;

always @(negedge rst_n) begin
    if(!rst_n) begin
        // pc      <= 32'd4294967292;
        pc      <= 32'd0;
    end
end

assign      pcout   =   pc;

always @(*) begin
    if (wen) begin
        pc      = pcin;
        done    = 1'b1;
    end else begin
        done    = 1'b0;
    end
end

endmodule