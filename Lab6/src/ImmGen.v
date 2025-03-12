module ImmGen (
    input [31:0] inst,                  // instruction
    output reg signed [31:0] imm        // imm value (output)
);
    // ImmGen generate imm value base opcode

    wire [6:0] opcode = inst[6:0];
    always @(*) begin
        case(opcode)
            // TODO: implement your ImmGen here
            // Hint: follow the RV32I opcode map (table in spec) to set imm value
            
            7'b0010011 : imm <= {{20{inst[31]}}, inst[31:20]};                                           // addi, andi, ori, slti
            7'b0000011 : imm <= {{20{inst[31]}}, inst[31:20]};                                           // lw
            7'b0100011 : imm <= {{20{inst[31]}}, inst[31:25], inst[11:7]};                               // sw
            7'b1100011 : imm <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};      // beq, bne, blt, bge
            7'b1101111 : imm <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};    // jal
            7'b1100111 : imm <= {{20{inst[31]}}, inst[31:20]};                                           // jalr
        endcase
    end

endmodule

