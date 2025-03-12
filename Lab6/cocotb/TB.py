import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock


class CPU:
    def __init__(self, instruction_file_name):
        self.pc = 0
        self.registers = [0] * 32
        self.memory = [0] * 128
        self.instruction_memory = self.load_instruction_memory(instruction_file_name)
        self.instruction_count = len(self.instruction_memory)

    def load_instruction_memory(self, instruction_file_name):
        with open(instruction_file_name, "r") as f:
            return [int(line.strip(),2) for line in f.readlines()]

    def reset(self):
        self.pc = 0
        self.registers = [0] * 32
        self.memory = [0] * 128
        self.registers[2] = 128 
    
    def fetch_instruction(self):
        return (
            (self.instruction_memory[self.pc] << 24)
            | (self.instruction_memory[self.pc + 1] << 16)
            | (self.instruction_memory[self.pc + 2] << 8)
            | self.instruction_memory[self.pc + 3]
        )

    def convert_int_to_2scomplement(self, value):
        if(value < 0):
            return (1 << 32) + value
        else :
            return value
        
    def convert_immediate_to_int(self, value, length):
        if((value >> (length - 1)) & 0x1):
            return value - (1 << length)
        else:
            return value

    def check_result(self, dut):
        # check registers value
        for i in range(32):
            # print("debug value",i,dut.m_Register.regs[i].value,self.convert_int_to_2scomplement(self.registers[i]),self.registers[i])
            assert dut.m_Register.regs[i].value == self.convert_int_to_2scomplement(self.registers[i])
        # check memory value
        for i in range(128):
            assert dut.m_DataMemory.data_memory[i].value == self.convert_int_to_2scomplement(self.memory[i])

    def execute_one_instruction(self):
        if self.pc >= self.instruction_count:
            # end of program
            return False
        # fetch instruction
        instruction = self.fetch_instruction()
        # execute instruction
        opcode = instruction & 0x7F
        if opcode == 0x33:
            # R-type
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct7 = (instruction >> 25) & 0x7F
            if funct3 == 0x0 and funct7 == 0x00:
                # ADD Function
                self.registers[rd] = (self.registers[rs1] + self.registers[rs2]) & 0xFFFFFFFF
            elif funct3 == 0x0 and funct7 == 0x20:
                # SUB Function
                self.registers[rd] = (self.registers[rs1] - self.registers[rs2]) & 0xFFFFFFFF
            elif funct3 == 0x7 and funct7 == 0x00:
                # AND Function
                self.registers[rd] = (self.registers[rs1] & self.registers[rs2]) & 0xFFFFFFFF
            elif funct3 == 0x6 and funct7 == 0x00:
                # OR Function
                self.registers[rd] = (self.registers[rs1] | self.registers[rs2]) & 0xFFFFFFFF
            elif funct3 == 0x2 and funct7 == 0x00:
                # SLT Function
                if(self.registers[rs1] < self.registers[rs2]):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            self.pc += 4
        elif opcode == 0x13:
            # I-type
            imm = (instruction >> 20)
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            if funct3 == 0x0:
                # ADDI Function
                self.registers[rd] = (self.registers[rs1] + self.convert_immediate_to_int(imm, 12)) & 0xFFFFFFFF
            elif funct3 == 0x7:
                # ANDI Function
                self.registers[rd] = (self.registers[rs1] & self.convert_immediate_to_int(imm, 12)) & 0xFFFFFFFF
            elif funct3 == 0x6:
                # ORI Function
                self.registers[rd] = (self.registers[rs1] | self.convert_immediate_to_int(imm, 12)) & 0xFFFFFFFF
            elif funct3 == 0x2:
                # SLTI Function
                if(self.registers[rs1] < self.convert_immediate_to_int(imm, 12)):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            self.pc += 4
        elif opcode == 0x3:
            # I-type Load
            imm = (instruction >> 20)
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            # LW Function
            self.registers[rd] = self.memory[self.registers[rs1] + self.convert_immediate_to_int(imm, 12)]
            self.pc += 4
        elif opcode == 0x23:
            # S-type Store
            offset = (instruction >> 25) << 5 | (instruction >> 7) & 0x1F
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            # SW Function
            self.memory[self.registers[rs1] + offset] = self.registers[rs2]
            self.pc += 4
        elif opcode == 0x63:
            # B-type
            offset = (instruction >> 31) << 12 | ((instruction >> 25) & 0x3F) << 5 | ((instruction >> 8) & 0xF) << 1 | (((instruction >> 7) & 0x1) << 11)
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            if funct3 == 0x0:
                # BEQ Function
                if(self.registers[rs1] == self.registers[rs2]):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x1:
                # BNE Function
                if(self.registers[rs1] != self.registers[rs2]):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x4:
                # BLT Function
                if(self.registers[rs1] < self.registers[rs2]):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x5:
                # BGE Function
                if(self.registers[rs1] >= self.registers[rs2]):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
        elif opcode == 0x6F:
            # J-type
            imm = (instruction >> 31) << 20 | ((instruction >> 12) & 0xFF) << 12 | ((instruction >> 20) & 0x1) << 11 | ((instruction >> 21) & 0x3FF) << 1
            rd = (instruction >> 7) & 0x1F
            # JAL Function
            self.registers[rd] = self.pc + 4
            self.pc += self.convert_immediate_to_int(imm, 21)
        elif opcode == 0x67:
            # I-type
            imm = (instruction >> 20)
            rd = (instruction >> 7) & 0x1F
            rs1 = (instruction >> 15) & 0x1F
            # JALR Function
            self.registers[rd] = self.pc + 4
            self.pc = (self.registers[rs1] + imm) & 0xFFFFFFFF
        self.registers[0] = 0
        return True


@cocotb.test()
async def TestTB(dut):
    # set timeout
    program_running_limit = 10000
    """Try accessing the design."""
    dut._log.info("Running test!")
    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    # create the CPU
    virtual_cpu = CPU("../src/EXAMPLE_INSTRUCTIONS.txt")
    # reset
    dut.start.value = 0
    virtual_cpu.reset()
    await Timer(15, units="ns")
    dut.start.value = 1
    virtual_cpu.check_result(dut)
    dut._log.info("Reset Complete")
    await Timer(10, units="ns")
    while virtual_cpu.execute_one_instruction() and program_running_limit > 0:
        # check result
        virtual_cpu.check_result(dut)
        await Timer(10, units="ns")
        program_running_limit -= 1
    dut._log.info("Test Complete")
