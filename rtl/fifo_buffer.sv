import itch_pkg::*;

module fifo_buffer #(
    parameter int DEPTH = 16,
    parameter int PTR_W = 4
)(
    input  logic         clk,
    input  logic         rst_n,


    input  logic         wr_en,
    input  order_event_t din,
    output logic         full,

    input  logic         rd_en,
    output order_event_t dout,
    output logic         empty
);

    order_event_t mem [0:DEPTH-1];

    logic [PTR_W:0] wr_ptr;
    logic [PTR_W:0] rd_ptr;

    assign dout  = mem[rd_ptr[PTR_W-1:0]];
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[PTR_W-1:0] == rd_ptr[PTR_W-1:0]) && (wr_ptr[PTR_W] != rd_ptr[PTR_W]);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[PTR_W-1:0]] <= din;
                wr_ptr                 <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end

endmodule