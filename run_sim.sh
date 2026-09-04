xvlog -sv rtl/hft_top.sv rtl/itch_pkg.sv rtl/itch_parser.sv rtl/order_book.sv rtl/strategy_engine.sv sim/itch_parser_tb.sv
xelab -debug typical -top itch_parser_tb -snapshot parser_sim
xsim parser_sim -gui