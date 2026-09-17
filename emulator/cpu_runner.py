"""Reference """

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from emulator.cpu import encode_i, encode_r, OP_ADDI, OP_SUB, OP_ST, OP_LD, OP_HALT, CPU  # noqa: E402

PROGRAM = [
    encode_i(OP_ADDI, 1, 0, 12),
    encode_i(OP_ADDI, 2, 0, 4),
    encode_r(OP_SUB, 1, 1, 2),
    encode_i(OP_ST, 1, 0, 0),
    encode_i(OP_LD, 3, 0, 0),
    OP_HALT << 12, #encodes HALT command as 0xF000
    ]

def run_program(program, max_steps=100) -> CPU:
    curr_step = 1
    cpu = CPU()
    while not cpu.halted:
        if (curr_step > max_steps):
            raise ValueError("Max steps exceeded")
        
        instruction_index = cpu.pc // 2 #fetch next instruction
        if instruction_index >= len(program):
            raise ValueError("PC moved outside of the program")
        
        instruction = program[instruction_index]
        print(f"pc: {cpu.pc} | registers: {cpu.regs} | flags: {cpu.flags}")
        cpu.step(instruction)
        curr_step += 1

    print(f"final registers: {cpu.regs} | data memory: {cpu.data_memory}")
    return cpu

if __name__ == "__main__":
    run_program(PROGRAM, 7)
    print("CPU program run test PASS")