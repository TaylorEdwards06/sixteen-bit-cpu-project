# Sixteen-bit CPU Project

An educational 16-bit RISC-style CPU designed in SystemVerilog, supported by a small Python reference emulator. The project is built in public: each milestone produces a working, testable system.

## Current status

**Milestone 0 — architecture and emulator foundation.** The initial ISA, instruction encoder, ALU model, and executable smoke test are in place. RTL currently contains the combinational ALU that will become part of the datapath.

## Architecture at a glance

- 16-bit data and address width
- 8 general-purpose registers (`r0`–`r7`); `r0` is hard-wired to zero
- Fixed-width 16-bit instructions
- Condition flags: zero (`Z`), negative (`N`), carry (`C`), overflow (`V`)
- Separate program and data memory interfaces planned
- Memory-mapped peripherals planned: UART, LEDs, timer, interrupts

The ISA is intentionally compact, so the control path is understandable and easy to verify. See [the ISA specification](docs/isa.md).

## Repository layout

```
docs/       ISA decisions, roadmap, and future diagrams
emulator/   Reference model and instruction encoder
rtl/        Synthesizable SystemVerilog modules
tests/      Executable checks for the reference model and RTL
```

## Run the current smoke test

```sh
python3 tests/test_emulator.py
```

No third-party Python packages are required.

## Roadmap

1. ISA specification and reference emulator — in progress
2. Single-cycle CPU core and RTL verification
3. FPGA memory, LEDs, and UART demo
4. Timer, interrupts, and exceptions
5. Three-stage pipeline with forwarding and hazard handling
6. Documentation, benchmarks, and demo video

The detailed plan lives in [docs/roadmap.md](docs/roadmap.md).

## Project goals

This is a portfolio project focused on ISA design, datapath/control implementation, verification, and hardware/software co-design. It is not intended to be compatible with an existing architecture.
