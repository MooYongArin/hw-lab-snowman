module Mux3to1 #(
    parameter size = 32
) 
(
    input [1:0] sel,                // Selector (2 bits)
    input signed [size-1:0] s0,     // Input 0
    input signed [size-1:0] s1,     // Input 1
    input signed [size-1:0] s2,     // Input 2
    output signed [size-1:0] out    // Output
);
    // TODO: implement your 3to1 multiplexer here

    reg [size-1:0] reg_out;
    assign out = reg_out;
    always @(*) begin
        if (sel == 0) begin
            reg_out <= s0;
        end
        else if (sel == 1) begin
            reg_out <= s1;
        end
        else if (sel == 2) begin
            reg_out <= s2;
        end
    end
    
  always @(sel) begin 
    if (out === {32{1'bx}}) begin // Check if A contains any 'X's
      $display("output All bits are X");
    end else if (| (out ^ out)) begin //check if any bit is X
      $display("out Invalid: %h ", out);
    end else begin
      $display("out Valid: %h ", out);
    end
  end
  
endmodule

