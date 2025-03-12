`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: BCD_Counter
// Module Name: SevenSegmentController
// Project Name: BCD_Counter
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Controller module for 7-Segment Display
//////////////////////////////////////////////////////////////////////////////////


module SevenSegmentController #(
    parameter ControllerClockCycle   = 1,
    parameter ControllerCounterWidth = 1
) (
    input  wire       Reset,
    input  wire       Clk,
    output wire [3:0] AN,
    output wire [1:0] Selector
);
  reg [ControllerCounterWidth-1:0] Counter = 0;
  // Add your code here
  reg [3:0] an;
  reg [1:0] select;
  assign AN = an;
  assign Selector = select;

  always @(posedge Clk or posedge Reset) begin
    if(Reset) begin
        an <= 4'b1111;
        select <= 0;
        Counter <= 0;
    end 
    else begin
        if (an == 4'b1111) begin
            an <= 4'b1110;
        end 
        else begin
            Counter <= Counter + 1;
            if(Counter == ControllerClockCycle-1) begin
                select = select + 1;
                case (an)
                    4'b1111: an = 4'b1110; 
                    4'b1110: an = 4'b1101; 
                    4'b1101: an = 4'b1011; 
                    4'b1011: an = 4'b0111; 
                    4'b0111: an = 4'b1110; 
                    default: an = 4'b1111;     // Default case (should not occur)
                endcase
                Counter <= 0;
            end 
        end
     end

//    $display("Value of Counter: %b", Counter);

  end
  // End of your code
endmodule