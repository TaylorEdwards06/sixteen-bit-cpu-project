#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if [[ ! -d work ]]; then
    vlib work
fi

vlog -sv \
    rtl/alu.sv \
    rtl/flag_register.sv \
    rtl/execution_unit.sv \
    rtl/register_file.sv \
    rtl/instruction_decoder.sv \
    rtl/program_counter.sv \
    rtl/data_memory_interface.sv \
    rtl/cpu_core.sv \
    tests/tb_*.sv

testbenches=(
    tb_register_file
    tb_instruction_decoder
    tb_program_counter
    tb_data_memory_interface
    tb_flag_register
    tb_execution_unit
    tb_cpu_core_control
    tb_cpu_core_arithmetic
    tb_cpu_core_branch
    tb_cpu_core_memory
    tb_cpu_core_halt
    tb_cpu_core_program
)

for testbench in "${testbenches[@]}"; do
    echo "Running $testbench"
    vsim -c "$testbench" \
        -do 'onerror {quit -code 1 -f}; run -all; quit -code 0 -f'
done

echo "All RTL testbenches passed."