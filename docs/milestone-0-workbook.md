# Milestone 0 workbook: complete the reference emulator

This is a guided-build checkpoint.  The tests describe the observable
behavior; implement one task at a time in `emulator/cpu.py`, then run the
corresponding executable test file.  Keep each task in its own commit.

## Starting point

The emulator already executes register ALU instructions (`ADD`, `SUB`, `AND`,
`OR`, and `XOR`) and `HALT`.  The committed smoke test must continue to pass:

```sh
python3 tests/test_emulator.py
```

## Task 1: immediate arithmetic

Implement `encode_i` and `ADDI`.

- `imm6` is a signed two's-complement number in the range -32 through 31.
- Addition wraps to 16 bits and updates `Z`, `N`, `C`, and `V` exactly like
  `ADD`.
- Writing `r0` is discarded, but flags still reflect the computed result.

Check it with:

```sh
python3 tests/test_emulator_extended.py
```

Initially that command fails at `encode_i`; complete this task before moving
on.  The branch checks will then remain red until Task 2.

## Task 2: control flow

Implement `encode_branch`, `BEQ`, and `JMP`.

- `offset12` is a signed two's-complement number in instruction words.
- `step()` advances the PC first.  A taken branch sets the PC to the advanced
  PC plus `offset12 * 2`; a non-taken `BEQ` leaves the advanced PC unchanged.
- `BEQ` reads the existing `Z` flag and does not modify any flags.
- `JMP` is unconditional and does not modify flags.

When both tasks are complete, the extended contract file passes.

## Task 3: implement the data-memory contract

The following behavior is now decided and captured in
`tests/test_memory_access.py`:

1. Data memory uses byte addresses with 16-bit aligned word accesses.
2. Valid RAM is `0x0000–0x7FFF`; unwritten words read as zero.
3. Unaligned or unmapped access raises `ValueError` in the emulator.
4. `LD` and `ST` preserve all flags.

`ST` uses the immediate-format `rd` field as its source-register field, as
specified in `docs/isa.md`. Implement one instruction at a time and run:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_memory_access.py
```

After it passes, add a short program/trace runner as the next small,
reviewable change set.
