// Combinational instruction decoder for the sixteen-bit CPU.
module instruction_decoder (
    input  logic [15:0] instruction,
    output logic [3:0]  opcode,
    output logic [2:0]  read_addr_a,
    output logic [2:0]  read_addr_b,
    output logic [2:0]  write_addr,
    output logic [15:0] immediate,
    output logic [15:0] branch_offset,
    output logic [2:0]  alu_operation,
    output logic        use_immediate,
    output logic        register_write,
    output logic        memory_read,
    output logic        memory_write,
    output logic        flags_write,
    output logic        branch_if_zero,
    output logic        jump,
    output logic        halt,
    output logic        illegal_instruction
);
    always_comb begin
        // Setting safe defaults
        opcode = 4'h0;
        read_addr_a = 3'd0;
        read_addr_b = 3'd0;
        write_addr = 3'd0;
        immediate = 16'h0000;
        branch_offset = 16'h0000;
        alu_operation = 3'd0;
        use_immediate = 1'b0;
        register_write = 1'b0;
        memory_read = 1'b0;
        memory_write = 1'b0;
        flags_write = 1'b0;
        branch_if_zero = 1'b0;
        jump = 1'b0;
        halt = 1'b0;
        illegal_instruction = 1'b0;

        opcode = instruction[15:12];

        case (opcode)
            4'h0: begin // NOP instruction
                // safe defaults are what NOP would be
            end

            4'h1: begin // ADD rd, rs, rt
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                read_addr_b = instruction[5:3];
                alu_operation = 3'd0;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h2: begin // SUB rd, rs, rt
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                read_addr_b = instruction[5:3];
                alu_operation = 3'd1;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h3: begin // AND rd, rs, rt
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                read_addr_b = instruction[5:3];
                alu_operation = 3'd2;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h4: begin // OR rd, rs, rt
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                read_addr_b = instruction[5:3];
                alu_operation = 3'd3;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h5: begin // XOR rd, rs, rt
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                read_addr_b = instruction[5:3];
                alu_operation = 3'd4;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h6: begin // ADDI rd, rs, imm6
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                // sign extend as instruction is logic not signed
                immediate = {{10{instruction[5]}},instruction[5:0]}; 
                alu_operation = 1'b0;
                use_immediate = 1'b1;
                register_write = 1'b1;
                flags_write = 1'b1;
            end

            4'h7: begin // LD rd, (rs + imm6)
                write_addr = instruction[11:9];
                read_addr_a = instruction[8:6];
                immediate = {{10{instruction[5]}}, instruction[5:0]}; 
                alu_operation = 1'b0;
                use_immediate = 1'b1;
                register_write = 1'b1;
                memory_read = 1'b1;
            end

            4'h8: begin // ST rd, (rs+imm6)
                read_addr_a = instruction[8:6]; // need to add to imm6
                read_addr_b = instruction[11:9]; // value to send to mem
                immediate = {{10{instruction[5]}}, instruction[5:0]};
                alu_operation = 1'b0;
                use_immediate = 1'b1;
                memory_write = 1'b1;
            end

            4'h9: begin // BEQ op, offset12 (Z value must be preset)
                branch_offset = {{4{instruction[11]}}, instruction[11:0]};
                branch_if_zero = 1'b1;
            end

            4'hA: begin // JMP op, offset12 
                branch_offset = {{4{instruction[11]}}, instruction[11:0]};
                jump = 1'b1;
            end

            4'hF: begin // HALT halt set hi
                halt = 1'b1;
            end

            default: begin
                illegal_instruction = 1'b1;
            end
        endcase
    end
endmodule
