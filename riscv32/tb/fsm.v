module FSM(
    input clk,
    input rst_n,
    input en,
    output reg done
);

reg[2:0]    delay_counter;
reg         useless_reg;
reg[2:0]    cur_state;
reg[2:0]    nxt_state;
//Gray Code
localparam  STATE_IDLE     = 3'b000;
localparam  STATE_S1       = 3'b001;
localparam  STATE_S2       = 3'b011;

//This is used for
//1. State shifting     (Sequential Logic)
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= STATE_IDLE;
    end else begin
        if(en) begin
            cur_state <= nxt_state;
        end
    end
end

//This is used for
//1. State judging      (Combinatorial Logic)
always @(*) begin
    if(en) begin
        case(cur_state)
            STATE_IDLE: begin
                nxt_state   = STATE_S1;
            end
            STATE_S1: begin
                if(delay_counter == 3'd4) nxt_state = STATE_S2;
            end
            STATE_S2: begin
                nxt_state       = STATE_IDLE;
            end
            default: useless_reg = 1'b0;
        endcase
    end
end

//This is used for
//1. Output (Sequential Logic)
always @(posedge clk) begin
    if(en) begin
        case(cur_state)
            STATE_IDLE: begin
                delay_counter       <= 1'b0;
            end
            STATE_S1: begin
                delay_counter       <= delay_counter + 1'b1;
            end
            STATE_S2: begin
                done            <= 1'b1;
            end
            default: useless_reg <= 1'b0;
        endcase
    end
end

endmodule