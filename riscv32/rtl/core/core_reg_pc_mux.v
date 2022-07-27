module core_reg_pc_mux (
    //IF
    input               if_pc_en,
    //PC Control
    output reg          pc_en,
    output reg          pc_wen,
    output reg[31:0]    pc_pcin
);

always @(*) begin
    if(if_pc_en) begin
        pc_en   =   1'b1;
        pc_wen  =   1'b0;
    end else begin
        pc_en   =   1'b0;
    end
end

endmodule