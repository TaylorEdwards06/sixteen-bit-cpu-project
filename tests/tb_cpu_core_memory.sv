`timescale 1ns/1ps

module tb_cpu_core_memory;
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

    task automatic execute(input logic [15:0] encoded_instruction);
        instruction = encoded_instruction;
        @(posedge clk);
        #1;
    endtask

    initial begin
        reset = 1'b1;
        instruction = 16'h0000;
        data_read_data = 16'h0000;
        @(posedge clk);
        #1;

        reset = 1'b0;

        // Establish an address base and a value to store.
        execute(16'h6204); // ADDI r1, r0, 4
        execute(16'h6415); // ADDI r2, r0, 21

        // ST r2, [r1 + 2] should request a write of 21 to byte address 6.
        instruction = 16'h8442;
        #1;
        if (data_address !== 16'h0006 ||
            data_write_data !== 16'h0015 ||
            data_write_enable !== 1'b1 ||
            data_read_enable !== 1'b0 ||
            access_fault !== 1'b0) begin
            $fatal(1, "aligned store produced incorrect memory signals");
        end
        @(posedge clk);
        #1;

        // LD r3, [r1 + 2] should request a read from byte address 6.
        data_read_data = 16'hBEEF;
        instruction = 16'h7642;
        #1;
        if (data_address !== 16'h0006 ||
            data_read_enable !== 1'b1 ||
            data_write_enable !== 1'b0 ||
            access_fault !== 1'b0) begin
            $fatal(1, "aligned load produced incorrect memory signals");
        end
        @(posedge clk);
        #1;

        // ADD r4, r3, r0 exposes the value written back by the load.
        instruction = 16'h18C0;
        #1;
        if (dut.alu_result !== 16'hBEEF) begin
            $fatal(1, "load writeback: expected BEEF, got %h",
                   dut.alu_result);
        end

        $display("cpu-core memory testbench: PASS");
        $finish;
    end
endmodule
