`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/01/2025 02:16:12 AM
// Design Name: BCD_Counter
// Module Name: SevenSegmentDisplay
// Project Name: BCD_Counter
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Top module for 7-Segment Display
//////////////////////////////////////////////////////////////////////////////////


module SevenSegmentDisplay #(
    parameter ControllerClockCycle   = 1,
    parameter ControllerCounterWidth = 1
) (
    input wire [15:0] DataIn,
    input wire Clk,
    input wire Reset,
    output wire [7:0] Segments,
    output wire [3:0] AN
);
  // Add your code here
  wire [1:0]selector;
  wire [3:0]out;

    SevenSegmentMultiplexer  SevenSegmentMultiplexerInst (
        .DataIn(DataIn[15:0]),
        .DataOut(out[3:0]),
        .Selector(selector[1:0])
    );
     SevenSegmentController #(
        .ControllerClockCycle  (ControllerClockCycle),
        .ControllerCounterWidth(ControllerCounterWidth)
    )  SevenSegmentControllerInst (
        .Reset(Reset),
        .Clk(Clk),
        .AN(AN[3:0]),
        .Selector(selector[1:0])
    );
    SevenSegmentDecoder SevenSegmentDecoderInst (
        .DataIn(out[3:0]),
        .Segments(Segments[7:0])
    );
  // End of your code
endmodule
