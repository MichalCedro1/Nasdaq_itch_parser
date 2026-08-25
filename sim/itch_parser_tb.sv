module itch_parser_tb;

    logic clk;
    logic rst_n;

    logic [7:0] s_axis_tdata;
    logic       s_axis_tvalid;
    logic       s_axis_tlast;
    logic       s_axis_tready;

    logic [7:0] msg_type;
    logic [7:0] msg_data;
    logic       msg_valid;

    itch_parser dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .msg_type(msg_type),
        .msg_data(msg_data),
        .msg_valid(msg_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        s_axis_tdata = 8'h00;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;

        #20 rst_n = 1;

        #20;

        $display("Wysylam naglowek MoldUDP64...");
        for (int i = 0; i < 20; i++) begin
            @(posedge clk);          
            s_axis_tvalid <= 1'b1;   
            s_axis_tdata  <= 8'h00;  
            s_axis_tlast  <= 1'b0;
        end

        $display("Wysylam Dlugosc wiadomosci...");
        @(posedge clk); s_axis_tdata <= 8'h00;
        @(posedge clk); s_axis_tdata <= 8'h04; 

        $display("Wysylam typ wiadomosci ITCH...");
        @(posedge clk); s_axis_tdata <= 8'h41; 

        $display("Wysylam Payload...");
        @(posedge clk); s_axis_tdata <= 8'hBB;
        @(posedge clk); s_axis_tdata <= 8'hCC;
        @(posedge clk); 
        s_axis_tdata <= 8'hDD;
        s_axis_tlast <= 1'b1; 

        @(posedge clk);
        s_axis_tvalid <= 1'b0;
        s_axis_tlast  <= 1'b0;
        s_axis_tdata  <= 8'h00;

        #100 $finish;
    end

endmodule