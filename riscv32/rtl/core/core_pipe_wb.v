/**
 * Author: Felix
 * Description: Pipe WB(Write Back)  (the 1st pipe)
 * 
*/

module core_pipe_wb (
    input               clk,
    input               rst_n,
    output reg          wb_allowin,
    output reg          wb_validout,
    input               if_allowin,
    input               mem_validout,
    //regs
    input[4:0]          mem_rd,
    input[4:0]          mem_rs1,
    input[4:0]          mem_rs2,
    //memory
    input               mem_write_rd,
    input[31:0]         ram_dout,
    //transfer
    input[31:0]         mem_result_pc,
    input               mem_result_jmp,
    input               mem_result_link,
    input[31:0]         mem_result_link_addr,
    //Computational
    input[31:0]         mem_result_value,
    input               mem_result_computed,
    //registers control
    input               wb_reg_done,
    output reg          wb_reg_wen,
    output reg[4:0]     wb_rd_addr,
    output reg[31:0]    wb_rd_din,
    //PC control
    input               pc_done,
    input[31:0]         pc_pcout,
    output reg          wb_pc_wen,
    output reg[31:0]    wb_pcin
);

always @(*) begin
    if (wb_reg_wen & wb_reg_done) begin
        wb_reg_wen = 1'b0;
    end
end

always @(*) begin
    if (wb_pc_wen & pc_done) begin
        wb_pc_wen  = 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wb_allowin      <= 1'b1;
        wb_validout     <= 1'b0;
        wb_pc_wen       <= 1'b0;
        wb_reg_wen      <= 1'b0;
        wb_rd_addr      <= 5'd0;
    end else begin
        if (mem_validout & if_allowin) begin
            wb_validout     <= 1'b1;
            //Whether WB needs to write data read from MEM back into rd.
            if (mem_write_rd) begin
                wb_reg_wen  <= 1'b1;
                wb_rd_addr  <= mem_rd;
                wb_rd_din   <= ram_dout;
            end

            //Whether WB needs jump to a new PC.
            wb_pc_wen  <= 1'b1;
            if (mem_result_jmp) begin
                wb_pcin    <= mem_result_pc;
            end else begin
                //If not, the PC will be updated by adding four.
                //Please note that pc_pcout is always readable.
                //And, PC is updated async.
                wb_pcin    <= pc_pcout + 3'd4;
            end

            if (mem_result_link) begin
                wb_reg_wen  <= 1'b1;
                wb_rd_addr  <= mem_rd;
                wb_rd_din   <= pc_pcout + 3'd4;
            end

            if (mem_result_computed) begin
                wb_reg_wen  <= 1'b1;
                wb_rd_addr  <= mem_rd;
                wb_rd_din   <= mem_result_value;
            end
        end
    end
end

endmodule