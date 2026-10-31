`timescale 1ns/1ps

module tb_execution_unit;
    logic clk = 1'b0;
    logic reset;
    logic [15:0] operand_a;
    logic [15:0] register_operand_b;
    logic [15:0] immediate;
    logic [2:0] alu_operation;
    logic use_immediate;
    logic flags_write;
    logic [15:0] result;
    logic zero;
    logic negative;
    logic carry;
    logic overflow;

    execution_unit dut (.*);

    always #5 clk = ~clk;

    task automatic expect_result(
        input logic [15:0] expected,
        input string       description
    );
        #1;
        if (result !== expected) begin
            $fatal(1, "%s: expected result %h, got %h",
                   description, expected, result);
        end
    endtask

    task automatic clock_and_expect_flags(
        input logic [3:0] expected,
        input string      description
    );
        logic [3:0] actual;
        @(posedge clk);
        #1;
        actual = {zero, negative, carry, overflow};
        if (actual !== expected) begin
            $fatal(1, "%s: expected ZNCV=%b, got ZNCV=%b",
                   description, expected, actual);
        end
    endtask

    initial begin
        reset = 1'b1;
        operand_a = 16'h0000;
        register_operand_b = 16'h0000;
        immediate = 16'h0000;
        alu_operation = 3'd0;
        use_immediate = 1'b0;
        flags_write = 1'b0;
        clock_and_expect_flags(4'b0000, "reset flags");

        // Register-register ADD selects register_operand_b.
        reset = 1'b0;
        operand_a = 16'h0002;
        register_operand_b = 16'h0003;
        immediate = 16'h0004;
        flags_write = 1'b1;
        expect_result(16'h0005, "register operand selection");
        clock_and_expect_flags(4'b0000, "ADD flags");

        // ADDI selects the sign-extended immediate input.
        use_immediate = 1'b1;
        expect_result(16'h0006, "immediate operand selection");

        // A subtract-to-zero updates the stored architectural flags.
        use_immediate = 1'b0;
        operand_a = 16'h0005;
        register_operand_b = 16'h0005;
        alu_operation = 3'd1;
        expect_result(16'h0000, "SUB result");
        clock_and_expect_flags(4'b1010, "SUB flags");

        // With flag writes disabled, ALU outputs may change while the stored
        // architectural flags retain their previous values.
        flags_write = 1'b0;
        operand_a = 16'h7FFF;
        register_operand_b = 16'h0001;
        alu_operation = 3'd0;
        expect_result(16'h8000, "overflowing ADD result");
        clock_and_expect_flags(4'b1010, "preserved flags");

        $display("execution-unit testbench: PASS");
        $finish;
    end
endmodule
