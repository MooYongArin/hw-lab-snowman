module Adder (
    input signed [31:0] a,
    input signed [31:0] b,
    output signed [31:0] sum
);
    // Adder computes sum = a + b
    // The module is useful when accumulating PC (Program Counter)
    
    // TODO: implement your Adder here
    // Hint: you can use operator to implement (just add it)
    reg [31:0] sumReg;
    assign sum=sumReg;
    always@(*) begin
        sumReg=a+b;
    end
endmodule

