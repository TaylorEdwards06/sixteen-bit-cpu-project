`timescale 1ns/1ps

module tb_flag_register;
    logic clk = 1'b0;
    logic reset;
    logic write_enable;
    logic zero_in;
    logic negative_in;
    logic carry_in;
    logic overflow_in;
    logic zero;
    logic negative;
    logic carry;
    logic overflow;

    flag_register dut (.*);

    always #5 clk = ~clk;

    task automatic clock_and_expect(
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
        write_enable = 1'b1;
        zero_in = 1'b1;
        negative_in = 1'b1;
        carry_in = 1'b1;
        overflow_in = 1'b1;
        clock_and_expect(4'b0000, "reset priority");

        // An enabled clock edge captures every incoming ALU flag.
        reset = 1'b0;
        zero_in = 1'b1;
        negative_in = 1'b0;
        carry_in = 1'b1;
        overflow_in = 1'b0;
        clock_and_expect(4'b1010, "enabled flag write");

        // Instructions such as LD and ST preserve the stored flags.
        write_enable = 1'b0;
        zero_in = 1'b0;
        negative_in = 1'b1;
        carry_in = 1'b0;
        overflow_in = 1'b1;
        clock_and_expect(4'b1010, "disabled flag write");

        write_enable = 1'b1;
        clock_and_expect(4'b0101, "second enabled flag write");

        $display("flag-register testbench: PASS");
        $finish;
    end
endmodule
