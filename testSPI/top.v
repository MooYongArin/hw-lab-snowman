module top (
    input wire clk100mhz,
    input wire btnC,
    input wire sd_miso,
    output wire sd_mosi,
    output wire sd_sck,
    output wire sd_cs,
    output wire [7:0] led
);

    wire rst_n = btnC;  // Use center button as reset (active low)

    wire [7:0] data_out;
    wire data_valid;
    wire busy, error;
    reg start_read;
    reg [31:0] sector_addr = 32'h00010000;  // match test sector
    reg [7:0] block_count = 8'd1;
    reg [7:0] debug_led;

    // One-shot trigger logic for read start
    reg btn_prev;
    always @(posedge clk100mhz) begin
        btn_prev <= btnC;
        if (~btn_prev & btnC)  // rising edge detect
            start_read <= 1;
        else
            start_read <= 0;
    end

    // Store debug LED
    always @(posedge clk100mhz) begin
        if (data_valid)
            debug_led <= data_out;
    end

    // Assign outputs
//    assign led = debug_led;

    // Instantiate SPI SD reader
    sd_card_reader sd (
        .clk(clk100mhz),
        .rst_n(rst_n),
        .miso(sd_miso),
        .mosi(sd_mosi),
        .sck(sd_sck),
        .cs_n(sd_cs),  // active low
        .start_read(start_read),
        .sector_addr(sector_addr),
        .block_count(block_count),
        .data_out(data_out),
        .data_valid(data_valid),
        .busy(busy),
        .error(error),
//        .debug_led(led)
        .data_out(led)
    );

endmodule
