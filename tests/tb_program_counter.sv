`timescale 1ns/1ps

module tb_program_counter;
    logic        clk = 1'b0;
    logic        reset;
    logic        enable;
    logic        take_branch;
    logic [15:0] branch_offset;
    logic [15:0] pc;

    program_counter dut (.*);

    always #5 clk = ~clk;

    task automatic clock_and_expect(
        input logic [15:0] expected,
        input string       description
    );
        @(posedge clk);
        #1;
        if (pc !== expected) begin
            $fatal(1, "%s: expected %h, got %h", description, expected, pc);
        end
    endtask

    initial begin
        reset = 1'b1;
        enable = 1'b0;
        take_branch = 1'b0;
        branch_offset = 16'h0000;
        clock_and_expect(16'h0000, "reset vector");

        // Instructions are 16 bits, so sequential execution adds two bytes.
        reset = 1'b0;
        enable = 1'b1;
        clock_and_expect(16'h0002, "sequential PC increment");

        // A disabled PC holds its current value.
        enable = 1'b0;
        clock_and_expect(16'h0002, "disabled PC hold");

        // Branch offsets are signed instruction-word counts and are applied
        // after the ordinary PC + 2 increment.
        enable = 1'b1;
        take_branch = 1'b1;
        branch_offset = 16'h0003;
        clock_and_expect(16'h000A, "forward branch");

        branch_offset = 16'hFFFE;
        clock_and_expect(16'h0008, "backward branch");

        // Sixteen-bit PC arithmetic wraps naturally.
        reset = 1'b1;
        clock_and_expect(16'h0000, "reset before wraparound");
        reset = 1'b0;
        branch_offset = 16'hFFFE;
        clock_and_expect(16'hFFFE, "branch wraparound");

        // Reset has priority over enable and branch control.
        reset = 1'b1;
        clock_and_expect(16'h0000, "reset priority");

        $display("program-counter testbench: PASS");
        $finish;
    end
endmodule
