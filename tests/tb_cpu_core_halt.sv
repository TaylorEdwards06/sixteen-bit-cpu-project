`timescale 1ns/1ps

module tb_cpu_core_halt;
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

    task automatic clock_once;
        @(posedge clk);
        #1;
    endtask

    initial begin
        reset = 1'b1;
        instruction = 16'h0000;
        data_read_data = 16'h0000;
        clock_once();

        reset = 1'b0;

        // ADDI r1, r0, 1 establishes observable register and flag state.
        instruction = 16'h6201;
        clock_once();
        if (instruction_address !== 16'h0002 || dut.zero !== 1'b0) begin
            $fatal(1, "setup instruction produced incorrect state");
        end

        // HALT advances from PC 2 to PC 4 on its own clock edge.
        instruction = 16'hF000;
        clock_once();
        if (halted !== 1'b1 || instruction_address !== 16'h0004) begin
            $fatal(1, "HALT did not latch or advance PC exactly once");
        end

        // This ADDI would change r1 from 1 to 2 if register writes continued.
        instruction = 16'h6241;
        clock_once();
        clock_once();
        if (instruction_address !== 16'h0004 ||
            halted !== 1'b1 ||
            dut.register_data_a !== 16'h0001) begin
            $fatal(1, "halted CPU changed PC, HALT state, or register state");
        end

        // SUB r0, r0, r0 would set Z if flag writes continued.
        instruction = 16'h2000;
        clock_once();
        if (dut.zero !== 1'b0) begin
            $fatal(1, "halted CPU updated condition flags");
        end

        // ST r1, [r0 + 0] must not issue a memory write after HALT.
        instruction = 16'h8200;
        #1;
        if (data_write_enable !== 1'b0 || data_read_enable !== 1'b0) begin
            $fatal(1, "halted CPU issued a memory request");
        end

        $display("cpu-core halt testbench: PASS");
        $finish;
    end
endmodule
