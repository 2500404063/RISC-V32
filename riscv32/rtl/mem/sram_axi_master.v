module mem_sram_axi_master (
    //control
    input               en,
    input               wen,
    input[31:0]         addr,
    input[1:0]          size,
    input[31:0]         din,
    output reg[31:0]    dout,
    output reg          done,
    //global
    input               clk,
    input               rst_n,
    //axi read address
    output reg[31:0]    araddr,
    output reg[1:0]     arsize,
    output reg          arvalid,
    input               arready,
    //axi read data
    input[31:0]         rdata,
    input               rvalid,
    output reg          rready,
    //axi write address
    output reg[31:0]    awaddr,
    output reg[1:0]     awsize,
    output reg          awvalid,
    input               awready,
    //axi write data
    output reg[31:0]    wdata,
    output reg          wvalid,
    input               wready,
    //axi write response
    input               bvalid,
    output reg          bready
);

always @(*) begin
    if(!en) begin
        done = 1'b0;
    end
end

reg en_flag;
reg useless_reg;

reg[2:0] cur_state_read;
reg[2:0] nxt_state_read;

reg[2:0] cur_state_write;
reg[2:0] nxt_state_write;

localparam STATE_READ_IDLE        = 3'b000;
localparam STATE_READ_AR_VALID    = 3'b001;
localparam STATE_READ_AR_READY    = 3'b011;
localparam STATE_READ_R_READY     = 3'b111;

localparam STATE_WRITE_IDLE         = 3'b000;
localparam STATE_WRITE_AWW_VALID    = 3'b001;
localparam STATE_WRITE_AWW_READY    = 3'b011;
localparam STATE_WRITE_RESP_READY   = 3'b111;

//state shift
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state_read <= STATE_READ_IDLE;
        cur_state_write <= STATE_WRITE_IDLE;
    end else begin
        if (en) begin
            cur_state_read <= nxt_state_read;
            cur_state_write <= nxt_state_write;
        end
    end
end

//state jump
always @(*) begin
    //This is for read transaction
    case (cur_state_read)
        STATE_READ_IDLE: begin
            if (en & ~wen) begin
                nxt_state_read = STATE_READ_AR_VALID;
            end else begin
                nxt_state_read = STATE_READ_IDLE;
            end
        end
        STATE_READ_AR_VALID: begin
            nxt_state_read = STATE_READ_AR_READY;
        end
        STATE_READ_AR_READY: begin
            if (arvalid & arready) begin
                nxt_state_read = STATE_READ_R_READY;
            end
        end
        STATE_READ_R_READY: begin
            if (rvalid & rready) begin
                nxt_state_read = STATE_READ_IDLE;
            end
        end
        default: nxt_state_read = STATE_READ_IDLE;
    endcase

    //This is for write transaction
    case (cur_state_write)
        STATE_WRITE_IDLE: begin
            if (en & wen) begin
                nxt_state_write = STATE_WRITE_AWW_VALID;
            end else begin
                nxt_state_write = STATE_WRITE_IDLE;
            end
        end
        STATE_WRITE_AWW_VALID: begin
            nxt_state_write = STATE_WRITE_AWW_READY;
        end
        STATE_WRITE_AWW_READY: begin
            if (awvalid & awready & wvalid & wready) begin
                nxt_state_write = STATE_WRITE_RESP_READY;
            end
        end
        STATE_WRITE_RESP_READY: begin
            if (bvalid & bready) begin
                nxt_state_write = STATE_WRITE_IDLE;
            end
        end
        default: nxt_state_write = STATE_WRITE_IDLE;
    endcase
end

//output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        arvalid <= 1'b0;
        awvalid <= 1'b0;
        wvalid  <= 1'b0;
        bready  <= 1'b0;
        rready  <= 1'b0;
        done    <= 1'b0;
    end else begin
        if (en) begin
            if (~wen) begin
                case (cur_state_read)
                    STATE_READ_IDLE:begin
                        done    <= 1'b0;
                    end
                    STATE_READ_AR_VALID: begin
                        araddr  <= addr;
                        arsize  <= size;
                        arvalid <= 1'b1;
                    end
                    STATE_READ_AR_READY: begin
                        if (arvalid & arready) begin
                            arvalid <= 1'b0;
                        end
                    end
                    STATE_READ_R_READY: begin
                        if (rvalid) begin
                            rready <= 1'b1;
                        end
                        if (rvalid & rready) begin
                            rready <= 1'b0;
                            dout <= rdata;
                            done <= 1'b1;
                        end
                    end
                    default: useless_reg <= 1'b0;
                endcase
            end

            if (wen) begin
                case (cur_state_write)
                    STATE_READ_IDLE: begin
                        done     <= 1'b0;
                    end
                    STATE_WRITE_AWW_VALID: begin
                        awaddr   <= addr;
                        awsize   <= size;
                        wdata    <= din;
                        awvalid  <= 1'b1;
                        wvalid   <= 1'b1;
                    end
                    STATE_WRITE_AWW_READY: begin
                        if (awvalid & awready & wvalid & wready) begin
                            awvalid <= 1'b0;
                            wvalid  <=1'b0;
                        end
                    end
                    STATE_WRITE_RESP_READY: begin
                        if (bvalid) begin
                            bready <= 1'b1;
                        end
                        if (bvalid & bready) begin
                            bready <= 1'b0;
                            done <= 1'b1;
                        end
                    end
                    default: useless_reg <= 1'b0;
                endcase
            end
        end
    end
end

endmodule