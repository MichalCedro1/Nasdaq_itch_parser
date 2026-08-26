module itch_parser (
    input logic clk,
    input logic rst_n,

    input logic [7:0] s_axis_tdata,
    input logic       s_axis_tvalid,
    input logic       s_axis_tlast,
    output logic      s_axis_tready,

    output logic [7:0] msg_type,
    output logic [7:0] msg_data,
    output logic       msg_valid,

    output logic [31:0] msg_ticker,
    output logic [31:0] msg_price,
    output logic        order_valid
);

    assign s_axis_tready = 1'b1; 

    typedef enum logic [2:0] {
        ST_IDLE       = 3'd0,
        ST_MOLD_HDR   = 3'd1,
        ST_MSG_LENGTH = 3'd2,
        ST_MSG_TYPE   = 3'd3,
        ST_PAYLOAD    = 3'd4  
    } state_t;

    state_t             state;
    logic [15:0]        byte_cnt;
    logic [15:0]        msg_length;
    logic [15:0]        msg_count_left;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            msg_valid      <= 0;
            msg_type       <= 8'h00;
            msg_data       <= 8'h00;
            msg_ticker     <= 32'h0;
            msg_price     <= 32'h0;
            state          <= ST_IDLE;
            byte_cnt       <= 0;
            msg_length     <= 0;
            msg_count_left <= 0;
        end 
        else begin
            msg_valid    <= 1'b0;
            order_valid <= 1'b0;

            if (s_axis_tvalid) begin
                case (state)
                    ST_IDLE: begin
                        state    <= ST_MOLD_HDR;
                        byte_cnt <= 1;
                        msg_count_left <=0;
                    end

                    ST_MOLD_HDR: begin
                        if (byte_cnt == 18 || byte_cnt == 19) begin
                            msg_count_left <= {msg_count_left[7:0], s_axis_tdata};
                        end

                        if (byte_cnt == 19) begin
                            state    <= ST_MSG_LENGTH;
                            byte_cnt <= 0;
                        end else begin
                            byte_cnt <= byte_cnt +1;
                        end
                    end
                    
                    ST_MSG_LENGTH: begin
                        msg_length <= {msg_length[7:0], s_axis_tdata};

                        if (byte_cnt == 1) begin
                            state    <= ST_MSG_TYPE;
                            byte_cnt <= 0;
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end

                    ST_MSG_TYPE: begin
                        msg_type  <= s_axis_tdata;
                        msg_data  <= s_axis_tdata;
                        msg_valid <= 1'b1;

                        state <=ST_PAYLOAD;
                        byte_cnt <= 1;
                    end

                    ST_PAYLOAD: begin
                        msg_valid <= 1'b1;
                        msg_data  <= s_axis_tdata;
                        
                        if (msg_type == 8'h41) begin
                            if (byte_cnt >= 1 && byte_cnt <= 4) begin
                                msg_ticker <= {msg_ticker[23:0], s_axis_tdata};
                            end

                            if (byte_cnt >= 5 && byte_cnt <= 8) begin
                                msg_price <= {msg_price[23:0], s_axis_tdata};
                            end
                        end

                        if (byte_cnt == msg_length - 1 || s_axis_tlast) begin
                            if (msg_type == 8'h41) begin
                                order_valid <= 1'b1;
                            end
                            if (msg_count_left > 1 && !s_axis_tlast) begin
                                msg_count_left <= msg_count_left - 1;
                                state          <= ST_MSG_LENGTH;
                                byte_cnt       <= 0;
                            end else begin
                                state <= ST_IDLE;
                            end

                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                endcase
            end
        end
    end

endmodule