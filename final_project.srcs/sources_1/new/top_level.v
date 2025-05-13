module top_level (
    input wire clk_100MHz,
    input wire btnC,
    input wire rst,
    input wire [7:0] sd_data_in,
    input wire sd_data_valid,
    input wire [1:0] image_select,

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

    // --- Internal wires ---
    wire [16:0] ram_addr;
    wire [15:0] ram_data;
    wire        ram_write_en;

    wire [16:0] vga_read_addr;
    wire [15:0] vga_data_out;
    wire [11:0] vga_rgb_out;
    wire [31:0] sd_start_address;

    wire read_enable; // Use Basys 3 button

    // --- Instantiate storage controller ---
    storage_controller u_storage (
        .clk_25MHz(clk_25MHz),
        .clk_100MHz(clk_100MHz),
        .rst(rst),
        .data_in(sd_data_in),
        .write_enable(sd_data_valid),
        .read_enable(read_enable),
        .image_select(image_select),

        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .ram_write_en(ram_write_en),

        .vga_read_addr(vga_read_addr),
        .vga_data_in(vga_data_out),
        .vga_pixel_rgb444(vga_rgb_out),

        .sd_start_address(sd_start_address)
    );

    // --- Instantiate dual-port RAM ---
    blk_mem_gen_0 u_ram (
    // Port A (write - SD card / storage_controller)
    .clka(clk_25MHz),
    .addra(ram_addr),
    .dina(ram_data),
    .wea(ram_write_en),
    .ena(1'b1),          // Enable always on for write side
               

    // Port B (read - VGA side)
    .clkb(clk_100MHz),
    .addrb(vga_read_addr),
    .enb(1'b1),           // Enable always on for read side
    .doutb(vga_data_out)
);
    InputSanitizer inputSanitizeInst(
    .Clk(clk_100MHz),
    .Reset(rst),
    .DataIn(btnC),
    .DataOut(read_enable)
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
        .image_data(vga_rgb_out),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .visible(visible),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
//        .image_addr()
    );


    // --- sd_card_controller not implemented here ---
    // You will need to connect sd_start_address and read_enable
    // to your sd_card_controller and feed sd_data_in, sd_data_valid

endmodule