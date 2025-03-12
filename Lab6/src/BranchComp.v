module BranchComp(
    input [31:0] rs1,       // First register value
    input [31:0] rs2,       // Second register value
    output brLt,            // Output for less than condition
    output brEq             // Output for equality condition
);

    // TODO: implement your branch comparator here for checking if
    // value is register is less than or equal to another register
    reg reg_brLt, reg_brEq;
    assign brLt = reg_brLt;
    assign brEq = reg_brEq;
    always@(*) begin
        reg_brLt <= (rs1<rs2);
        reg_brEq <= (rs1==rs2);
    end
endmodule