import itch_pkg::*;

module order_book (
    input logic clk,
    input logic rst_n,

    input itch_add_order_t parsed_order,
    input logic            order_valid,

    input itch_delete_order_t parsed_delete,
    input logic               delete_valid,

    output logic [31:0] best_bid_price,
    output logic [31:0] best_bid_volume
);

    logic [63:0] mem_a_orders [0:255];
    logic [31:0] mem_b_levels [0:255];

    initial begin
        for (int i = 0; i<256; i++) begin
            mem_a_orders[i] = 64'h0;
            mem_b_levels[i] = 32'h0;
        end
    end

    wire [7:0] del_id       = parsed_delete.order_ref_num[7:0];
    wire [31:0] del_price   = mem_a_orders[del_id][63:32];
    wire [31:0] del_shares  = mem_a_orders[del_id][31:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            best_bid_price  <= 32'h0;
            best_bid_volume <= 32'h0;
        end
        else begin
            if (order_valid && parsed_order.buy_sell_indicator == 8'h42) begin
                mem_a_orders[parsed_order.order_ref_num[7:0]] <= {parsed_order.price, parsed_order.shares};

                mem_b_levels[parsed_order.price[7:0]] <= mem_b_levels[parsed_order.price[7:0]] + parsed_order.shares;

                if (parsed_order.price > best_bid_price) begin
                    best_bid_price <=  parsed_order.price;
                    best_bid_volume <= parsed_order.shares;
                end
                else if (parsed_order.price == best_bid_price) begin
                    best_bid_volume <= best_bid_volume + parsed_order.shares;
                end
            end

            if (delete_valid) begin
                mem_b_levels[parsed_order.price[7:0]] <= mem_b_levels[parsed_order.price[7:0]] - del_shares;
                if (del_price == best_bid_price) begin
                    best_bid_volume <= best_bid_volume - del_shares;
                end
            end
        end
    end

endmodule