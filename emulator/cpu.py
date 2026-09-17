"""Reference model for the draft sixteen-bit CPU ISA."""

MASK16 = 0xFFFF

OP_NOP = 0x0
OP_ADD = 0x1
OP_SUB = 0x2
OP_AND = 0x3
OP_OR = 0x4
OP_XOR = 0x5
OP_ADDI = 0x6
OP_LD = 0x7
OP_ST = 0x8
OP_BEQ = 0x9
OP_JMP = 0xA
OP_HALT = 0xF


def encode_r(opcode: int, rd: int, rs: int, rt: int) -> int:
    return (opcode << 12) | (rd << 9) | (rs << 6) | (rt << 3)


def encode_i(opcode: int, rd: int, rs: int, imm6: int) -> int:
    return (opcode << 12) | (rd << 9) | (rs << 6) | (imm6 & 0x3F)


def encode_branch(opcode: int, offset12: int) -> int:
    return (opcode << 12) | (offset12 & 0xFFF)


class CPU:
    def __init__(self) -> None:
        self.regs = [0] * 8
        self.pc = 0
        self.flags = {"Z": 0, "N": 0, "C": 0, "V": 0}
        self.halted = False
        # Sparse word-valued RAM for the reference model
        self.data_memory: dict[int, int] = {}

    def _write(self, register: int, value: int) -> None:
        if register != 0:
            self.regs[register] = value & MASK16

    def _set_flags(self, result: int, carry: bool, overflow: bool) -> None:
        result &= MASK16
        #Z: bit result = 0, N: output number is negative, C: unsigned addition makes a carry, V: overflow occurs
        self.flags = {"Z": int(result == 0), "N": int(bool(result & 0x8000)),
                      "C": int(carry), "V": int(overflow)}

    def step(self, instruction: int) -> None:
        if self.halted:
            return
        #aligning values with ISA
        opcode = (instruction >> 12) & 0xF
        rd, rs, rt = (instruction >> 9) & 0x7, (instruction >> 6) & 0x7, (instruction >> 3) & 0x7
        
        #converting 6-bit immidiate value into a 16-bit value for ALU use
        imm6 = (instruction & 0x3F)
        if imm6 & 0x20:
            immidiate = imm6 - 0x40
        else:
            immidiate = imm6
        imm16 = immidiate & MASK16

        #left = RA, right = RB 
        left, right = self.regs[rs], self.regs[rt]
        self.pc = (self.pc + 2) & MASK16
        offset12 = (instruction & 0xFFF)

        if opcode == OP_NOP:
            return
        
        if opcode == OP_HALT:
            self.halted = True
            return
        
        if opcode == OP_ADD:
            raw = left + right
            result = raw & MASK16 #ensure 16 bit value
            overflow = not (left ^ right) & 0x8000 and (left ^ result) & 0x8000
            self._write(rd, result)
            self._set_flags(result, raw > MASK16, bool(overflow))
            return
        
        if opcode == OP_SUB:
            result = (left - right) & MASK16 #ensure 16 bit value
            overflow = (left ^ right) & (left ^ result) & 0x8000
            self._write(rd, result)
            self._set_flags(result, left >= right, bool(overflow))
            return
        
        if opcode in (OP_AND, OP_OR, OP_XOR):
            result = {OP_AND: left & right, OP_OR: left | right, OP_XOR: left ^ right}[opcode]
            self._write(rd, result)
            self._set_flags(result, False, False)
            return
        
        if opcode == OP_ADDI:
            raw = left + imm16
            result = raw & MASK16 #ensure 16 bit value
            overflow = not (left ^ imm16) & 0x8000 and (left ^ result) & 0x8000
            self._write(rd, result)
            self._set_flags(result, raw > MASK16, bool(overflow))
            return
        
        if opcode == OP_BEQ:
            # convert to 2's-comp negative number
            if offset12 & 0x800:
                offset12 -= 0x1000
            # if the values are zero execute branch (programmer will have to SUB before BEQ)
            if (self.flags["Z"] == 1):
                self.pc = (self.pc + offset12 * 2) & MASK16
            return 
        
        if opcode == OP_JMP:
            # convert to 2's-comp negative number
            if offset12 & 0x800:
                offset12 -= 0x1000

            self.pc = (self.pc + offset12 * 2) & MASK16
            return
       
        if opcode == OP_LD:
            # load memory location = RA + immidiate offset
            byteAddress = (left + imm16) & MASK16
            if (byteAddress & 1) or not (0x0000 <= byteAddress <= 0x7FFF):
                raise ValueError(f"Referencing illigal memory address: {byteAddress:#06x}")

            # .get used to execute safe memory pull
            retValue = self.data_memory.get(byteAddress, 0)
            self._write(rd, retValue)
            return
        
        if opcode == OP_ST:
            # store memory location = RA + immidiate offset
            byteAddress = (left + imm16) & MASK16
            if (byteAddress & 1) or not (0x0000 <= byteAddress <= 0x7FFF):
                raise ValueError(f"Referencing illigal memory address: {byteAddress:#06x}")
            
            # data -> memory at location RA + immidiate offset
            self.data_memory[byteAddress] = (self.regs[rd] & MASK16)
            return
        raise ValueError(f"unimplemented or illegal opcode: {opcode:#x}")