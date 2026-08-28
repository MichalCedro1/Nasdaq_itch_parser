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
        .order_valid(order_valid)   
    );


    order_book ob_dut (
        .clk(clk),
        .rst_n(rst_n),
        .parsed_order(parsed_order),
        .order_valid(order_valid), 
        
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
        // 1. WYSYŁAMY NAGŁÓWEK MOLD_UDP64 (Tego brakowało!)
        // ============================================
        $display("Wysylam naglowek MoldUDP64...");
        
        // Wysyłamy pierwsze 18 bajtów (Session i SeqNum)
        for (int i = 0; i < 18; i++) begin
            @(posedge clk);          
            s_axis_tvalid <= 1'b1;   // WŁĄCZAMY TRANSMISJĘ!
            s_axis_tdata  <= 8'h00;  
            s_axis_tlast  <= 1'b0;
        end

        // Wysyłamy bajty 18 i 19 (Message Count = 1 wiadomość w pakiecie)
        @(posedge clk); s_axis_tdata <= 8'h00; 
        @(posedge clk); s_axis_tdata <= 8'h01; 

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
        @(posedge clk); s_axis_tdata <= 8'h02; // MSG COUNT = 2

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
        s_axis_tlast <= 1'b1; // TLAST na samym końcu drugiej wiadomości!

        // ============================================
        // 4. ZAMKNIĘCIE TRANSMISJI
        // ============================================
        @(posedge clk);
        s_axis_tvalid <= 1'b0;
        s_axis_tlast  <= 1'b0;
        s_axis_tdata  <= 8'h00;

        #100 $finish;

        #100 $finish;
    end

endmodule