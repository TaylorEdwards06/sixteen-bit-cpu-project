// Byte-addressed program counter for the sixteen-bit CPU.
module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    input  logic        take_branch,
    input  logic [15:0] branch_offset,
    output logic [15:0] pc
);
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 16'h0000;
        end else if (enable) begin
            if (take_branch)begin
                pc <= pc + 16'd2 + (branch_offset << 1); // convert branch word offset to byte offset 
            end else begin
                pc <= pc+16'd2;
            end
        end
    end
endmodule
