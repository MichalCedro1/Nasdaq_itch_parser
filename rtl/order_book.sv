import itch_pkg::*;

module order_book (
    input logic clk,
    input logic rst_n,

    input  order_event_t      fifo_dout,
    input  logic              fifo_empty,
    output logic              fifo_rd_en,

    output logic [31:0] best_bid_price,
    output logic [31:0] best_bid_volume,
    output logic [31:0] panic_volume
);

    logic [63:0] mem_a_orders [0:255];
    logic [31:0] mem_b_levels [0:255];

    initial begin
        for (int i = 0; i<256; i++) begin
            mem_a_orders[i] = 64'h0;
            mem_b_levels[i] = 32'h0;
        end
    end

    wire [7:0]  del_id     = fifo_dout.delete_data.order_ref_num[7:0];
    wire [31:0] del_price   = mem_a_orders[del_id][63:32];
    wire [31:0] del_shares  = mem_a_orders[del_id][31:0];

    typedef enum logic {
        ST_NORMAL = 1'b0,
        ST_SEARCH = 1'b1
    } state_t;

    state_t      state;
    logic [31:0] search_price;

    assign fifo_rd_en = (state ==ST_NORMAL) && (!fifo_empty);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            best_bid_price  <= 32'h0;
            best_bid_volume <= 32'h0;
            state           <= ST_NORMAL;
            search_price    <= 32'h0;
            panic_volume    <= 32'h0;
        end
        else begin
            case (state)
                ST_NORMAL: begin
                    if (!fifo_empty) begin
                        if (fifo_dout.evt_type == EVT_ADD && fifo_dout.order_data.buy_sell_indicator == 8'h42) begin
                            mem_a_orders[fifo_dout.order_data.order_ref_num[7:0]] <= {fifo_dout.order_data.price, fifo_dout.order_data.shares};
                            mem_b_levels[fifo_dout.order_data.price[7:0]]         <= mem_b_levels[fifo_dout.order_data.price[7:0]] + fifo_dout.order_data.shares;

                            if (fifo_dout.order_data.price > best_bid_price) begin
                                best_bid_price  <= fifo_dout.order_data.price;
                                best_bid_volume <= fifo_dout.order_data.shares;
                            end
                            else if (fifo_dout.order_data.price == best_bid_price) begin
                                best_bid_volume <= best_bid_volume + fifo_dout.order_data.shares;
                            end
                        end

                        if (fifo_dout.evt_type == EVT_DELETE) begin
                            mem_b_levels[del_price[7:0]] <= mem_b_levels[del_price[7:0]] - del_shares;

                            if (del_price == best_bid_price) begin
                                if (best_bid_volume <= del_shares) begin
                                    best_bid_volume <= 32'h0;
                                    state           <= ST_SEARCH;
                                    search_price    <= best_bid_price - 1;
                                end
                                else begin
                                    best_bid_volume <= best_bid_volume - del_shares;
                                end
                            end

                            if (del_shares > 50) begin
                                panic_volume <= panic_volume + del_shares;
                            end
                        end
                    end
                end
                ST_SEARCH: begin
                    if (mem_b_levels[search_price[7:0]] > 0) begin
                        best_bid_price  <= search_price;
                        best_bid_volume <= mem_b_levels[search_price[7:0]];
                        state           <= ST_NORMAL;
                    end
                    else if (search_price == 0) begin
                        best_bid_price  <= 32'h0;
                        best_bid_volume <= 32'h0;
                        state           <= ST_NORMAL;
                    end
                    else begin
                        search_price <= search_price - 1;
                    end
                end
            endcase
        end
    end

endmodule