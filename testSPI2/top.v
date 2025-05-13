/* Top module for SD card reader with status display on LEDs, ignoring address, dout, byte_available, and ready */

`timescale 1ns / 1ps

module sd_top (
    input wire clk,              // 25 MHz system clock
    input wire reset,            // Reset input
    input wire rd,            // Reset input
    input wire miso,             // SD card MISO (SD_DAT[0])
    output wire cs,              // SD card CS (SD_DAT[3])
    output wire mosi,            // SD card MOSI (SD_CMD)
    output wire sclk,            // SD card SCLK (SD_SCK)
    output wire [4:0] led        // LED output for status (full 5-bit status)
);

    // Internal signals
    wire [4:0] status;      // Controller status

    // Instantiate SD controller
    sd_controller sd_inst (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .address(32'h0),        // Tie off address to 0
        .miso(miso),
        .cs(cs),
        .mosi(mosi),
        .sclk(sclk),
        .dout(),                // Leave dout unconnected
        .byte_available(),      // Leave byte_available unconnected
        .ready(),               // Leave ready unconnected
        .status(status),
        // Tie off write-related inputs
        .wr(1'b0),              // Disable write operations
        .din(8'h00),            // No write data
        .ready_for_next_byte()  // Leave unconnected
    );

    // Map full status to LEDs
    assign led = status;

endmodule