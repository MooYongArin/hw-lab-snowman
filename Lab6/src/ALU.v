module ALU (
    input [3:0] ALUctl,                     // This will be used to select the operation of ALU
    input brLt,                             // Branch Less Than (for branching instruction)
    input brEq,                             // Branch Equal (for branching instruction)
    input signed [31:0] A,B,                // Operands
    output reg signed [31:0] ALUOut        // Output of ALU
);
    // ALU has two operand, it execute different operator based on ALUctl wire

    // TODO: implement your ALU here
    // Hint: you can use operator to implement

//reg [3:0] ALUc;
//assign ALUctl = ALUc;

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

/*
always @(*) begin

    case (ALUc)
        ADD: begin
            ALUOut <= A + B;
        end
        SUB: begin
            ALUOut <= A - B;
        end
        AND: begin
            ALUOut <= A & B;
        end
        OR: begin
            ALUOut <= A | B;
        end
        SLT: begin
            if (A < B) begin
                ALUOut <= 1;
            end else begin
                ALUOut <= 0;
            end
        end
        NOTHING: begin
            ALUOut <= A;
        end
        ADDIFEQ: begin
            if (A == B) begin
                ALUOut <= A + B;
            end
            
            //else begin
            //    ALUOut <= A;
            //end

        end
        ADDEVEN: begin
                ALUOut <= A + B;
                ALUOut[0] <= 0;
        end
        ADDIFNEQ: begin
            if (A != B) begin
                ALUOut <= A + B;
            end
        end
        ADDIFLT: begin
            if (A < B) begin
                ALUOut <= A + B;
            end
        end
        ADDIFNLT: begin
            if (A >= B) begin
                ALUOut <= A + B;
            end
        end
        default: begin // Undefined opcode
            //ALUOut = A;
        end

    endcase

end

endmodule
*/
    always @(*) begin
        case (ALUctl)
            ADD:     ALUOut <= A + B;
            SUB:     ALUOut <= A - B;
            AND:     ALUOut <= A & B;
            OR:      ALUOut <= A | B;
            SLT:     ALUOut <= (A < B) ? 1 : 0;
            NOTHING: ALUOut <= A;
            ADDIFEQ: ALUOut <= (A == B) ? A + B : A;
            ADDEVEN: begin
                ALUOut <= A + B;
                ALUOut <= ALUOut & ~1; //force result to be even.
            end
            ADDIFNEQ: ALUOut <= (A != B) ? A + B : A;
            ADDIFLT:  ALUOut <= (A < B) ? A + B : A;
            ADDIFNLT: ALUOut <= (A >= B) ? A + B : A;
            default:  ALUOut <= 32'bx;
        endcase
    end
    
    
    
    
  always @(A) begin
    if (A === {32{1'bx}}) begin // Check if A contains any 'X's
      $display("A All bits are X");
    end else if (| (A ^ A)) begin //check if any bit is X
      $display("A Invalid: %h ", A);
    end else begin
      $display("A Valid: %h ", A);
    end
  end
  always @(B) begin
    if (B === {32{1'bx}}) begin // Check if A contains any 'X's
      $display("B All bits are X");
    end else if (| (B ^ B)) begin //check if any bit is X
      $display("B Invalid: %h ", B);
    end else begin
      $display("B Valid: %h ", B);
    end
  end
  
  
    

endmodule


