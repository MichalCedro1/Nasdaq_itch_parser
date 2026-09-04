import itch_pkg::*;

module hft_top (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [7:0]  s_axis_tdata,
    input  logic        s_axis_tvalid,
    input  logic        s_axis_tlast,
    output logic        s_axis_tready,

    output logic        trigger_buy,
    output logic        trigger_sell,
    output logic [31:0] trade_price,

    output logic [31:0] best_bid_price,
    output logic [31:0] panic_volume
);

    logic [7:0]         msg_type;
    logic [7:0]         msg_data;
    logic               msg_valid;

    itch_add_order_t    parsed_order;
    logic               order_valid;

    itch_delete_order_t parsed_delete;
    logic               delete_valid;
    
    logic [31:0]        best_bid_vol;

    itch_parser u_parser (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .msg_type(msg_type),
        .msg_data(msg_data),
        .msg_valid(msg_valid),
        .parsed_order(parsed_order),
        .order_valid(order_valid),
        .parsed_delete(parsed_delete),
        .delete_valid(delete_valid)
    );

    order_book u_order_book (
        .clk(clk),
        .rst_n(rst_n),
        .parsed_order(parsed_order),
        .order_valid(order_valid),
        .parsed_delete(parsed_delete),
        .delete_valid(delete_valid),
        .best_bid_price(best_bid_price),
        .best_bid_volume(best_bid_vol),
        .panic_volume(panic_volume)
    );

    strategy_engine u_strategy (
        .clk(clk),
        .rst_n(rst_n),
        .best_bid_price(best_bid_price),
        .panic_volume(panic_volume),
        .trigger_buy(trigger_buy),
        .trigger_sell(trigger_sell),
        .trade_price(trade_price)
    );

endmodule