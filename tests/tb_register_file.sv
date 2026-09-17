`timescale 1ns/1ps

module tb_register_file;
    logic        clk = 1'b0;
    logic        reset;
    logic [2:0]  read_addr_a;
    logic [2:0]  read_addr_b;
    logic [15:0] read_data_a;
    logic [15:0] read_data_b;
    logic        write_enable;
    logic [2:0]  write_addr;
    logic [15:0] write_data;

    register_file dut (
        .clk,
        .reset,
        .read_addr_a,
        .read_addr_b,
        .read_data_a,
        .read_data_b,
        .write_enable,
        .write_addr,
        .write_data
    );

    always #5 clk = ~clk;

    task automatic expect_equal(
        input logic [15:0] actual,
        input logic [15:0] expected,
        input string       description
    );
        if (actual !== expected) begin
            $fatal(1, "%s: expected %h, got %h", description, expected, actual);
        end
    endtask

    initial begin
        reset = 1'b1;
        read_addr_a = 3'd0;
        read_addr_b = 3'd0;
        write_enable = 1'b0;
        write_addr = 3'd0;
        write_data = 16'h0000;

        // Reset clears all storage, and r0 reads as zero.
        @(posedge clk);
        #1; // let the logic settle before read to prevent race conditions
        expect_equal(read_data_a, 16'h0000, "r0 must read as zero after reset");

        // A normal write is visible through either combinational read port.
        reset = 1'b0;
        write_enable = 1'b1;
        write_addr = 3'd3;
        write_data = 16'hBEEF;
        @(posedge clk);
        #1;
        read_addr_a = 3'd3;
        read_addr_b = 3'd3;
        #1;
        expect_equal(read_data_a, 16'hBEEF, "read port A must see r3 write");
        expect_equal(read_data_b, 16'hBEEF, "read port B must see r3 write");

        // A write to r0 must be ignored.
        write_addr = 3'd0;
        write_data = 16'hCAFE;
        @(posedge clk);
        #1;
        read_addr_a = 3'd0;
        #1;
        expect_equal(read_data_a, 16'h0000, "writes to r0 must be discarded");

        // write_enable gates writes.
        write_enable = 1'b0;
        write_addr = 3'd3;
        write_data = 16'h1234;
        @(posedge clk);
        #1;
        read_addr_a = 3'd3;
        #1;
        expect_equal(read_data_a, 16'hBEEF, "disabled write must not change r3");

        $display("register-file testbench: PASS");
        $finish;
    end
endmodule
