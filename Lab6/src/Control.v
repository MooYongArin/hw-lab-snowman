module Control (
    input [6:0] opcode,         // opcode field of instruction
    output reg memRead,         // memory read signal
    output reg [1:0] memtoReg,  // memory to register signal
    output reg [2:0] ALUOp,     // ALU operation signal
    output reg memWrite,        // memory write signal
    output reg ALUSrc1,         // ALU source 1 signal (for MUX)
    output reg ALUSrc2,         // ALU source 2 signal (for MUX)
    output reg regWrite,        // register write signal
    output reg PCSel            // PC select signal (for MUX PC)
);

    // TODO: implement your Control here
    // Hint: follow the Architecture (figure in spec) to set output signal
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-TYPE ADD, SUB, AND, OR, SLT | ALUOp = 0
                memRead <= 0;
                memtoReg <= 0; // 0 -> write ALU result | 1 -> read from memory | 2 -> PC + 4
                ALUOp <= 0;
                memWrite <= 0;
                ALUSrc1 <= 0; // 1 -> PC | 0 -> reg_read
                ALUSrc2 <= 0; // 1 -> imm | 0 -> reg_read
                regWrite <= 1;
                PCSel <= 0; // 0 -> PC + 4 | 1 -> branch, jump
            end
            7'b0010011: begin // I-TYPE ADDI, ANDI, ORI, XORI, SLTI | ALUOp = 1
                memRead <= 0;
                memtoReg <= 0;
                ALUOp <= 1;
                memWrite <= 0;
                ALUSrc1 <= 0;
                ALUSrc2 <= 1;
                regWrite <= 1;
                PCSel <= 0;
            end
            7'b0000011: begin // I-TYPE LW | ALUOp = 2
                memRead <= 1;
                memtoReg <= 1;
                ALUOp <= 2;
                memWrite <= 0;
                ALUSrc1 <= 0;
                ALUSrc2 <= 1;
                regWrite <= 1;
                PCSel <= 0;
            end
            7'b0100011: begin // S-TYPE SW | ALUOp = 3
                memRead <= 0;
                memtoReg <= 0;
                ALUOp <= 3;
                memWrite <= 1;
                ALUSrc1 <= 0;
                ALUSrc2 <= 1;
                regWrite <= 0;
                PCSel <= 0;
            end
            7'b1100011: begin // B-TYPE BEQ, BNE, BLT, BGE | ALUOp = 4
                memRead <= 0;
                memtoReg <= 0;
                ALUOp <= 4;
                memWrite <= 0;
                ALUSrc1 <= 1;
                ALUSrc2 <= 1;
                regWrite <= 0;
                PCSel <= 1;
            end
            7'b1101111: begin // J-TYPE JAL | ALUOp = 5
                memRead <= 0;
                memtoReg <= 2;
                ALUOp <= 5;
                memWrite <= 0;
                ALUSrc1 <= 1;
                ALUSrc2 <= 1;
                regWrite <= 1;
                PCSel <= 1;
            end
            7'b1100111: begin // I-TYPE JALR | ALUOp = 6
                memRead <= 0;
                memtoReg <= 2;
                ALUOp <= 6;
                memWrite <= 0;
                ALUSrc1 <= 0;
                ALUSrc2 <= 1;
                regWrite <= 1;
                PCSel <= 1;
            end
            default:  begin
            end
        endcase
    end

endmodule

