module image_display (
    input clk,               // 25 MHz
    input rst,
    input [11:0] image_data,  // pixel data (e.g., grayscale)
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input visible,
    output reg [3:0] vga_r,
    output reg [3:0] vga_g,
    output reg [3:0] vga_b
//output [16:0] image_addr  // 320x240 needs 76,800 pixels = 17 bits
);

    wire [9:0] x = h_cnt >> 1;  // downscale VGA 640x480 to 320x240
    wire [9:0] y = v_cnt >> 1;

//    assign image_addr = (y < 240 && x < 320) ? (y * 320 + x) : 0;

    always @(posedge clk) begin
        if (rst) begin
            vga_r <= 0;
            vga_g <= 0;
            vga_b <= 0;
        end
        else if (visible && x < 320 && y < 240) begin
            vga_r <= image_data[11:8];
            vga_g <= image_data[7:4];
            vga_b <= image_data[3:0];
        end else begin
            vga_r <= 0;
            vga_g <= 0;
            vga_b <= 0;
        end
    end

endmodule
