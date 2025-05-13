module top_level (
    input wire clk_100MHz,        // System clock (100 MHz)
    input wire rst,               // Active-high reset
    input wire [1:0] image_select, // Image selection input

    // SD Card reader interface
    input wire miso,              // SPI MISO from SD card
    output wire cs_n,             // SPI chip select (active low)
    output wire sck,              // SPI clock
    output wire mosi,             // SPI MOSI to SD card

    // VGA output signals
    output wire hsync,            // VGA horizontal sync
    output wire vsync,            // VGA vertical sync
    output wire [3:0] vga_r,      // VGA red channel (RGB444)
    output wire [3:0] vga_g,      // VGA green channel (RGB444)
    output wire [3:0] vga_b       // VGA blue channel (RGB444)
);

    // --- Internal clocks ---
    wire clk_25MHz;

    clk_wiz_25 clkgen (
        .clk_in1(clk_100MHz),
        .clk_out1(clk_25MHz)
    );

    // --- Wires for SD data path ---
    wire [7:0] sd_data_out;
    wire sd_data_valid;

    // --- RAM signals ---
    wire [16:0] ram_addr;
    wire [15:0] ram_data;
    wire ram_write_en;

    wire [16:0] vga_read_addr;
    wire [15:0] vga_data_out;

    // --- Control signals (hook up actual button logic as needed) ---
    wire start_read = 1'b1;               // Auto-trigger for now
    wire [31:0] sector_addr = 32'd0;      // Starting address of image
    wire [7:0] block_count = 8'd1;        // Number of blocks to read

    // --- SD Card Reader ---
    sd_card_reader u_sd_card_reader (
        .clk(clk_25MHz),
        .rst_n(~rst),
        .miso(miso),
        .start_read(start_read),
        .sector_addr(sector_addr),
        .block_count(block_count),
        .cs_n(cs_n),
        .sck(sck),
        .mosi(mosi),
        .data_out(sd_data_out),
        .data_valid(sd_data_valid),
        .busy(),         // Optional: connect if needed
        .error(),        // Optional: connect if needed
        .debug_led()     // Optional: connect if needed
    );

    // --- Storage Controller ---
    storage_controller u_storage (
        .clk_25MHz(clk_25MHz),
        .clk_100MHz(clk_100MHz),
        .rst(rst),
        .data_in(sd_data_out),
        .write_enable(sd_data_valid),
        .read_enable(1'b1),  // Always reading
        .image_select(image_select),
        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .ram_write_en(ram_write_en),
        .vga_read_addr(vga_read_addr),
        .vga_data_in(vga_data_out),
        .vga_pixel_rgb444()  // Not used directly
    );

    // --- VGA Controller ---
    wire [9:0] h_cnt, v_cnt;
    wire visible;

    vga_controller u_vga_ctrl (
        .clk(clk_25MHz),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .hsync(hsync),
        .vsync(vsync),
        .visible(visible)
    );

    // --- Image Display ---
    image_display u_image_display (
        .clk(clk_25MHz),
        .rst(rst),
        .image_data(vga_data_out),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .visible(visible),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .image_addr(vga_read_addr)
    );

    // --- Dual-Port RAM (Block Memory Generator) ---
    blk_mem_gen_0 u_ram (
        // Write port (Port A)
        .clka(clk_25MHz),
        .addra(ram_addr),
        .dina(ram_data),
        .wea(ram_write_en),
        .ena(1'b1),
        .douta(),  // Write-only

        // Read port (Port B)
        .clkb(clk_25MHz),
        .addrb(vga_read_addr),
        .dinb(16'd0),
        .enb(1'b1),
        .doutb(vga_data_out)
    );

endmodule
