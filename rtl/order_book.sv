import itch_pkg::*;

module order_book (
    input logic clk,
    input logic rst_n,

    input itch_add_order_t parsed_order,
    input logic            order_valid,

    output logic [31:0] best_bid_price
);
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            best_bid_price <= 32'h0;
        end
        else begin
            if (order_valid) begin
                if(parsed_order.stock == 64'h4141504C20202020 && 
                parsed_order.buy_sell_indicator == 8'h42) begin
                    if (parsed_order.price > best_bid_price) begin
                        best_bid_price <= parsed_order.price;
                    end
                end
            end
        end
    end

endmodule