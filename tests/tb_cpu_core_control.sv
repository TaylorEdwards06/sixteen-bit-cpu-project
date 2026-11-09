`timescale 1ns/1ps

module tb_cpu_core_control;
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

    task automatic clock_and_expect_pc(
        input logic [15:0] expected,
        input string       description
    );
        @(posedge clk);
        #1;
        if (instruction_address !== expected) begin
            $fatal(1, "%s: expected PC %h, got %h",
                   description, expected, instruction_address);
        end
    endtask

    initial begin
        reset = 1'b1;
        instruction = 16'h0000;
        data_read_data = 16'h0000;
        clock_and_expect_pc(16'h0000, "reset");

        // NOP advances from byte address 0 to byte address 2.
        reset = 1'b0;
        instruction = 16'h0000;
        clock_and_expect_pc(16'h0002, "sequential instruction");

        // JMP +2 advances past the instruction, then adds two words:
        // 0x0002 + 2 + (2 * 2) = 0x0008.
        instruction = 16'hA002;
        clock_and_expect_pc(16'h0008, "forward jump");

        // JMP -2 uses a sign-extended offset:
        // 0x0008 + 2 + (-2 * 2) = 0x0006.
        instruction = 16'hAFFE;
        clock_and_expect_pc(16'h0006, "backward jump");

        $display("cpu-core control testbench: PASS");
        $finish;
    end
endmodule
