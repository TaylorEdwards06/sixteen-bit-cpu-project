"""Dependency-free smoke checks for the reference CPU."""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from emulator.cpu import CPU, OP_ADD, OP_AND, OP_SUB, encode_r  # noqa: E402


def test_arithmetic_and_flags() -> None:
    cpu = CPU()
    cpu.regs[1], cpu.regs[2] = 0xFFFF, 1
    cpu.step(encode_r(OP_ADD, 3, 1, 2))
    assert cpu.regs[3] == 0
    assert cpu.flags == {"Z": 1, "N": 0, "C": 1, "V": 0}

    cpu.step(encode_r(OP_SUB, 4, 2, 1))
    assert cpu.regs[4] == 2
    assert cpu.flags["C"] == 0

    cpu.step(encode_r(OP_AND, 5, 1, 2))
    assert cpu.regs[5] == 1
    assert cpu.pc == 6


if __name__ == "__main__":
    test_arithmetic_and_flags()
    print("emulator smoke test: PASS")
