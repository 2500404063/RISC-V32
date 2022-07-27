module gnrl_dff_arst #(
    parameter width = 1,
    parameter rst   = 0
) (
    input               clk,
    input               rst_n,
    input[width-1:0]    d,
    output[width-1:0]   q
);

reg[width-1:0]  q_r;
assign          q = q_r;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        q_r <= {width{rst}};
    end else begin
        q_r <= d;
    end
end

endmodule

module gnrl_dff_rst #(
    parameter width = 1,
    parameter rst   = 0
) (
    input               clk,
    input               rst_n,
    input[width-1:0]    d,
    output[width-1:0]   q
);

reg[width-1:0]  q_r;
assign          q = q_r;

always @(posedge clk) begin
    if (~rst_n) begin
        q_r <= {width{rst}};
    end else begin
        q_r <= d;
    end
end

endmodule