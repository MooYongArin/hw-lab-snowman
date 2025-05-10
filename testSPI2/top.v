/* Top module for SD card reader with status display on LEDs */

`timescale 1ns / 1ps

module sd_top (
    input clk,              // 25 MHz system clock
    input reset,            // Reset input
    input rd,               // Read enable
    input [31:0] address,   // SD card address (multiple of 512)
    input miso,             // SD card MISO (SD_DAT[0])
    output cs,              // SD card CS (SD_DAT[3])
    output mosi,            // SD card MOSI (SD_CMD)
    output sclk,            // SD card SCLK (SD_SCK)
    output [7:0] dout,      // Data output from SD card
    output byte_available,  // Indicates new byte available
    output ready,           // SD card ready signal
    output [4:0] led        // LED output for status (full 5-bit status)
);

    // Internal signals
    wire [4:0] status;      // Controller status

    // Instantiate SD controller
    sd_controller sd_inst (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .address(address),
        .miso(miso),
        .cs(cs),
        .mosi(mosi),
        .sclk(sclk),
        .dout(dout),
        .byte_available(byte_available),
        .ready(ready),
        .status(status),
        // Tie off write-related inputs
        .wr(1'b0),              // Disable write operations
        .din(8'h00),            // No write data
        .ready_for_next_byte()  // Leave unconnected
    );

    // Map full status to LEDs
    assign led = status;

endmodule