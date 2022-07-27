/******************************************************************************************************************
 * Author: Felix
 * Description: Pipe IF(Instruction Fetch)  (the 1st pipe)
 * Note: At this first stage, we met two problems.
         The First:
         the pc must be latest, otherwise the instruction will be wrong.
         The first time getting the latest PC is at IE stage which figures out whether to jump.
         Thus, the IF to fetch instruction must depend on IE, to ensure that every Instruction is useful.
         (but when cpu with cache, the IF will be different. It tolerates fetching some useless instructions.)
         
         The Second:
         MEM period uses ram as well, and pipes are working at the same time,
         however, ram has only one interface to read and write, which means
         while MEM is reading or writing, IF cannot read RAM.
         but pay attention that, IF should pause before entering MEM, and continue after the end of MEM.

         Oh, these two damn problems bothered me much at the first time to design a CPU.
         Here, I wanna say, anything can be constrained, just make a rule and let everyone keep.
*******************************************************************************************************************/

module core_pipe_if (
    //control
    input               clk,
    input               rst_n,
    input               wb_validout,
    input               mem_allowin,
    output reg          if_validout,
    output reg          if_allowin,
    //Get the lastest PC from IE
    input               ie_result_jmp,
    input[31:0]         ie_result_pc,
    //Get whether to pause for MEM
    input               ie_result_mem_load,
    input               ie_result_mem_store,
    //PC
    input[31:0]         pc_pcout,
    //RAM
    input               ram_done,
    output reg          if_ram_en,
    output reg[31:0]    if_ram_pc
);

reg[31:0]       pc;

always @(*) begin
    if (if_ram_en & ram_done) begin
        if_ram_en      = 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        if_allowin      <= 1'b1;
        if_validout     <= 1'b0;
        if_ram_en       <= 1'b0;
        if_ram_pc       <= 32'd0;
        pc              <= 32'd0;
    end else begin
        //Rules:
        //When MEM is not to work at the current period, IF works.
        //If the last command jumps to another PC, IF jumps to.
        if (ie_result_mem_load | ie_result_mem_store) begin
            if_ram_en   <= 1'b0;
            if_validout <= 1'b0;
        end else begin
            if_validout <= 1'b1;
            if (ie_result_jmp) begin
                if_ram_en   <= 1'b1;
                if_ram_pc   <= ie_result_pc;
                pc          <= ie_result_pc;
            end else begin
                if_ram_en   <= 1'b1;
                if_ram_pc   <= pc;
                pc          <= pc + 3'd4;
            end
        end
    end
end

endmodule