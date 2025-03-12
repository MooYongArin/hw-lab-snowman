module SingleCycleCPU (
    input   wire        clk,
    input   wire        start,
    output  wire [7:0]  segments,
    output  wire [3:0]  an
);
   wire [31:0] pc_ow;
   wire [31:0] pc_iw;
   wire [31:0] adder_ow;
   wire [31:0] inst_memo;
   wire memReadw;
   wire [1:0] memtoregw;
   wire [2:0] ALUopw;
   wire memwritew,ALUSrc1w,ALUSrc2w,regWritew,PCSelw;
   wire [31:0] writeDataw;
   wire [31:0] readData1w;
   wire [31:0] readData2w;
   wire [31:0] reg5Dataw;
   wire [31:0] readDataw;
   wire [31:0] addressw;
   wire [31:0] immw;
   wire [31:0] ALU_ow;
   wire [31:0] Aw,Bw;
   wire [3:0] ALUCt1w;
   wire brLtw,brEqw;
// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: Connect wires to realize SingleCycleCPU and instantiate all modules related to seven-segment displays
// The following provides simple template,

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(pc_iw),
    .pc_o(pc_ow)
);

Adder m_Adder_1(
    .a(pc_ow),
    .b(4),
    .sum(adder_ow)
);

InstructionMemory m_InstMem(
    .readAddr(pc_ow),
    .inst(inst_memo)
);

Control m_Control(
    .opcode(inst_memo[6:0]),
    .memRead(memReadw),
    .memtoReg(memtoregw),
    .ALUOp(ALUopw),
    .memWrite(memwritew),
    .ALUSrc1(ALUSrc1w),
    .ALUSrc2(ALUSrc2w),
    .regWrite(regWritew),
    .PCSel(PCSelw)
);

// ------------------------------------------
// For Student:
// Do not change the modules' instance names and I/O port names!!
// Or you will fail validation.
// By the way, you still have to wire up these modules

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWritew),
    .readReg1(inst_memo[19:15]),
    .readReg2(inst_memo[24:20]),
    .writeReg(inst_memo[11:7]),
    .writeData(writeDataw),
    .readData1(readData1w),
    .readData2(readData2w),
    .reg5Data(reg5Dataw)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memwritew),
    .memRead(memReadw),
    .address(addressw),
    .writeData(readData2w),
    .readData(readDataw)
);

// ------------------------------------------

ImmGen m_ImmGen(
    .inst(inst_memo[31:0]),
    .imm(immw)
);

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSelw),
    .s0(add_ow),
    .s1(ALU_ow),
    .out(pc_iw)
);

Mux2to1 #(.size(32)) m_Mux_ALU_1(
    .sel(ALUSrc1w),
    .s0(readData1w),
    .s1(pc_ow),
    .out(Aw)
);

Mux2to1 #(.size(32)) m_Mux_ALU_2(
    .sel(ALUSrc2w),
    .s0(readData2w),
    .s1(immw),
    .out(Bw)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUopw),
    .funct7(inst_memo[30]),
    .funct3(inst_memo[14:12]),
    .ALUCtl(ALUCt1w)
);

ALU m_ALU(
    .ALUctl(ALUCt1w),
    .brLt(brLtw),
    .brEq(brEqw),
    .A(Aw),
    .B(Bw),
    .ALUOut(addressw)
);

Mux3to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoregw),
    .s0(addressw),
    .s1(readDataw),
    .s2(adder_ow),
    .out(writeDataw)
);

BranchComp m_BranchComp(
    .rs1(readData1w),
    .rs2(readData2w),
    .brLt(brLtw),
    .brEq(brEqw)
);

SevenSegmentDisplay #(
    .ControllerClockCycle   (1),
    .ControllerCounterWidth (1)
) SevenSegmentDisplayInst(
    .DataIn(reg5Dataw [15:0]),
    .Clk(clk),
    .Reset(start),
    .Segments(segments),
    .AN(an)
);

endmodule
