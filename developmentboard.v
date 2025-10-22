`timescale 1ns / 1ns

module DevelopmentBoard(
    input wire clk, 
    input wire reset, B2, B3, B4, B5,
   
    output wire h_sync, v_sync,
    output wire [15:0] rgb,
    
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4,
    output wire led5
);

   
    reg pixel_clk;
    always @(posedge clk) begin
        pixel_clk <= ~pixel_clk;
    end

  
    localparam H_DISPLAY = 640;
    localparam H_FRONT = 16;
    localparam H_SYNC = 96;
    localparam H_BACK = 48;
    localparam H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
    
    localparam V_DISPLAY = 480;
    localparam V_FRONT = 10;
    localparam V_SYNC = 2;
    localparam V_BACK = 33;
    localparam V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count;
    reg [9:0] v_count;
    
    
    assign h_sync = (h_count >= (H_DISPLAY + H_FRONT) && h_count < (H_DISPLAY + H_FRONT + H_SYNC));
    assign v_sync = (v_count >= (V_DISPLAY + V_FRONT) && v_count < (V_DISPLAY + V_FRONT + V_SYNC));
    
   
    wire display_enable = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
  
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    
    localparam CHAR_WIDTH = 64;
    localparam CHAR_HEIGHT = 128;
    localparam CHAR_SPACING = 16;
  
    localparam START_X = (H_DISPLAY - (4 * CHAR_WIDTH + 3 * CHAR_SPACING)) / 2;
    localparam START_Y = (V_DISPLAY - CHAR_HEIGHT) / 2;
    
   
    wire in_char_area = (h_count >= START_X) && 
                       (h_count < START_X + 4 * CHAR_WIDTH + 3 * CHAR_SPACING) &&
                       (v_count >= START_Y) && 
                       (v_count < START_Y + CHAR_HEIGHT);
    
    wire [1:0] char_index;
    wire [5:0] char_x;
    wire [6:0] char_y;
    
    assign char_index = (h_count - START_X) / (CHAR_WIDTH + CHAR_SPACING);
    assign char_x = (h_count - START_X) % (CHAR_WIDTH + CHAR_SPACING);
    assign char_y = v_count - START_Y;
    
   
    wire char_pixel;
    
    
    char_rom char_rom_inst(
        .char_index(char_index),
        .x(char_x),
        .y(char_y),
        .pixel(char_pixel)
    );
    
    
    assign rgb = display_enable && in_char_area && char_pixel ? 16'hFFFF : 16'h0000;
    
   
    assign led1 = B2;
    assign led2 = B3;
    assign led3 = B4;
    assign led4 = B5;
    assign led5 = reset;

endmodule


module char_rom(
    input wire [1:0] char_index,  
    input wire [5:0] x,           
    input wire [6:0] y,           
    output reg pixel
);
   
    
    always @(*) begin
        case(char_index)
            2'b00: pixel = draw_M(x, y);  
            2'b01: pixel = draw_U(x, y);  
            2'b10: pixel = draw_S(x, y);  
            2'b11: pixel = draw_T(x, y);  
            default: pixel = 0;
        endcase
    end
    

    function draw_M;
        input [5:0] x;
        input [6:0] y;
        begin
            
            draw_M = ((x < 8) || (x >= 56) || 
                     ((x >= 24 && x < 40) && (y < 64)) ||
                     (y >= 112 && ((x >= 16 && x < 24) || (x >= 40 && x < 48))));
        end
    endfunction
    
    function draw_U;
        input [5:0] x;
        input [6:0] y;
        begin
            
            draw_U = (((x < 8) || (x >= 56)) && (y < 112)) ||
                     (y >= 112 && (x >= 16 && x < 48));
        end
    endfunction
    
    function draw_S;
        input [5:0] x;
        input [6:0] y;
        begin
            
            draw_S = ((y < 16) && (x >= 8 && x < 56)) ||
                     ((y >= 16 && y < 56) && ((x < 8) || (x >= 56))) ||
                     ((y >= 56 && y < 72) && (x >= 8 && x < 56)) ||
                     ((y >= 72 && y < 112) && ((x < 8) || (x >= 56))) ||
                     ((y >= 112) && (x >= 8 && x < 56));
        end
    endfunction
    
    function draw_T;
        input [5:0] x;
        input [6:0] y;
        begin
            
            draw_T = ((y < 16) && (x >= 8 && x < 56)) ||
                     ((y >= 16) && (x >= 24 && x < 40));
        end
    endfunction

endmodule