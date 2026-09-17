"""Executable behavioral contracts for the emulator data-memory task."""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from emulator.cpu import CPU, OP_LD, OP_ST, encode_i  # noqa: E402


def test_load_reads_a_word_and_preserves_flags() -> None:
    cpu = CPU()
    cpu.regs[1] = 0x0010
    cpu.data_memory[0x000E] = 0xBEEF
    cpu.flags = {"Z": 1, "N": 0, "C": 1, "V": 0}
    cpu.step(encode_i(OP_LD, 2, 1, -2))
    assert cpu.regs[2] == 0xBEEF
    assert cpu.flags == {"Z": 1, "N": 0, "C": 1, "V": 0}
    assert cpu.pc == 2


def test_store_writes_a_word_and_preserves_flags() -> None:
    cpu = CPU()
    cpu.regs[1] = 0x0010
    cpu.regs[2] = 0x1234
    cpu.flags = {"Z": 0, "N": 1, "C": 0, "V": 1}
    # For ST, the immediate-format rd field selects the source register.
    cpu.step(encode_i(OP_ST, 2, 1, 2))
    assert cpu.data_memory[0x0012] == 0x1234
    assert cpu.flags == {"Z": 0, "N": 1, "C": 0, "V": 1}
    assert cpu.pc == 2


def test_uninitialized_valid_ram_reads_as_zero() -> None:
    cpu = CPU()
    cpu.regs[1] = 0x0010
    cpu.step(encode_i(OP_LD, 2, 1, 0))
    assert cpu.regs[2] == 0


def test_unaligned_access_raises_value_error() -> None:
    cpu = CPU()
    cpu.regs[1] = 1
    try:
        cpu.step(encode_i(OP_LD, 2, 1, 0))
    except ValueError:
        pass
    else:
        raise AssertionError("unaligned LD must raise ValueError")


def test_unmapped_access_raises_value_error() -> None:
    cpu = CPU()
    cpu.regs[1] = 0x8004
    try:
        cpu.step(encode_i(OP_LD, 2, 1, 0))
    except ValueError:
        pass
    else:
        raise AssertionError("unmapped LD must raise ValueError")


if __name__ == "__main__":
    test_load_reads_a_word_and_preserves_flags()
    test_store_writes_a_word_and_preserves_flags()
    test_uninitialized_valid_ram_reads_as_zero()
    test_unaligned_access_raises_value_error()
    test_unmapped_access_raises_value_error()
    print("memory-access contracts: PASS")
