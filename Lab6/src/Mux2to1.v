module Mux2to1 #(
    parameter size = 32
) 
(
    input sel,                      // Selector
    input signed [size-1:0] s0,     // Input 0
    input signed [size-1:0] s1,     // Input 1
    output signed [size-1:0] out    // Output
);
    // TODO: implement your 2to1 multiplexer here
    reg [size-1:0] reg_out;
    assign out = reg_out;
    always @(*) begin
        if (sel == 0) begin
            reg_out <= s0;
        end
        else if (sel == 1) begin
            reg_out <= s1;
        end
    end
    
endmodule

