# Development roadmap

## Milestone 0: executable architecture

- [x] Define initial register set, instruction formats, and arithmetic flags
- [x] Implement a Python reference model for arithmetic instructions
- [x] Add a smoke test and instruction encoder
- [x] Implement the RTL ALU
- [ ] Add every instruction to the emulator
- [ ] Write a short assembly demo and trace output

## Milestone 1: single-cycle CPU

- Build instruction decoder, register file, PC logic, and data-memory interface
- Connect the ALU and define flag writeback behavior
- Create SystemVerilog testbenches and compare RTL state against the emulator
- Run a small arithmetic and branch program end to end

## Milestone 2: FPGA bring-up

- Select a development board and record its toolchain/version
- Add on-chip ROM/RAM and a clock/reset wrapper
- Add memory-mapped LEDs and UART transmit
- Demonstrate a serial "hello" and register/ALU program

## Milestone 3: system features

- Add timer peripheral and maskable interrupt path
- Define illegal-instruction and divide-by-zero exceptions
- Document reset and interrupt timing

## Milestone 4: pipelined microarchitecture

- Split the core into fetch, decode, and execute/writeback stages
- Add branch flush behavior
- Add data forwarding and load-use stalls
- Measure clock frequency, area, and CPI before/after the change

## Milestone 5: portfolio polish

- Publish block diagrams and waveform screenshots
- Record FPGA utilization and maximum clock frequency
- Add test coverage summary and reproducible build instructions
- Record a concise hardware demonstration video
