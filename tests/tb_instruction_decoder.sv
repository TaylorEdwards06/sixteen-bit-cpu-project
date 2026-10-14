`timescale 1ns/1ps

module tb_instruction_decoder;
    localparam logic [3:0] OP_ADD  = 4'h1;
    localparam logic [3:0] OP_ADDI = 4'h6;
    localparam logic [3:0] OP_LD   = 4'h7;
    localparam logic [3:0] OP_ST   = 4'h8;
    localparam logic [3:0] OP_BEQ  = 4'h9;
    localparam logic [3:0] OP_JMP  = 4'hA;
    localparam logic [3:0] OP_HALT = 4'hF;

    logic [15:0] instruction;
    logic [3:0]  opcode;
    logic [2:0]  read_addr_a;
    logic [2:0]  read_addr_b;
    logic [2:0]  write_addr;
    logic [15:0] immediate;
    logic [15:0] branch_offset;
    logic [2:0]  alu_operation;
    logic        use_immediate;
    logic        register_write;
    logic        memory_read;
    logic        memory_write;
    logic        flags_write;
    logic        branch_if_zero;
    logic        jump;
    logic        halt;
    logic        illegal_instruction;

    instruction_decoder dut (.*);

    function automatic logic [15:0] encode_r(
        input logic [3:0] opcode_value,
        input logic [2:0] rd,
        input logic [2:0] rs,
        input logic [2:0] rt
    );
        return {opcode_value, rd, rs, rt, 3'b000};
    endfunction

    function automatic logic [15:0] encode_i(
        input logic [3:0] opcode_value,
        input logic [2:0] rd,
        input logic [2:0] rs,
        input logic [5:0] immediate_value
    );
        return {opcode_value, rd, rs, immediate_value};
    endfunction

    function automatic logic [15:0] encode_branch(
        input logic [3:0]  opcode_value,
        input logic [11:0] offset
    );
        return {opcode_value, offset};
    endfunction

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
        input logic [8:0] expected,
        input string      description
    );
        logic [8:0] actual;
        actual = {
            use_immediate,
            register_write,
            memory_read,
            memory_write,
            flags_write,
            branch_if_zero,
            jump,
            halt,
            illegal_instruction
        };
        if (actual !== expected) begin
            $fatal(1, "%s controls: expected %b, got %b",
                   description, expected, actual);
        end
    endtask

    task automatic check_register_alu(
        input logic [3:0] opcode_value,
        input logic [2:0] expected_alu_operation,
        input string      mnemonic
    );
        instruction = encode_r(opcode_value, 3'd3, 3'd1, 3'd2);
        #1;
        expect_equal(opcode, opcode_value, $sformatf("%s opcode", mnemonic));
        expect_equal(read_addr_a, 3'd1, $sformatf("%s source A", mnemonic));
        expect_equal(read_addr_b, 3'd2, $sformatf("%s source B", mnemonic));
        expect_equal(write_addr, 3'd3, $sformatf("%s destination", mnemonic));
        expect_equal(alu_operation, expected_alu_operation,
                     $sformatf("%s ALU operation", mnemonic));
        expect_controls(9'b010010000, mnemonic);
    endtask

    initial begin
        instruction = 16'h0000;
        #1;
        expect_equal(opcode, 4'h0, "NOP opcode");
        expect_controls(9'b000000000, "NOP");

        check_register_alu(4'h1, 3'd0, "ADD");
        check_register_alu(4'h2, 3'd1, "SUB");
        check_register_alu(4'h3, 3'd2, "AND");
        check_register_alu(4'h4, 3'd3, "OR");
        check_register_alu(4'h5, 3'd4, "XOR");

        instruction = encode_i(OP_ADDI, 3'd4, 3'd2, 6'b111101);
        #1;
        expect_equal(read_addr_a, 3'd2, "ADDI source A");
        expect_equal(write_addr, 3'd4, "ADDI destination");
        expect_equal(immediate, 16'hFFFD, "ADDI signed immediate");
        expect_equal(alu_operation, 3'd0, "ADDI ALU operation");
        expect_controls(9'b110010000, "ADDI");

        instruction = encode_i(OP_LD, 3'd5, 3'd1, 6'b011111);
        #1;
        expect_equal(read_addr_a, 3'd1, "LD base register");
        expect_equal(write_addr, 3'd5, "LD destination");
        expect_equal(immediate, 16'h001F, "LD signed immediate");
        expect_equal(alu_operation, 3'd0, "LD address ALU operation");
        expect_controls(9'b111000000, "LD");

        instruction = encode_i(OP_ST, 3'd6, 3'd2, 6'b111110);
        #1;
        expect_equal(read_addr_a, 3'd2, "ST base register");
        expect_equal(read_addr_b, 3'd6, "ST data register");
        expect_equal(immediate, 16'hFFFE, "ST signed immediate");
        expect_equal(alu_operation, 3'd0, "ST address ALU operation");
        expect_controls(9'b100100000, "ST");

        instruction = encode_branch(OP_BEQ, 12'hFFE);
        #1;
        expect_equal(branch_offset, 16'hFFFE, "BEQ signed word offset");
        expect_controls(9'b000001000, "BEQ");

        instruction = encode_branch(OP_JMP, 12'h003);
        #1;
        expect_equal(branch_offset, 16'h0003, "JMP signed word offset");
        expect_controls(9'b000000100, "JMP");

        instruction = {OP_HALT, 12'h000};
        #1;
        expect_controls(9'b000000010, "HALT");

        instruction = 16'hB000;
        #1;
        expect_controls(9'b000000001, "reserved opcode");

        $display("instruction-decoder testbench: PASS");
        $finish;
    end
endmodule
