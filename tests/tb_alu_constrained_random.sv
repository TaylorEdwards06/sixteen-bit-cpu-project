`timescale 1ns/1ps

class alu_transaction;
    rand bit [15:0] a;
    rand bit [15:0] b;
    rand bit [2:0]  operation;

    constraint legal_operation {
        operation inside {3'd0, 3'd1, 3'd2, 3'd3, 3'd4};
    }
endclass

module tb_alu_constrained_random;
    localparam int unsigned DEFAULT_RANDOM_TRIALS = 5000;

    typedef struct packed {
        logic [15:0] result;
        logic        zero;
        logic        negative;
        logic        carry;
        logic        overflow;
    } expected_alu_t;

    logic [15:0] a;
    logic [15:0] b;
    logic [2:0]  operation;
    logic [15:0] result;
    logic        zero;
    logic        negative;
    logic        carry;
    logic        overflow;

    int unsigned operation_hits [0:4];
    int unsigned zero_hits;
    int unsigned negative_hits;
    int unsigned carry_hits;
    int unsigned overflow_hits;
    int unsigned random_trials;
    int unsigned total_checks;

    alu_transaction transaction;

    alu dut (.*);

    function automatic expected_alu_t reference_alu(
        input logic [15:0] reference_a,
        input logic [15:0] reference_b,
        input logic [2:0]  reference_operation
    );
        expected_alu_t expected;
        logic [16:0] extended;

        expected = '0;
        extended = '0;

        case (reference_operation)
            3'd0: begin
                extended = {1'b0, reference_a} + {1'b0, reference_b};
                expected.result = extended[15:0];
                expected.carry = extended[16];
                expected.overflow =
                    ~(reference_a[15] ^ reference_b[15]) &
                    (reference_a[15] ^ expected.result[15]);
            end
            3'd1: begin
                expected.result = reference_a - reference_b;
                expected.carry = (reference_a >= reference_b);
                expected.overflow =
                    (reference_a[15] ^ reference_b[15]) &
                    (reference_a[15] ^ expected.result[15]);
            end
            3'd2: expected.result = reference_a & reference_b;
            3'd3: expected.result = reference_a | reference_b;
            3'd4: expected.result = reference_a ^ reference_b;
            default: expected.result = '0;
        endcase

        expected.zero = (expected.result == 16'h0000);
        expected.negative = expected.result[15];
        return expected;
    endfunction

    task automatic drive_and_check(
        input logic [15:0] test_a,
        input logic [15:0] test_b,
        input logic [2:0]  test_operation
    );
        expected_alu_t expected;

        a = test_a;
        b = test_b;
        operation = test_operation;
        #1;

        expected = reference_alu(test_a, test_b, test_operation);
        if ({result, zero, negative, carry, overflow} !== expected) begin
            $fatal(1,
                   "ALU mismatch: op=%0d a=%h b=%h expected={%h,%b,%b,%b,%b} got={%h,%b,%b,%b,%b}",
                   test_operation, test_a, test_b,
                   expected.result, expected.zero, expected.negative,
                   expected.carry, expected.overflow,
                   result, zero, negative, carry, overflow);
        end

        operation_hits[test_operation]++;
        if (zero) zero_hits++;
        if (negative) negative_hits++;
        if (carry) carry_hits++;
        if (overflow) overflow_hits++;
        total_checks++;
    endtask

    initial begin
        transaction = new();
        random_trials = DEFAULT_RANDOM_TRIALS;
        void'($value$plusargs("TRIALS=%d", random_trials));

        a = '0;
        b = '0;
        operation = '0;
        foreach (operation_hits[index]) begin
            operation_hits[index] = 0;
        end
        zero_hits = 0;
        negative_hits = 0;
        carry_hits = 0;
        overflow_hits = 0;
        total_checks = 0;

        // Directed corners guarantee rare flag behavior is exercised even
        // when a particular random seed does not produce it.
        drive_and_check(16'h0000, 16'h0000, 3'd0);
        drive_and_check(16'hFFFF, 16'h0001, 3'd0);
        drive_and_check(16'h7FFF, 16'h0001, 3'd0);
        drive_and_check(16'h0000, 16'h0001, 3'd1);
        drive_and_check(16'h8000, 16'h0001, 3'd1);
        drive_and_check(16'hA5A5, 16'h5A5A, 3'd2);
        drive_and_check(16'h8000, 16'h0001, 3'd3);
        drive_and_check(16'hFFFF, 16'hFFFF, 3'd4);

        repeat (random_trials) begin
            if (!transaction.randomize()) begin
                $fatal(1, "ALU transaction randomization failed");
            end
            drive_and_check(transaction.a,
                            transaction.b,
                            transaction.operation);
        end

        for (int operation_index = 0; operation_index < 5;
             operation_index++) begin
            if (operation_hits[operation_index] == 0) begin
                $fatal(1, "operation %0d received no stimulus",
                       operation_index);
            end
        end

        if (zero_hits == 0 || negative_hits == 0 || carry_hits == 0 ||
            overflow_hits == 0) begin
            $fatal(1,
                   "flag coverage incomplete: Z=%0d N=%0d C=%0d V=%0d",
                   zero_hits, negative_hits, carry_hits, overflow_hits);
        end

        $display("ALU constrained-random testbench: PASS");
        $display("checks=%0d operations={%0d,%0d,%0d,%0d,%0d} flags={Z:%0d,N:%0d,C:%0d,V:%0d}",
                 total_checks,
                 operation_hits[0], operation_hits[1], operation_hits[2],
                 operation_hits[3], operation_hits[4],
                 zero_hits, negative_hits, carry_hits, overflow_hits);
        $finish;
    end
endmodule
