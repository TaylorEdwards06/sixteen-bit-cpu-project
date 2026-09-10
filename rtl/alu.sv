// Combinational arithmetic/logic unit for the draft 16-bit CPU.
module alu (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [2:0]  operation,
    output logic [15:0] result,
    output logic        zero,
    output logic        negative,
    output logic        carry,
    output logic        overflow
);
    logic [16:0] extended;

    always_comb begin
        result = '0;
        extended = '0;
        carry = 1'b0;
        overflow = 1'b0;
        unique case (operation)
            3'd0: begin // ADD
                extended = {1'b0, a} + {1'b0, b};
                result = extended[15:0];
                carry = extended[16];
                overflow = ~(a[15] ^ b[15]) & (a[15] ^ result[15]);
            end
            3'd1: begin // SUB
                result = a - b;
                carry = (a >= b); // no borrow
                overflow = (a[15] ^ b[15]) & (a[15] ^ result[15]);
            end
            3'd2: result = a & b;
            3'd3: result = a | b;
            3'd4: result = a ^ b;
            default: result = '0;
        endcase
        zero = (result == '0);
        negative = result[15];
    end
endmodule
