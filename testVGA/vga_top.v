module vga_top (
    input clk_50mhz,          // VGA clock (50 MHz, driven by clock divider)
    input rst,                // Reset signal (active-low)
    input [16:0] img_addr,    // Image address (from storage controller)
    input [15:0] image_data,  // Image data (RGB565 format from RAM)
    output reg hsync,         // VGA horizontal sync
    output reg vsync,         // VGA vertical sync
    output reg [3:0] vga_r,   // VGA red output (RGB444 format)
    output reg [3:0] vga_g,   // VGA green output (RGB444 format)
    output reg [3:0] vga_b    // VGA blue output (RGB444 format)
);

    wire [9:0] h_cnt, v_cnt;  // Horizontal and vertical counters for pixel positions
    wire visible;              // Signal that indicates if the pixel is visible (inside display area)

    // VGA Controller instance (generates sync signals and handles counters)
    vga_controller u_vga_controller (
        .clk(clk_50mhz),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .visible(visible)
    );

    // Process the image data and convert it from RGB565 to RGB444
    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            vga_r <= 4'b0000;
            vga_g <= 4'b0000;
            vga_b <= 4'b0000;
        end else if (visible) begin
            // Extract RGB565 data from image and convert to RGB444
            // image_data is RGB565 format (5 bits red, 6 bits green, 5 bits blue)
            vga_r <= image_data[15:12];  // Upper 4 bits of Red
            vga_g <= image_data[10:7];   // Upper 4 bits of Green
            vga_b <= image_data[4:1];    // Upper 4 bits of Blue
        end
    end

endmodule
