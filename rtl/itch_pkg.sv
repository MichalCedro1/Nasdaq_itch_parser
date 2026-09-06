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

    typedef struct packed {
        logic [7:0]   msg_type;           
        logic [15:0]  stock_locate;       
        logic [15:0]  tracking_number;    
        logic [47:0]  timestamp;          
        logic [63:0]  order_ref_num;                  
    } itch_delete_order_t;

    typedef enum logic [1:0] {
        EVT_NONE   = 2'b00,
        EVT_ADD    = 2'b01,
        EVT_DELETE = 2'b10
    } evt_type_t;

    typedef struct packed {
        evt_type_t          evt_type;
        itch_add_order_t    order_data;
        itch_delete_order_t delete_data;
    } order_event_t;

endpackage