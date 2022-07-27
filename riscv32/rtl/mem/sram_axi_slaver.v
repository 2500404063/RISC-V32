`include "./rtl/mem/sram.v"

module mem_sram_axi_slaver (
    //global
    input               clk,
    input               rst_n,
    //axi read address
    input[31:0]         araddr,
    input[1:0]          arsize,
    input               arvalid,
    output reg          arready,
    //axi read data
    output reg[31:0]    rdata,
    output reg          rvalid,
    input               rready,
    //axi write address
    input[31:0]         awaddr,
    input[1:0]          awsize,
    input               awvalid,
    output reg          awready,
    //axi write data
    input[31:0]         wdata,
    input               wvalid,
    output reg          wready,
    //axi write response
    output reg          bvalid,
    input               bready
);

reg         en;
reg         wen;
reg[2:0]    cs;
reg[12:0]   addr;
reg[1:0]    size;
wire[31:0]  dout[7:0];

genvar i;
generate
    for (i = 0; i < 8; i=i+1) begin:srams
        mem_sram_8k #(
            .sel(i)
        ) sram(
            .clk(clk),
            .rst_n(rst_n),
            .en(en),
            .wen(wen),
            .cs(cs),
            .addr(addr),
            .size(size),
            .din(wdata),
            .dout(dout[i])
        );
    end
endgenerate

reg      useless_reg;

reg[2:0] cur_state_read;
reg[2:0] nxt_state_read;

reg[2:0] cur_state_write;
reg[2:0] nxt_state_write;

localparam STATE_READ_IDLE          = 3'b000;
localparam STATE_READ_AR_READY      = 3'b001;
localparam STATE_READ_WAIT          = 3'b011;
localparam STATE_READ_READ          = 3'b111;
localparam STATE_READ_READ_READY    = 3'b101;

localparam STATE_WRITE_IDLE         = 3'b000;
localparam STATE_WRITE_AWW_READY    = 3'b001;
localparam STATE_WRITE_RESP         = 3'b011;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state_read <= STATE_READ_IDLE;
        cur_state_write <= STATE_WRITE_IDLE;
    end else begin
        cur_state_read <= nxt_state_read;
        cur_state_write <= nxt_state_write;
    end
end

always @(*) begin
    case (cur_state_read)
        STATE_READ_IDLE: begin
            if (arvalid) begin
                nxt_state_read = STATE_READ_AR_READY;
            end else begin
                nxt_state_read = STATE_READ_IDLE;
            end
        end
        STATE_READ_AR_READY: begin
            if (arready & arvalid) begin
                nxt_state_read = STATE_READ_WAIT;
            end
        end
        STATE_READ_WAIT: begin
            nxt_state_read = STATE_READ_READ;
        end
        STATE_READ_READ: begin
            nxt_state_read = STATE_READ_READ_READY;
        end
        STATE_READ_READ_READY: begin
            if (rvalid & rready) begin
                nxt_state_read = STATE_READ_IDLE;
            end
        end
        default: nxt_state_read = STATE_READ_IDLE;
    endcase

    case (cur_state_write)
        STATE_WRITE_IDLE: begin
            if (awvalid & wvalid) begin
                nxt_state_write = STATE_WRITE_AWW_READY;
            end else begin
                nxt_state_write = STATE_WRITE_IDLE;
            end
        end
        STATE_WRITE_AWW_READY: begin
            if (awvalid & wvalid & awready & wready) begin
                nxt_state_write = STATE_WRITE_RESP;
            end
        end
        STATE_WRITE_RESP: begin
            if (bvalid & bready) begin
                nxt_state_write = STATE_WRITE_IDLE;
            end
        end
        default: nxt_state_write = STATE_WRITE_IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        arready <= 1'b0;
        awready <= 1'b0;
        wready  <= 1'b0;
        rvalid  <= 1'b0;
        bvalid  <= 1'b0;
        en      <= 1'b0;
        wen     <= 1'b0;
    end else begin
        case (cur_state_read)
            STATE_READ_AR_READY: begin
                if (arvalid) begin
                    arready <= 1'b1;
                    en      <=  1'b1;
                    wen     <=  1'b0;
                    addr    <=  araddr[12:0];
                    cs      <=  araddr[15:13];
                    size    <=  arsize;
                end
                if (arready & arvalid) begin
                    arready <= 1'b0;
                end
            end
            STATE_READ_READ: begin
                rdata   <=  dout[cs];
                rvalid  <=  1'b1;
            end
            STATE_READ_READ_READY: begin
                if (rvalid & rready) begin
                    rvalid <= 1'b0;
                end
            end
            default: useless_reg <= 1'b0;
        endcase

        case (cur_state_write)
            STATE_WRITE_AWW_READY: begin
                if (awvalid & wvalid) begin
                    awready     <= 1'b1;
                    wready      <= 1'b1;
                    bvalid      <= 1'b0;

                    en          <= 1'b1;
                    wen         <= 1'b1;
                    addr        <= awaddr[10:0];
                    cs          <= awaddr[13:11];
                    size        <= awsize;
                end
                if (awvalid & wvalid & awready & wready) begin
                    awready     <= 1'b0;
                    wready      <= 1'b0;
                end
            end
            STATE_WRITE_RESP: begin
                bvalid      <= 1'b1;
                if (bvalid & bready) begin
                    bvalid      <= 1'b0;
                end
            end
            default: useless_reg <= 1'b0;
        endcase
    end
end

endmodule