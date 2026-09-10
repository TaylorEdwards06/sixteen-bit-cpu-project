"""Reference model for the draft sixteen-bit CPU ISA."""

MASK16 = 0xFFFF

OP_NOP = 0x0
OP_ADD = 0x1
OP_SUB = 0x2
OP_AND = 0x3
OP_OR = 0x4
OP_XOR = 0x5
OP_ADDI = 0x6
OP_HALT = 0xF


def encode_r(opcode: int, rd: int, rs: int, rt: int) -> int:
    return (opcode << 12) | (rd << 9) | (rs << 6) | (rt << 3)


class CPU:
    def __init__(self) -> None:
        self.regs = [0] * 8
        self.pc = 0
        self.flags = {"Z": 0, "N": 0, "C": 0, "V": 0}
        self.halted = False

    def _write(self, register: int, value: int) -> None:
        if register != 0:
            self.regs[register] = value & MASK16

    def _set_flags(self, result: int, carry: bool, overflow: bool) -> None:
        result &= MASK16
        self.flags = {"Z": int(result == 0), "N": int(bool(result & 0x8000)),
                      "C": int(carry), "V": int(overflow)}

    def step(self, instruction: int) -> None:
        if self.halted:
            return
        opcode = (instruction >> 12) & 0xF
        rd, rs, rt = (instruction >> 9) & 0x7, (instruction >> 6) & 0x7, (instruction >> 3) & 0x7
        left, right = self.regs[rs], self.regs[rt]
        self.pc = (self.pc + 2) & MASK16

        if opcode == OP_NOP:
            return
        if opcode == OP_HALT:
            self.halted = True
            return
        if opcode == OP_ADD:
            raw = left + right
            result = raw & MASK16
            overflow = not (left ^ right) & 0x8000 and (left ^ result) & 0x8000
            self._write(rd, result)
            self._set_flags(result, raw > MASK16, bool(overflow))
            return
        if opcode == OP_SUB:
            result = (left - right) & MASK16
            overflow = bool((left ^ right) & (left ^ result) & 0x8000)
            self._write(rd, result)
            self._set_flags(result, left >= right, overflow)
            return
        if opcode in (OP_AND, OP_OR, OP_XOR):
            result = {OP_AND: left & right, OP_OR: left | right, OP_XOR: left ^ right}[opcode]
            self._write(rd, result)
            self._set_flags(result, False, False)
            return
        raise ValueError(f"unimplemented or illegal opcode: {opcode:#x}")
