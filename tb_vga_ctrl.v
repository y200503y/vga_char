`timescale 1ns/1ns  
module tb_vga_ctrl();  

wire locked;  
wire rst_n;  
wire vga_clk;  

reg sys_clk;  
reg sys_rst_n;  
reg [15:0] pix_data;  

wire [9:0] pix_x;  
wire [9:0] pix_y;  
wire hsync;  
wire vsync;  
wire [15:0] rgb;  
  
initial  
begin  
    sys_clk = 1'b1;  
    sys_rst_n <= 1'b0;  
    #200  
    sys_rst_n <= 1'b1;  
end  

always #10 sys_clk = ~sys_clk;  
 
assign rst_n = sys_rst_n & locked;  
 
always @(posedge vga_clk or negedge rst_n)  
begin  
    if (rst_n == 1'b0)  
        pix_data <= 16'h0000;  
    else  
        pix_data <= 16'hffff; 
end  

clk_gen clk_gen_inst (  
    .areset (~sys_rst_n),  
    .inclk0 (sys_clk),     
    .c0 (vga_clk),         
    .locked (locked)       
);  
 
vga_ctrl vga_ctrl_inst (  
    .vga_clk (vga_clk),    
    .sys_rst_n (rst_n),    
    .pix_data (pix_data),  
    .pix_x (pix_x),        
    .pix_y (pix_y),        
    .hsync (hsync),        
    .vsync (vsync),        
    .rgb (rgb)
);  

endmodule   