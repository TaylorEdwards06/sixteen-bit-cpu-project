# ISA specification (draft 0.1)

## Programmer-visible state

The CPU has eight 16-bit registers. `r0` always reads as zero; writes to it are discarded. `r1` through `r7` are general purpose. The program counter (`PC`) is a 16-bit byte address and advances by two for every instruction unless a control-transfer instruction changes it.

Arithmetic instructions update the `Z`, `N`, `C`, and `V` flags. Logical instructions update `Z` and `N` and clear `C` and `V`.

## Instruction formats

All instructions are one 16-bit word.

### Register format

```
15          12 11   9 8    6 5    3 2      0
+--------------+------+------+------+--------+
|    opcode    |  rd  |  rs  |  rt  |  000   |
+--------------+------+------+------+--------+
```

### Immediate format

```
15          12 11   9 8    6 5                 0
+--------------+------+------+------------------+
|    opcode    |  rd  |  rs  |      imm6        |
+--------------+------+------+------------------+
```

`imm6` is sign-extended for arithmetic and address offsets.

### Branch format

```
15          12 11                         0
+--------------+----------------------------+
|    opcode    |       offset12             |
+--------------+----------------------------+
```

The signed offset is in instruction words and is applied after the PC advances.

## Opcodes

| Opcode | Mnemonic | Description |
|---:|---|---|
| `0x0` | `NOP` | No operation |
| `0x1` | `ADD rd, rs, rt` | `rd = rs + rt` |
| `0x2` | `SUB rd, rs, rt` | `rd = rs - rt` |
| `0x3` | `AND rd, rs, rt` | Bitwise AND |
| `0x4` | `OR rd, rs, rt` | Bitwise OR |
| `0x5` | `XOR rd, rs, rt` | Bitwise XOR |
| `0x6` | `ADDI rd, rs, imm6` | Add signed immediate |
| `0x7` | `LD rd, [rs + imm6]` | Load 16-bit word |
| `0x8` | `ST rt, [rs + imm6]` | Store 16-bit word |
| `0x9` | `BEQ offset12` | Branch if `Z` is set |
| `0xA` | `JMP offset12` | Unconditional PC-relative branch |
| `0xF` | `HALT` | Stop execution (emulator/testing only) |

Reserved opcodes deliberately trap as illegal instructions in a later milestone.

## Memory map (planned)

| Address | Device |
|---:|---|
| `0x0000–0x7FFF` | Program/data RAM |
| `0x8000` | UART transmit register |
| `0x8002` | LED output register |
| `0x8010` | Timer control/status |

## Open decisions

- Exact reset-vector address and RAM/ROM split
- Byte accesses versus word-only data memory
- Interrupt vector layout and return-from-interrupt encoding
