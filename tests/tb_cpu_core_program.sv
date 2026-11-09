`timescale 1ns/1ps

module tb_cpu_core_program;
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

    logic [15:0] data_memory [0:15];

    cpu_core dut (.*);

    always #5 clk = ~clk;

    always_comb begin
        instruction = 16'h0000;
        case (instruction_address)
            16'h0000: instruction = {4'h6, 3'd1, 3'd0, 6'b000011}; // ADDI r1, r0, 3
            16'h0002: instruction = {4'h6, 3'd2, 3'd0, 6'b000000}; // ADDI r2, r0, 0
            16'h0004: instruction = {4'h1, 3'd2, 3'd2, 3'd1, 3'b000}; // ADD  r2, r2, r1
            16'h0006: instruction = {4'h6, 3'd1, 3'd1, 6'b111111}; // ADDI r1, r1, -1
            16'h0008: instruction = {4'h9, 12'h001}; // BEQ  +1 (to address 0x000C)
            16'h000A: instruction = {4'hA, 12'hFFC}; // JMP  -4 (to address 0x0004)
            16'h000C: instruction = {4'h8, 3'd2, 3'd0, 6'b000000}; // ST   r2, [r0 + 0]
            16'h000E: instruction = {4'h7, 3'd3, 3'd0, 6'b000000}; // LD   r3, [r0 + 0]
            16'h0010: instruction = {4'h2, 3'd4, 3'd3, 3'd2, 3'b000}; // SUB  r4, r3, r2
            16'h0012: instruction = {4'h9, 12'h001}; // BEQ  +1 (to address 0x0016)
            16'h0014: instruction = {4'h6, 3'd5, 3'd0, 6'd31}; // ADDI r5, r0, 31 (must skip)
            16'h0016: instruction = {4'hF, 12'd0}; // HALT
            default:  instruction = 16'h0000;
        endcase
    end

    always_comb begin
        data_read_data = 16'h0000;
        if (data_read_enable) begin
            data_read_data = data_memory[data_address[4:1]];
        end
    end

    always @(posedge clk) begin
        if (data_write_enable) begin
            data_memory[data_address[4:1]] <= data_write_data;
        end
    end

    initial begin
        reset = 1'b1;
        for (int i = 0; i < 16; i++) begin
            data_memory[i] = 16'h0000;
        end

        @(posedge clk);
        #1;
        reset = 1'b0;

        for (int cycles = 0; cycles < 40 && !halted; cycles++) begin
            @(posedge clk);
            #1;
        end

        if (!halted) begin
            $fatal(1, "program did not halt within 40 cycles");
        end
        if (instruction_address !== 16'h0018) begin
            $fatal(1, "expected final PC 0018, got %h", instruction_address);
        end
        if (data_memory[0] !== 16'h0006) begin
            $fatal(1, "expected loop result 0006 in memory, got %h",
                   data_memory[0]);
        end
        if (dut.reg_file.regs[3] !== 16'h0006) begin
            $fatal(1, "expected loaded value 0006 in r3, got %h",
                   dut.reg_file.regs[3]);
        end
        if (dut.reg_file.regs[5] !== 16'h0000) begin
            $fatal(1, "final BEQ failed to skip ADDI into r5");
        end
        if (access_fault || illegal_instruction) begin
            $fatal(1, "program raised an unexpected fault");
        end

        $display("cpu-core program testbench: PASS");
        $finish;
    end
endmodule
