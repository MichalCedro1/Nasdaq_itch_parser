import itch_pkg::*;
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
    
    itch_add_order_t parsed_order;
    logic            order_valid;

    itch_delete_order_t parsed_delete;
    logic               delete_valid;

    logic [31:0]     best_bid;


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
        .parsed_order(parsed_order), 
        .order_valid(order_valid),
        .parsed_delete(parsed_delete),
        .delete_valid(delete_valid)
    );


    order_book ob_dut (
        .clk(clk),
        .rst_n(rst_n),
        .parsed_order(parsed_order),
        .order_valid(order_valid), 
        .parsed_delete(parsed_delete),
        .delete_valid(delete_valid),
        
        .best_bid_price(best_bid)  
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

        // ============================================
        // 1. NAGŁÓWEK (2 wiadomości w paczce)
        // ============================================
        $display("Wysylam naglowek MoldUDP64...");
        for (int i = 0; i < 18; i++) begin
            @(posedge clk);          
            s_axis_tvalid <= 1'b1;   
            s_axis_tdata  <= 8'h00;  
            s_axis_tlast  <= 1'b0;
        end
        @(posedge clk); s_axis_tdata <= 8'h00; 
        @(posedge clk); s_axis_tdata <= 8'h03; 

        // ============================================
        // 2. WIADOMOŚĆ 1: KUPNO ZA CENĘ 0x50
        // ============================================
        $display("Wysylam Oferte 1 (Cena 50)...");
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h24; // Len: 36
        @(posedge clk); s_axis_tdata <= 8'h41; // Typ 'A'
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h01; // Locate
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h02; // Track
        for(int i=0; i<6; i++) begin @(posedge clk); s_axis_tdata <= 8'hAA; end // Time
        for(int i=0; i<8; i++) begin @(posedge clk); s_axis_tdata <= 8'hBB; end // Ref
        
        @(posedge clk); s_axis_tdata <= 8'h42; // BUY (Kupno)
        for(int i=0; i<4; i++) begin @(posedge clk); s_axis_tdata <= 8'h00; end // Shares
        
        // Stock: AAPL
        @(posedge clk); s_axis_tdata <= 8'h41; @(posedge clk); s_axis_tdata <= 8'h41; 
        @(posedge clk); s_axis_tdata <= 8'h50; @(posedge clk); s_axis_tdata <= 8'h4C; 
        @(posedge clk); s_axis_tdata <= 8'h20; @(posedge clk); s_axis_tdata <= 8'h20; 
        @(posedge clk); s_axis_tdata <= 8'h20; @(posedge clk); s_axis_tdata <= 8'h20; 
        
        // CENA NR 1: 0x00000050
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h00;
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h50;

        // ============================================
        // 3. WIADOMOŚĆ 2: KUPNO ZA CENĘ 0x99
        // ============================================
        $display("Wysylam Oferte 2 (Cena 99)...");
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h24; // Len: 36
        @(posedge clk); s_axis_tdata <= 8'h41; // Typ 'A'
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h01; // Locate
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h02; // Track
        for(int i=0; i<6; i++) begin @(posedge clk); s_axis_tdata <= 8'hAA; end // Time
        for(int i=0; i<8; i++) begin @(posedge clk); s_axis_tdata <= 8'hBB; end // Ref
        
        @(posedge clk); s_axis_tdata <= 8'h42; // BUY (Kupno)
        for(int i=0; i<4; i++) begin @(posedge clk); s_axis_tdata <= 8'h00; end // Shares
        
        // Stock: AAPL
        @(posedge clk); s_axis_tdata <= 8'h41; @(posedge clk); s_axis_tdata <= 8'h41; 
        @(posedge clk); s_axis_tdata <= 8'h50; @(posedge clk); s_axis_tdata <= 8'h4C; 
        @(posedge clk); s_axis_tdata <= 8'h20; @(posedge clk); s_axis_tdata <= 8'h20; 
        @(posedge clk); s_axis_tdata <= 8'h20; @(posedge clk); s_axis_tdata <= 8'h20; 
        
        // CENA NR 2: 0x00000099
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h00;
        @(posedge clk); s_axis_tdata <= 8'h00; 
        @(posedge clk); 
        s_axis_tdata <= 8'h99; 

        // ============================================
        // 4. WIADOMOŚĆ 3: KASOWANIE ZAMÓWIENIA ('D') - 19 bajtów
        // ============================================
        $display("Wysylam Oferte Kasowania (D)...");
        // Długość wiadomości: 19 bajtów (0x13 w systemie szesnastkowym)
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h13; 

        // 1. Typ 'D'
        @(posedge clk); s_axis_tdata <= 8'h44; 
        
        // 2. Stock Locate (2 bajty) & Tracking Number (2 bajty)
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h01; 
        @(posedge clk); s_axis_tdata <= 8'h00; @(posedge clk); s_axis_tdata <= 8'h02; 
        
        // 3. Timestamp (6 bajtów)
        for(int i=0; i<6; i++) begin @(posedge clk); s_axis_tdata <= 8'hAA; end 

        // 4. Order Ref Num (8 bajtów) - tutaj dajemy TLAST na końcu paczki sieciowej!
        for(int i=0; i<7; i++) begin @(posedge clk); s_axis_tdata <= 8'hBB; end 
        @(posedge clk); 
        s_axis_tdata <= 8'hBB; 
        s_axis_tlast <= 1'b1; // TLAST KOŃCZY CAŁY RUCH SIECIOWY

        // ============================================
        // 5. ZAMKNIĘCIE TRANSMISJI
        // ============================================
        @(posedge clk);
        s_axis_tvalid <= 1'b0;
        s_axis_tlast  <= 1'b0;
        s_axis_tdata  <= 8'h00;

        #100 $finish;
    end

endmodule