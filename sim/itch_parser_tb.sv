import itch_pkg::*;

module itch_parser_tb;

    logic clk;
    logic rst_n;

    logic [7:0] s_axis_tdata;
    logic       s_axis_tvalid;
    logic       s_axis_tlast;
    logic       s_axis_tready;

    logic        algo_buy;
    logic        algo_sell;
    logic [31:0] algo_price;
    logic [31:0] best_bid;
    logic [31:0] panic_volume;

    hft_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .trigger_buy(algo_buy),
        .trigger_sell(algo_sell),
        .trade_price(algo_price),
        .best_bid_price(best_bid),
        .panic_volume(panic_volume)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // TABLICA NA DANE Z PLIKU (Może pomieścić 1024 bajty)
    logic [7:0] memory [0:1023]; 

    initial begin
        // 1. WCZYTANIE DANYCH Z PLIKU DO PAMIĘCI
        // UWAGA: Upewnij się, że podajesz pełną ścieżkę do pliku, np. "/home/student/mcedro/itch_parser/market_data.hex"
        // Jeśli Vivado zgłosi błąd, że nie widzi pliku, podmień "market_data.hex" na absolutną ścieżkę!
        $readmemh("market_data.hex", memory);

        rst_n = 0;
        s_axis_tdata = 8'h00;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;

        #20 rst_n = 1;
        #20;

        $display("Rozpoczynam wstrzykiwanie danych z pliku...");

        // 2. AUTOMATYCZNE POMPOWANIE DANYCH DO PARSERA
        for (int i = 0; i < 1024; i++) begin
            if (memory[i] === 8'hxx) break; 
            
            // NOWOŚĆ: Reakcja na nasz Magiczny Znacznik
            if (memory[i] === 8'hFF) begin
                @(posedge clk);
                s_axis_tvalid <= 1'b0; // Zakręcamy kran z danymi
                s_axis_tlast  <= 1'b0;
                #1000;                 // Czekamy 1000ns aż Księgowy znajdzie 50$!
                continue;              // Przeskakujemy bajt 'FF' i jedziemy dalej
            end
            
            @(posedge clk);          
            s_axis_tvalid <= 1'b1;   
            s_axis_tdata  <= memory[i];  
            
            // TLAST musi pójść w górę przed pustym polem ATAKŻE przed przerwą 'FF'
            if (memory[i+1] === 8'hxx || memory[i+1] === 8'hFF) begin
                s_axis_tlast <= 1'b1;
            end else begin
                s_axis_tlast <= 1'b0;
            end
        end

        // Zamykamy rurę z danymi
        @(posedge clk);
        s_axis_tvalid <= 1'b0;
        s_axis_tlast  <= 1'b0;

        // Dajemy Księgowemu i Mózgowi czas na szukanie cen, kupno i sprzedaż
        #2000 $finish;
    end

endmodule