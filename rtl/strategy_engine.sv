module strategy_engine (
    input logic clk,
    input logic rst_n,

    input logic [31:0] best_bid_price,
    input logic [31:0] panic_volume,

    output logic        trigger_buy,
    output logic        trigger_sell,
    output logic [31:0] trade_price
);

    localparam logic [31:0] PANIC_THRESHOLD = 32'd150;
    localparam logic [31:0] BARGAIN_PRICE   = 32'h50;
    localparam logic [31:0] TAKE_PROFIT_PRICE = 32'h90;

    typedef enum logic {
        WAITING_FOR_OPPORTUNITY = 1'b0,
        POSITION_TAKEN          = 1'b1
    } algo_state_t;

    algo_state_t state;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            trigger_buy  <= 1'b0;
            trigger_sell <= 1'b0;
            trade_price  <= 32'h0;
            state        <= WAITING_FOR_OPPORTUNITY;
        end
        else begin
            trigger_buy  <= 1'b0;
            trigger_sell <= 1'b0;

            case (state)
                WAITING_FOR_OPPORTUNITY: begin
                    if((panic_volume >= PANIC_THRESHOLD) && (best_bid_price > 0) && (best_bid_price <=BARGAIN_PRICE)) begin
                        trigger_buy <= 1'b1;
                        trade_price <= best_bid_price;
                        state       <= POSITION_TAKEN;
                    end
                end

                POSITION_TAKEN: begin
                    if (best_bid_price >= TAKE_PROFIT_PRICE) begin
                        trigger_sell <= 1'b1;         
                        trade_price  <= best_bid_price; 
                        state        <= WAITING_FOR_OPPORTUNITY;
                    end
                end
            endcase
        end
    end

endmodule