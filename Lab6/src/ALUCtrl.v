module ALUCtrl (
    input [2:0] ALUOp,          // ALU operation
    input funct7,               // funct7 field of instruction (only 30th bit of instruction)
    input [2:0] funct3,         // funct3 field of instruction
    output reg [3:0] ALUCtl     // ALU control signal
);

    

    // TODO: implement your ALU control here
    // For testbench verifying, Do not modify input and output pin
    // For funct7, we care only 30th bit of instruction. Why?
    // See all R-type instructions in the lab and observe.

    // Hint: using ALUOp, funct7, funct3 to select exact operation


    

localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam AND = 4'b0010;
localparam OR = 4'b0011;
localparam SLT = 4'b0100;
localparam NOTHING = 4'b0101;
localparam ADDIFEQ = 4'b0110;
localparam ADDEVEN = 4'b0111;
localparam ADDIFNEQ = 4'b1000;
localparam ADDIFLT = 4'b1001;
localparam ADDIFNLT = 4'b1010;



always @(*) begin 
    if (funct7 == 0 && funct3 == 3'b000 && ALUOp == 0) begin // ADD

    end else if (funct3 == 3'b000 && ALUOp == 1) begin //ADDI

    end else if (funct7 == 1 && funct3 == 3'b000 && ALUOp == 0) begin //SUB

    end else if (funct7 == 0 && funct3 == 3'b111 && ALUOp == 0) begin //AND

    end else if (funct3 == 3'b111 && ALUOp == 1) begin //ANDI

    end else if (funct7 == 0 && funct3 == 3'b110 && ALUOp == 0) begin //OR

    end else if (funct3 == 3'b110 && ALUOp == 1) begin //ORI

    end else if (funct7 == 0 && funct3 == 3'b010 && ALUOp == 0) begin //SLT

    end else if (funct3 == 3'b010 && ALUOp == 1) begin //SLTI

    end else if (ALUOp == 2) begin //LW

    end else if (ALUOp == 3) begin //SW

    end else if (funct3 == 3'b000 && ALUOp == 4) begin //BEQ

    end else if (ALUOp == 5) begin //JAL

    end else if (ALUOp == 6) begin //JALR

    end else if (funct3 == 3'b001 && ALUOp == 4) begin //BNE

    end else if (funct3 == 3'b100 && ALUOp == 4) begin //BLT

    end else if (funct3 == 3'b101 && ALUOp == 4) begin //BGE

    end 


end











endmodule

