`timescale 1ns/1ps

module tb_cpu_core_arithmetic;
    logic        clk = 1'b0;
    logic        reset;
    logic [15:0] instruction;
    logic [15:0] instruction_address;
    logic [15:0] data_read_data;
    logic [15:0] data_address;
    logic [15:0] data_write_data;
    logic        data_read_enable;
    logic        data_write_enable;
    logic        halted;
    logic        access_fault;
    logic        illegal_instruction;

    cpu_core dut (.*);

    always #5 clk = ~clk;

    task automatic execute_and_expect_result(
        input logic [15:0] encoded_instruction,
        input logic [15:0] expected,
        input string       description
    );
        instruction = encoded_instruction;
        @(posedge clk);
        #1;
        if (dut.alu_result !== expected) begin
            $fatal(1, "%s: expected result %h, got %h",
                   description, expected, dut.alu_result);
        end
    endtask

    initial begin
        reset = 1'b1;
        instruction = 16'h0000;
        data_read_data = 16'h0000;
        @(posedge clk);
        #1;

        reset = 1'b0;

        // ADDI r1, r0, 5: r1 becomes 5.
        execute_and_expect_result(16'h6205, 16'h0005, "write r1");

        // ADDI r2, r1, -2: reading r1 proves the prior write occurred.
        execute_and_expect_result(16'h647E, 16'h0003,
                                  "read r1 and write r2");

        // ADD r3, r1, r2: 5 + 3 = 8.
        execute_and_expect_result(16'h1650, 16'h0008,
                                  "register-register add");

        // SUB r4, r3, r3: 8 - 8 = 0 and stores the zero flag.
        execute_and_expect_result(16'h28D8, 16'h0000,
                                  "subtract to zero");
        if (dut.zero !== 1'b1) begin
            $fatal(1, "subtract to zero: expected stored zero flag");
        end

        $display("cpu-core arithmetic testbench: PASS");
        $finish;
    end
endmodule
