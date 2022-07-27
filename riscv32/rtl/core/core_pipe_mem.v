/**
 * Author: Felix
 * Description: Pipe MEM(Momory)  (the 4th pipe)
*/

module core_pipe_mem (
    input               clk,
    input               rst_n,
    output reg          mem_validout,
    output reg          mem_allowin,
    input               ie_validout,
    input               wb_allowin,
    //reg
    input[4:0]          ie_rd,
    input[4:0]          ie_rs1,
    input[4:0]          ie_rs2,
    //results
    //Memory Instruction
    input[1:0]          ie_result_mem_size,
    input               ie_result_mem_load,
    input               ie_result_mem_store,
    input[31:0]         ie_result_mem_addr,
    input[31:0]         ie_result_mem_din,
    //Transfer Control
    input[31:0]         ie_result_pc,
    input               ie_result_jmp,
    input               ie_result_link,
    input[31:0]         ie_result_link_addr,
    //Computational
    input[31:0]         ie_result_value,
    input               ie_result_computed,
    //keep for wb
    //regs
    output reg[4:0]     mem_rd,
    output reg[4:0]     mem_rs1,
    output reg[4:0]     mem_rs2,
    //memory read
    output reg          mem_result_mem_load,
    output reg          mem_write_rd,
    //Transfer Control
    output reg[31:0]    mem_result_pc,
    output reg          mem_result_jmp,
    output reg          mem_result_link,
    output reg[31:0]    mem_result_link_addr,
    //Computational
    output reg[31:0]    mem_result_value,
    output reg          mem_result_computed,
    //ram control
    input               ram_done,
    input[31:0]         ram_dout,
    output reg          mem_ram_en,
    output reg          mem_ram_wen,
    output reg[31:0]    mem_ram_addr,
    output reg[1:0]     mem_ram_size,
    output reg[31:0]    mem_ram_din
);

reg         reg_useless;

always @(*) begin
    if (ram_done) begin
        mem_ram_en  =   1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_allowin     <= 1'b1;
        mem_validout    <= 1'b0;
        mem_write_rd    <= 1'b0;
        mem_ram_en      <= 1'b0;
        mem_ram_addr    <= 32'd0;
        mem_ram_size    <= 2'd0;
        mem_ram_wen     <= 1'b0;
        mem_result_mem_load <= 1'b0;
        mem_result_computed <= 1'b0;
    end else begin
        if (ie_validout & wb_allowin) begin
            mem_allowin     <= 1'b1;
            mem_validout    <= 1'b1;
            //mem
            mem_result_mem_load             <= ie_result_mem_load;
            //regs
            mem_rd                          <= ie_rd;
            mem_rs1                         <= ie_rs1;
            mem_rs2                         <= ie_rs2;
            //transfer
            mem_result_pc                   <= ie_result_pc;
            mem_result_jmp                  <= ie_result_jmp;
            mem_result_link                 <= ie_result_link;
            mem_result_link_addr            <= ie_result_link_addr;
            //computational
            mem_result_value                <= ie_result_value;
            mem_result_computed             <= ie_result_computed;
            if (ie_result_mem_load) begin
                mem_write_rd    <= 1'b1;
                mem_ram_en      <= 1'b1;
                mem_ram_wen     <= 1'b0;
                mem_ram_addr    <= ie_result_mem_addr;
                mem_ram_size    <= ie_result_mem_size;
            end else if(ie_result_mem_store) begin
                mem_ram_en      <= 1'b1;
                mem_ram_wen     <= 1'b1;
                mem_ram_addr    <= ie_result_mem_addr;
                mem_ram_size    <= ie_result_mem_size;
                mem_ram_din     <= ie_result_mem_din;
            end else begin
                mem_ram_en      <= 1'b0;
            end
        end else begin
            mem_validout    <= 1'b0;
        end
    end
end

endmodule
