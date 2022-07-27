module core_clk (
    input clk,
    input rst_n,
    output reg pipe_clk,
    output reg sram_clk
);

reg[3:0]    pipe_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipe_counter    <= 3'd0;
        pipe_clk        <= 1'b0;
        sram_clk        <= 1'b0;
    end else begin
        //count
        pipe_counter <= pipe_counter + 1'b1;
        //output
        sram_clk <= ~sram_clk;
        if (pipe_counter == 4'b1001) begin
            pipe_clk <= ~pipe_clk;
            pipe_counter <= 4'b0000;
        end
    end
end

endmodule