# Sixteen-bit CPU Project

An educational 16-bit RISC-style CPU implemented in SystemVerilog, with a
Python reference emulator and focused RTL testbenches. The project explores
instruction-set design, datapath and control integration, memory interfaces,
and hardware verification.

## Current status

**Milestone 1 — single-cycle CPU: complete.**

The repository contains a working single-cycle CPU core that executes
arithmetic, logical, memory, branch, jump, and halt instructions. The complete
core has been exercised with an end-to-end program using testbench instruction
ROM and data RAM models.

That program:

- Loops through `3 + 2 + 1` to produce `6`
- Stores the result in data memory
- Loads it into another register
- Verifies it with subtraction and a conditional branch
- Skips an instruction and halts at the expected address

The Python reference model reaches the same final state: PC `0x0018`, memory
word `0x0000` equal to `0x0006`, `r3` equal to `0x0006`, and `r5` unchanged.

## Architecture

- 16-bit data and address width
- Eight 16-bit registers (`r0`–`r7`)
- `r0` hard-wired to zero
- Fixed-width 16-bit instructions
- Byte-addressed program counter; each instruction occupies two bytes
- Signed immediate and PC-relative branch offsets
- Condition flags: zero (`Z`), negative (`N`), carry (`C`), and overflow (`V`)
- Separate instruction and data-memory interfaces
- Aligned 16-bit loads and stores at even byte addresses
- Stored HALT state that freezes architectural updates until reset

The current instruction set includes:

- `NOP`
- `ADD`, `SUB`, `AND`, `OR`, and `XOR`
- `ADDI`
- `LD` and `ST`
- `BEQ` and `JMP`
- `HALT`

See [the ISA specification](docs/isa.md) for instruction formats, opcodes, and
memory semantics.

## RTL organization

The single-cycle core in `rtl/cpu_core.sv` integrates:

- `instruction_decoder.sv` — instruction fields and control signals
- `program_counter.sv` — sequential and PC-relative control flow
- `register_file.sv` — two read ports, one write port, and hard-wired `r0`
- `alu.sv` — arithmetic, logical operations, and combinational flags
- `flag_register.sv` — architectural condition-flag storage
- `execution_unit.sv` — operand selection, ALU, and stored flags
- `data_memory_interface.sv` — aligned load/store boundary and access faults

The core uses combinational instruction and data reads with clocked PC,
register, flag, memory-write, and HALT state.

## Repository layout

```text
docs/       ISA specification and development roadmap
emulator/   Python reference CPU and instruction encoders
rtl/        Synthesizable SystemVerilog modules
tests/      Python contracts and SystemVerilog testbenches
```

## Verification

### Python reference model

No third-party Python packages are required.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_emulator.py
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_emulator_extended.py
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_memory_access.py
```

These tests cover arithmetic, immediate operations, flags, control flow,
loads, stores, alignment, and invalid memory accesses.

### SystemVerilog RTL

The RTL testbenches target ModelSim or Questa. With `vlib`, `vlog`, and `vsim`
on `PATH`, run the complete regression with one command:

```sh
./tests/run_all_rtl_tests.sh
```

The script creates the ModelSim work library when needed, compiles the complete
design and test suite, stops on the first failure, and returns a nonzero exit
status when compilation or simulation fails.

The core-level tests build progressively from PC/decode control through
arithmetic writeback, conditional branching, data memory, HALT behavior, and
the complete program.

## Roadmap

The next milestone is FPGA bring-up:

1. Select a development board and toolchain.
2. Add synthesizable instruction ROM and data RAM.
3. Add a clock/reset wrapper.
4. Connect memory-mapped LEDs and UART transmit.
5. Run a small program on hardware.

The information needed to begin is listed in
[the FPGA bring-up plan](docs/fpga-bring-up.md).

Later milestones add a timer, interrupts and exceptions, a three-stage
pipeline, forwarding, hazard handling, and portfolio-oriented documentation.
See [the detailed roadmap](docs/roadmap.md).

## Project goals

This is a portfolio project focused on computer architecture,
hardware/software co-design, verification, and FPGA implementation. The ISA is
intentionally compact so that the complete control and datapath behavior remain
understandable and testable.
