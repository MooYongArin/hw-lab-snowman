module sd_vga_top (
    input wire clk,           // 25 MHz clock for VGA
    input wire reset,         // Reset button
    input wire miso,          // From SD card
    output wire cs, mosi, sclk, // To SD card
    output wire hsync, vsync,
    output wire [11:0] rgb,
    output wire [4:0] led     // status LEDs (optional)
);

    // Frame buffer to store 256 RGB444 pixels (12 bits)
    reg [11:0] frame [0:255];

    // SD controller wires
    wire [7:0] dout;
    wire byte_available;
    wire ready;
    wire [4:0] status;
    wire wr_ack, rd_ack;

    // VGA sync wires
    wire [9:0] x, y;
    wire video_on;

    // Instantiate SD controller (only reading)
    sd_controller sd_inst (
        .clk(clk),
        .reset(reset),
        .rd(1'b1),                        // start reading
        .address(32'h00010000),          // image sector
        .miso(miso),
        .cs(cs),
        .mosi(mosi),
        .sclk(sclk),
        .dout(dout),
        .byte_available(byte_available),
        .ready(ready),
        .status(status),
        .wr(1'b0),                       // disable writing
        .din(8'h00),
        .ready_for_next_byte()
    );

    // Frame loader: capture 512 bytes = 256 pixels
    reg [7:0] pixel_index = 0;
    reg [7:0] buffer_hi;
    reg phase = 0;

    always @(posedge clk) begin
        if (reset) begin
            pixel_index <= 0;
            phase <= 0;
        end else if (byte_available && pixel_index < 256) begin
            if (phase == 0)
                buffer_hi <= dout;
            else begin
                frame[pixel_index] <= {buffer_hi, dout} >> 4;  // 12-bit RGB444
                pixel_index <= pixel_index + 1;
            end
            phase <= ~phase;
        end
    end

    // VGA Sync
    vga_sync vga_sync_unit (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .p_tick(), // unused
        .x(x),
        .y(y)
    );

    // Display only the first 16x16 pixels from frame buffer
    wire [7:0] vga_index = (y < 16 && x < 16) ? (y[3:0] << 4) | x[3:0] : 0;
    wire [11:0] pixel_rgb = frame[vga_index];

    assign rgb = (video_on && x < 16 && y < 16) ? pixel_rgb : 12'b0;
    assign led = status;

endmodule
