module top_level (
    input wire clk_100MHz,        // System clock (100 MHz)
    input wire rst,               // Active-low reset
    input wire [1:0] image_select, // Image selection input

    // SD Card reader interface
    input wire miso,              // SPI MISO from SD card
    output wire cs_n,             // SPI chip select (active low)
    output wire sck,              // SPI clock
    output wire mosi,             // SPI MOSI to SD card
    output wire [7:0] sd_data_out, // Data from SD card
    output wire sd_data_valid,    // Data valid signal

    // VGA output signals
    output wire hsync,            // VGA horizontal sync
    output wire vsync,            // VGA vertical sync
    output wire [3:0] vga_r,      // VGA red channel (RGB444)
    output wire [3:0] vga_g,      // VGA green channel (RGB444)
    output wire [3:0] vga_b       // VGA blue channel (RGB444)
);

    // --- Internal clocks ---
    wire clk_25MHz;
    wire clk_50MHz = clk_100MHz; // Assuming 50 MHz for VGA clock
    clk_wiz_25 clkgen (
        .clk_in1(clk_100MHz),
        .clk_out1(clk_25MHz)
    );

    // --- Internal wires ---
    wire [16:0] ram_addr;
    wire [15:0] ram_data;
    wire ram_write_en;
    wire [16:0] vga_read_addr;
    wire [15:0] vga_data_out;

    // --- Instantiate SD Card Reader ---
    sd_card_reader u_sd_card_reader (
        .clk(clk_100MHz),           // Use 100 MHz clock
        .rst_n(~rst),               // Active-low reset (inverted)
        .miso(miso),
        .start_read(),              // Trigger read based on control signals
        .sector_addr(),             // Set to read image sectors
        .block_count(1),
        .cs_n(cs_n),
        .sck(sck),
        .mosi(mosi),
        .data_out(sd_data_out),
        .data_valid(sd_data_valid)
    );

    // --- Instantiate Storage Controller ---
    storage_controller u_storage (
        .clk_25MHz(clk_25MHz),
        .clk_100MHz(clk_100MHz),
        .rst(rst),
        .data_in(sd_data_out),      // Data from SD card
        .write_enable(sd_data_valid), // Data is valid when SD card reader signals it
        .read_enable(),             // Trigger read operation
        .image_select(image_select), // Image selection for display
        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .ram_write_en(ram_write_en),
        .vga_read_addr(vga_read_addr),
        .vga_data_in(vga_data_out),
        .vga_pixel_rgb444()         // Pass RGB444 data to VGA
    );

    // --- Instantiate VGA Controller ---
    vga_top u_vga (
        .clk_50mhz(clk_50MHz),      // VGA clock (50 MHz)
        .rst(rst),
        .img_addr(vga_read_addr),   // Address to read image data from RAM
        .image_data(vga_data_out),  // Image data (RGB565 format)
        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

    // --- Instantiate Image Display ---
    image_display u_image_display (
        .clk(clk_25MHz),
        .rst(rst),
        .image_data(vga_data_out),  // Image data in RGB565 format
        .h_cnt(vga_top.h_cnt),      // Horizontal pixel count
        .v_cnt(vga_top.v_cnt),      // Vertical pixel count
        .visible(vga_top.visible),  // Visible signal for drawing
        .vga_r(vga_r),              // VGA Red output
        .vga_g(vga_g),              // VGA Green output
        .vga_b(vga_b),              // VGA Blue output
        .image_addr(vga_read_addr)  // Address of current pixel
    );

endmodule
