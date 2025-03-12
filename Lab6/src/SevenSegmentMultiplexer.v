`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/01/2025 02:16:55 AM
// Design Name: BCD_Counter
// Module Name: Multiplexer
// Project Name: BCD_Counter
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Multiplexer module for 7-Segment Display
//////////////////////////////////////////////////////////////////////////////////


module Multiplexer (
    input  wire [15:0] DataIn,
    input  wire [ 1:0] Selector,
    output wire [ 3:0] DataOut
);
  // Add your code here
    reg [3:0]out;
    assign DataOut = out;

    always @(*) begin
        if (Selector == 0) begin
            out = DataIn[3:0];
        end
        else if (Selector == 1) begin
            out = DataIn[7:4];
        end
        else if (Selector == 2) begin
            out = DataIn[11:8];
        end
        else begin
            out = DataIn[15:12];
        end
    end
endmodule
