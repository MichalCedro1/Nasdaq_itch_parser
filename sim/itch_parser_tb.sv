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
    logic [31:0] msg_ticker;
    logic [31:0] msg_price;
    logic        order_valid;

    itch_parser dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .msg_type(msg_type),
        .msg_data(msg_data),
        .msg_valid(msg_valid),
        .msg_ticker(msg_ticker),
        .msg_price(msg_price),    
        .order_valid(order_valid)
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
        
        for (int i = 0; i < 18; i++) begin
            @(posedge clk);          
            s_axis_tvalid <= 1'b1;   
            s_axis_tdata  <= 8'h00;  
            s_axis_tlast  <= 1'b0;
        end

        // ... (Nagłówek i Count zostają bez zmian)
        // Wysyłamy bajty 18 i 19 (Message Count = 1 wiadomość)
        @(posedge clk); s_axis_tdata <= 8'h00; 
        @(posedge clk); s_axis_tdata <= 8'h01; 

        // ============================================
        // WIADOMOŚĆ: Typ 'A', długość 9 bajtów (1 typ + 4 ticker + 4 cena)
        // ============================================
        $display("Wysylam Wiadomosc Add Order (AAPL)...");
        @(posedge clk); s_axis_tdata <= 8'h00; // Długość: 9
        @(posedge clk); s_axis_tdata <= 8'h09; 

        @(posedge clk); s_axis_tdata <= 8'h41; // Typ 'A'
        
        // --- 4 BAJTY TICKERA (Szyld: AAPL) ---
        @(posedge clk); s_axis_tdata <= 8'h41; // Litera 'A'
        @(posedge clk); s_axis_tdata <= 8'h41; // Litera 'A'
        @(posedge clk); s_axis_tdata <= 8'h50; // Litera 'P'
        @(posedge clk); s_axis_tdata <= 8'h4c; // Litera 'L'

        // --- 4 BAJTY CENY (Cokolwiek) ---
        @(posedge clk); s_axis_tdata <= 8'hFF; 
        @(posedge clk); s_axis_tdata <= 8'hEE; 
        @(posedge clk); s_axis_tdata <= 8'hDD; 
        @(posedge clk); 
        s_axis_tdata <= 8'hCC; 
        s_axis_tlast <= 1'b1;  // TLAST = 1 (Koniec)

        // Zamykamy transmisję
        @(posedge clk);
        s_axis_tvalid <= 1'b0;
        s_axis_tlast  <= 1'b0;
        s_axis_tdata  <= 8'h00;

        #100 $finish;
    end

endmodule