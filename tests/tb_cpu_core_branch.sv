`timescale 1ns/1ps

module tb_cpu_core_branch;
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

    task automatic execute_and_expect_pc(
        input logic [15:0] encoded_instruction,
        input logic [15:0] expected_pc,
        input string       description
    );
        instruction = encoded_instruction;
        @(posedge clk);
        #1;
        if (instruction_address !== expected_pc) begin
            $fatal(1, "%s: expected PC %h, got %h",
                   description, expected_pc, instruction_address);
        end
    endtask

    initial begin
        reset = 1'b1;
        instruction = 16'h0000;
        data_read_data = 16'h0000;
        @(posedge clk);
        #1;

        reset = 1'b0;

        // ADDI r1, r0, 1 clears the stored zero flag and advances to PC 2.
        execute_and_expect_pc(16'h6201, 16'h0002, "prepare nonzero flag");

        // With Z clear, BEQ +2 is not taken and advances normally to PC 4.
        execute_and_expect_pc(16'h9002, 16'h0004, "BEQ not taken");

        // SUB r2, r1, r1 stores Z=1 and advances normally to PC 6.
        execute_and_expect_pc(16'h2448, 16'h0006, "prepare zero flag");
        if (dut.zero !== 1'b1) begin
            $fatal(1, "prepare zero flag: expected stored zero flag");
        end

        // With Z set, BEQ +2 branches from PC 6 to PC 12.
        execute_and_expect_pc(16'h9002, 16'h000C, "BEQ taken");

        // Clear Z again, then verify a negative-offset BEQ is also not taken.
        execute_and_expect_pc(16'h6401, 16'h000E, "clear zero flag");
        execute_and_expect_pc(16'h9FFE, 16'h0010,
                              "negative BEQ not taken");

        $display("cpu-core branch testbench: PASS");
        $finish;
    end
endmodule
