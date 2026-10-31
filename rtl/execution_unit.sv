// ALU datapath and architectural condition-flag storage.
module execution_unit (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] operand_a,
    input  logic [15:0] register_operand_b,
    input  logic [15:0] immediate,
    input  logic [2:0]  alu_operation,
    input  logic        use_immediate,
    input  logic        flags_write,
    output logic [15:0] result,
    output logic        zero,
    output logic        negative,
    output logic        carry,
    output logic        overflow
);
    logic [15:0] alu_operand_b;
    logic        alu_zero;
    logic        alu_negative;
    logic        alu_carry;
    logic        alu_overflow;

    always_comb begin
        if (use_immediate) begin
            alu_operand_b = immediate;
        end else begin
            alu_operand_b = register_operand_b;
        end
    end

    alu alu_instance (
        .a(operand_a),
        .b(alu_operand_b),
        .operation(alu_operation),
        .result(result),
        .zero(alu_zero),
        .negative(alu_negative),
        .carry(alu_carry),
        .overflow(alu_overflow)
    );

    flag_register flag_storage (
        .clk(clk),
        .reset(reset),
        .write_enable(flags_write),
        .zero_in(alu_zero),
        .negative_in(alu_negative),
        .carry_in(alu_carry),
        .overflow_in(alu_overflow),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );
endmodule
