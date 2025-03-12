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
    reg [1:0] reg_memtoReg;
    reg [2:0] reg_ALUOp;
    reg reg_memRead, reg_memWrite;
    reg reg_ALUSrc1, reg_ALUSrc2, reg_regWrite, reg_PCSel;
    assign memtoReg = reg_memtoReg; // 0 -> write ALU result | 1 -> read from memory | 2 -> PC + 4
    assign memRead = reg_memRead;
    assign ALUOp = reg_ALUOp;
    assign memWrite = reg_memWrite;
    assign ALUSrc1 = reg_ALUSrc1; // 1 -> PC | 0 -> reg_read
    assign ALUSrc2 = reg_ALUSrc2; // 1 -> imm | 0 -> reg_read
    assign regWrite = reg_regWrite;
    assign PCSel = reg_PCSel; // 0 -> PC + 4 | 1 -> branch, jump
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-TYPE ADD, SUB, AND, OR, SLT | ALUOp = 0
                reg_memRead <= 0;
                reg_memtoReg <= 0;
                reg_ALUOp <= 0;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 0;
                reg_ALUSrc2 <= 0;
                reg_regWrite <= 1;
                reg_PCSel <= 0;
            end
            7'b0010011: begin // I-TYPE ADDI, ANDI, ORI, XORI, SLTI | ALUOp = 1
                reg_memRead <= 0;
                reg_memtoReg <= 0;
                reg_ALUOp <= 1;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 0;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 1;
                reg_PCSel <= 0;
            end
            7'b0000011: begin // I-TYPE LW | ALUOp = 2
                reg_memRead <= 1;
                reg_memtoReg <= 1;
                reg_ALUOp <= 2;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 0;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 1;
                reg_PCSel <= 0;
            end
            7'b0100011: begin // S-TYPE SW | ALUOp = 3
                reg_memRead <= 0;
                reg_memtoReg <= 0;
                reg_ALUOp <= 3;
                reg_memWrite <= 1;
                reg_ALUSrc1 <= 0;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 0;
                reg_PCSel <= 0;
            end
            7'b1100011: begin // B-TYPE BEQ, BNE, BLT, BGE | ALUOp = 4
                reg_memRead <= 0;
                reg_memtoReg <= 0;
                reg_ALUOp <= 4;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 1;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 0;
                reg_PCSel <= 1;
            end
            7'b1101111: begin // J-TYPE JAL | ALUOp = 5
                reg_memRead <= 0;
                reg_memtoReg <= 2;
                reg_ALUOp <= 5;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 1;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 1;
                reg_PCSel <= 1;
            end
            7'b1100111: begin // I-TYPE JALR | ALUOp = 6
                reg_memRead <= 0;
                reg_memtoReg <= 2;
                reg_ALUOp <= 6;
                reg_memWrite <= 0;
                reg_ALUSrc1 <= 0;
                reg_ALUSrc2 <= 1;
                reg_regWrite <= 1;
                reg_PCSel <= 1;
            end
            default:  begin
            end
        endcase
    end

endmodule

