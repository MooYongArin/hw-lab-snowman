module vga_top (
    input clk_25mhz,      // 25 MHz input clock
    input rst,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output hsync,
    output vsync
);

    wire [9:0] h_cnt, v_cnt;
    wire visible;

    // VGA Controller
    vga_controller vga_ctrl (
        .clk(clk_25mhz),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .hsync(hsync),
        .vsync(vsync),
        .visible(visible)
    );

    // Downscaled pixel coordinates for 320x240 image display
    wire [9:0] x = h_cnt >> 1;
    wire [9:0] y = v_cnt >> 1;

    // Test Pattern Generator
    wire [3:0] r = x[8:5];                     // Red gradient
    wire [3:0] g = y[8:5];                     // Green gradient
    wire [3:0] b = (x[6] ^ y[6]) ? 4'hF : 4'h0; // Blue checkerboard

    wire [11:0] image_data = {r, g, b};        // Combine into RGB444

    // Image Display
    image_display display (
        .clk(clk_25mhz),
        .rst(rst),
        .image_data(image_data),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .visible(visible),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

endmodule
