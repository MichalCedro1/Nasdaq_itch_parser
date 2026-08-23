module itch_parser (
    input logic clk,
    input logic rst_n,

    input logic [7:0] s_axis_tdata,
    input logic       s_axis_tvalid,
    input logic       s_axis_tlast,
    output logic      s_axis_tready,

    output logic [7:0] msg_type,
    output logic       msg_valid
);

    assign s_axis_tready = 1'b1; 

    typedef enum logic {
        ST_IDLE = 1'b0,
        ST_READ = 1'b1
    } state_t;

    state_t             state;
    logic [15:0]        byte_cnt;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            msg_valid <= 0;
            msg_type  <= 8'h00;
            state     <= ST_IDLE;
            byte_cnt  <= 0;
        end 
        else begin
            msg_valid <= 1'b0;

            if (s_axis_tvalid) begin
                case (state)
                    ST_IDLE: begin
                        state    <= ST_READ;
                        byte_cnt <= 1;
                    end

                    ST_READ: begin
                        if (byte_cnt == 19) begin
                            msg_type  <= s_axis_tdata;
                            msg_valid <= 1'b1;
                        end

                        if (s_axis_tlast) begin
                            state <= ST_IDLE;
                        end else begin
                            byte_cnt <= byte_cnt +1;
                        end
                    end
                endcase
            end
        end
    end

endmodule