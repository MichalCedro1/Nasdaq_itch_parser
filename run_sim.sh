xvlog -sv rtl/itch_parser.sv sim/itch_parser_tb.sv
xelab -debug typical -top itch_parser_tb -snapshot parser_sim
xsim parser_sim -gui