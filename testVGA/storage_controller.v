module storage_controller (
    input wire clk_25MHz,         // Clock for SD-side write
    input wire clk_100MHz,        // Clock for VGA-side read
    input wire rst,               // Reset signal

    input wire [7:0] data_in,     // 8-bit byte from SD card
    input wire write_enable,      // High when data_in is valid
    input wire read_enable,       // From button (shared trigger)
    input wire [1:0] image_select,// Select which image to show

    output reg [16:0] ram_addr,   // Address for RAM write
    output reg [15:0] ram_data,   // 16-bit RGB565 pixel
    output reg ram_write_en,      // Write enable to RAM

    output wire [16:0] vga_read_addr, // Read address for VGA controller

    input wire [15:0] vga_data_in,    // Data from RAM (RGB565)
    output wire [11:0] vga_pixel_rgb444, // Final VGA RGB444 output

    output wire [31:0] sd_start_address // Start byte address for SD read
);

    parameter IMAGE_SIZE = 76800;        // 320 * 240 pixels
    parameter IMAGE_BYTE_SIZE = 153600;  // 2 bytes per pixel

    wire [16:0] image_offset = image_select * IMAGE_SIZE;
        // --- WRITE SIDE LOGIC ---
    reg [7:0] byte_buf;
    reg byte_flag = 0;
    reg [16:0] write_ptr;

    reg [31:0] sd_start_address_reg;
    reg started = 0;

    assign sd_start_address = sd_start_address_reg;

    always @(posedge clk_25MHz or posedge rst) begin
        if (rst) begin
            byte_flag <= 0;
            write_ptr <= 0;
            ram_write_en <= 0;
            started <= 0;
            sd_start_address_reg <= 0;
        end else begin
            if (!started && read_enable) begin
                sd_start_address_reg <= image_select * IMAGE_BYTE_SIZE;
                started <= 1;
            end

            if (write_enable) begin
                if (!byte_flag) begin
                    byte_buf <= data_in;
                    byte_flag <= 1;
                    ram_write_en <= 0;
                end else begin
                    ram_data <= {byte_buf, data_in};
                    ram_addr <= write_ptr + image_offset;
                    ram_write_en <= 1;
                    write_ptr <= write_ptr + 1;
                    byte_flag <= 0;
                end
            end else begin
                ram_write_en <= 0;
            end
        end
    end

    // --- READ SIDE LOGIC ---
    reg [16:0] read_ptr;

    always @(posedge clk_100MHz or posedge rst) begin
        if (rst) begin
            read_ptr <= 0;
        end else if (read_enable) begin
            read_ptr <= read_ptr + 1;
        end
    end

    assign vga_read_addr = read_ptr + image_offset;

    // --- RGB565 to RGB444 Conversion ---
    wire [4:0] R5 = vga_data_in[15:11];
    wire [5:0] G6 = vga_data_in[10:5];
    wire [4:0] B5 = vga_data_in[4:0];

    wire [3:0] R4 = R5[4:1];
    wire [3:0] G4 = G6[5:2];
    wire [3:0] B4 = B5[4:1];

    assign vga_pixel_rgb444 = {R4, G4, B4};

endmodule