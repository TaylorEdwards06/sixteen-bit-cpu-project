# Milestone 1 workbook: single-cycle RTL CPU

This guided-build milestone turns the Python reference model into a
synthesizable, single-cycle SystemVerilog CPU. Complete and test one module at
a time; make each completed task its own commit.

## RTL contract: separate instruction and data memory

The core will use independent, combinational instruction and data-memory read
interfaces. This lets a single clock cycle fetch an instruction while an
`LD` or `ST` uses data memory. The future FPGA wrapper will supply instruction
ROM and data RAM behind these interfaces.

## Task 1: register file

Implement `rtl/register_file.sv` against `tests/tb_register_file.sv`.

- The file has eight 16-bit storage locations, addressed by three-bit register
  indices.
- `reset` is synchronous and active-high: on a rising clock edge with
  `reset == 1`, every stored register value becomes zero.
- A normal write happens only on a rising edge when `write_enable == 1` and
  `write_addr != 0`.
- `read_data_a` and `read_data_b` are combinational reads of the selected
  registers.
- Register `r0` must always read as `16'h0000`; writes targeting it are
  discarded.

The testbench checks reset, both read ports, an ordinary write, the hard-wired
zero register, and the write-enable gate.

On the computer with ModelSim or Questa, run:

```sh
vlib work
vlog -sv rtl/register_file.sv tests/tb_register_file.sv
vsim -c tb_register_file -do "run -all; quit -f"
```

Expected output:

```text
register-file testbench: PASS
```

To inspect the waveform interactively, use `vsim tb_register_file` instead of
the final command, then run `add wave -r *` and `run -all` at the simulator
prompt.
