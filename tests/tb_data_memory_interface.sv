`timescale 1ns/1ps

module tb_data_memory_interface;
    logic        memory_read;
    logic        memory_write;
    logic [15:0] effective_address;
    logic [15:0] store_data;
    logic [15:0] memory_read_data;
    logic [15:0] memory_address;
    logic [15:0] memory_write_data;
    logic        memory_read_enable;
    logic        memory_write_enable;
    logic [15:0] load_data;
    logic        access_fault;

    data_memory_interface dut (.*);

    task automatic expect_equal(
        input logic [15:0] actual,
        input logic [15:0] expected,
        input string       description
    );
        if (actual !== expected) begin
            $fatal(1, "%s: expected %h, got %h", description, expected, actual);
        end
    endtask

    task automatic expect_controls(
        input logic [2:0] expected,
        input string      description
    );
        logic [2:0] actual;
        actual = {memory_read_enable, memory_write_enable, access_fault};
        if (actual !== expected) begin
            $fatal(1, "%s controls: expected %b, got %b",
                   description, expected, actual);
        end
    endtask

    initial begin
        memory_read = 1'b0;
        memory_write = 1'b0;
        effective_address = 16'h0010;
        store_data = 16'hCAFE;
        memory_read_data = 16'hBEEF;
        #1;
        expect_equal(memory_address, 16'h0010, "idle address");
        expect_equal(memory_write_data, 16'hCAFE, "idle store data");
        expect_equal(load_data, 16'h0000, "idle load data");
        expect_controls(3'b000, "idle");

        // Valid loads expose memory data combinationally in the same cycle.
        memory_read = 1'b1;
        #1;
        expect_equal(load_data, 16'hBEEF, "valid load data");
        expect_controls(3'b100, "valid load");

        // Valid stores forward the selected register value to memory.
        memory_read = 1'b0;
        memory_write = 1'b1;
        #1;
        expect_equal(memory_write_data, 16'hCAFE, "valid store data");
        expect_equal(load_data, 16'h0000, "store load data");
        expect_controls(3'b010, "valid store");

        // Word accesses use byte addresses and must be even-aligned.
        effective_address = 16'h0011;
        #1;
        expect_controls(3'b001, "misaligned store");

        memory_read = 1'b1;
        memory_write = 1'b0;
        #1;
        expect_equal(load_data, 16'h0000, "misaligned load data");
        expect_controls(3'b001, "misaligned load");

        // Decoder controls should never conflict, but fail safely if they do.
        effective_address = 16'h0010;
        memory_write = 1'b1;
        #1;
        expect_equal(load_data, 16'h0000, "conflicting request load data");
        expect_controls(3'b001, "conflicting requests");

        $display("data-memory-interface testbench: PASS");
        $finish;
    end
endmodule
