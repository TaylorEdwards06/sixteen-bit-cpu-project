// Clocked storage for the architectural condition flags.
module flag_register (
    input  logic clk,
    input  logic reset,
    input  logic write_enable,
    input  logic zero_in,
    input  logic negative_in,
    input  logic carry_in,
    input  logic overflow_in,
    output logic zero,
    output logic negative,
    output logic carry,
    output logic overflow
);
    always_ff @(posedge clk) begin
        if (reset) begin
            zero <= 1'b0;
            negative <= 1'b0;
            carry <= 1'b0;
            overflow <= 1'b0;
        end else if (write_enable) begin
            zero <= zero_in;
            negative <= negative_in;
            carry <= carry_in;
            overflow <= overflow_in;
        end
    end
endmodule
