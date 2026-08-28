package itch_pkg;
    typedef struct packed {
        logic [7:0]   msg_type;           
        logic [15:0]  stock_locate;       
        logic [15:0]  tracking_number;    
        logic [47:0]  timestamp;          
        logic [63:0]  order_ref_num;      
        logic [7:0]   buy_sell_indicator; 
        logic [31:0]  shares;             
        logic [63:0]  stock;              
        logic [31:0]  price;              
    } itch_add_order_t;

endpackage