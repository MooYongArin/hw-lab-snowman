module image_display_test_wrapper (
    input clk,               // 25 MHz
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input visible,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b
);

    wire [9:0] x = h_cnt >> 1;  // downscale 640x480 to 320x240
    wire [9:0] y = v_cnt >> 1;

    // Test pattern: horizontal gradient in R, vertical in G, checker in B
    wire [3:0] r = x[8:5];                     // horizontal red gradient
    wire [3:0] g = y[8:5];                     // vertical green gradient
    wire [3:0] b = (x[6] ^ y[6]) ? 4'hF : 4'h0; // checkerboard blue

    wire [11:0] image_data = {r, g, b};  // Combine RGB444

    // Use your original module but feed it test pattern
    image_display uut (
        .clk(clk),
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
