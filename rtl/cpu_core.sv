// Top-level integration for the single-cycle sixteen-bit CPU.
module cpu_core (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] instruction,
    output logic [15:0] instruction_address,
    input  logic [15:0] data_read_data,
    output logic [15:0] data_address,
    output logic [15:0] data_write_data,
    output logic        data_read_enable,
    output logic        data_write_enable,
    output logic        halted,
    output logic        access_fault,
    output logic        illegal_instruction
);
    logic [3:0]  opcode;
    logic [2:0]  read_addr_a;
    logic [2:0]  read_addr_b;
    logic [2:0]  write_addr;
    logic [15:0] immediate;
    logic [15:0] branch_offset;
    logic [2:0]  alu_operation;
    logic        use_immediate;
    logic        register_write;
    logic        memory_read;
    logic        memory_write;
    logic        flags_write;
    logic        branch_if_zero;
    logic        jump;
    logic        halt;

    logic [15:0] pc;
    logic        take_branch;

    logic [15:0] register_data_a;
    logic [15:0] register_data_b;
    logic [15:0] alu_result;
    logic        zero;
    logic        negative;
    logic        carry;
    logic        overflow;

    logic [15:0] memory_load_return;
    logic [15:0] writeback_register;

    logic core_active;

    assign instruction_address = pc;
    assign core_active = !halted;

    always_ff @ (posedge clk) begin
        if (reset) begin
            halted <= 1'b0;
        end else if (halt) begin
            halted <= 1'b1;
        end
    end

    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .write_addr(write_addr),
        .immediate(immediate),
        .branch_offset(branch_offset),
        .alu_operation(alu_operation),
        .use_immediate(use_immediate),
        .register_write(register_write),
        .memory_read(memory_read),
        .memory_write(memory_write),
        .flags_write(flags_write),
        .branch_if_zero(branch_if_zero),
        .jump(jump),
        .halt(halt),
        .illegal_instruction(illegal_instruction)
    );

    // branching logic
    always_comb begin
        if (jump) begin
            take_branch = 1'b1;
        end else if (branch_if_zero && zero)begin
            take_branch = 1'b1;
        end else begin
            take_branch = 1'b0;
        end

        // determine which value is written back to reg file
        if (memory_read) begin
            writeback_register = memory_load_return;
        end else begin
            writeback_register = alu_result;
        end
    end

    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .enable(core_active),
        .take_branch(take_branch),
        .branch_offset(branch_offset),
        .pc(pc)
    );

    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .read_data_a(register_data_a),
        .read_data_b(register_data_b),
        .write_enable(register_write && core_active),
        .write_addr(write_addr),
        .write_data(writeback_register)
    );

    execution_unit exec_unit (
        .clk(clk),
        .reset(reset),
        .operand_a(register_data_a),
        .register_operand_b(register_data_b),
        .immediate(immediate),
        .alu_operation(alu_operation),
        .use_immediate(use_immediate),
        .flags_write(flags_write && core_active),
        .result(alu_result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    data_memory_interface data_mem_unit (
        .memory_read(memory_read && core_active),
        .memory_write(memory_write && core_active),
        .effective_address(alu_result),
        .store_data(register_data_b),
        .memory_read_data(data_read_data),
        .memory_address(data_address),
        .memory_write_data(data_write_data),
        .memory_read_enable(data_read_enable),
        .memory_write_enable(data_write_enable),
        .load_data(memory_load_return),
        .access_fault(access_fault)
    );
endmodule
