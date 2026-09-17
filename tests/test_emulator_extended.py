"""Executable behavioral contracts for the next emulator tasks.

Run this file directly while implementing each task.  It will fail until the
corresponding TODO in ``emulator/cpu.py`` is complete; that is intentional.
No third-party test runner is needed.
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from emulator.cpu import (  # noqa: E402
    CPU,
    OP_ADDI,
    OP_BEQ,
    OP_JMP,
    encode_branch,
    encode_i,
)


def test_addi_sign_extension_and_flags() -> None:
    cpu = CPU()
    cpu.regs[1] = 3
    cpu.step(encode_i(OP_ADDI, 2, 1, -4))
    assert cpu.regs[2] == 0xFFFF
    assert cpu.flags == {"Z": 0, "N": 1, "C": 0, "V": 0}
    assert cpu.pc == 2


def test_addi_discards_writes_to_r0() -> None:
    cpu = CPU()
    cpu.step(encode_i(OP_ADDI, 0, 0, 1))
    assert cpu.regs[0] == 0


def test_beq_uses_post_increment_pc_and_word_offsets() -> None:
    cpu = CPU()
    cpu.flags["Z"] = 1
    cpu.step(encode_branch(OP_BEQ, 2))
    assert cpu.pc == 6  # (PC + 2) + (2 words * 2 bytes)

    cpu = CPU()
    cpu.flags["Z"] = 0
    cpu.step(encode_branch(OP_BEQ, -1))
    assert cpu.pc == 2


def test_jmp_supports_negative_offsets() -> None:
    cpu = CPU()
    cpu.pc = 8
    cpu.step(encode_branch(OP_JMP, -2))
    assert cpu.pc == 6  # (8 + 2) + (-2 words * 2 bytes)


if __name__ == "__main__":
    test_addi_sign_extension_and_flags()
    test_addi_discards_writes_to_r0()
    test_beq_uses_post_increment_pc_and_word_offsets()
    test_jmp_supports_negative_offsets()
    print("extended emulator contracts: PASS")
