// Eight-register, two-read-port register file for the sixteen-bit CPU.
//
// Implement the behavior described in docs/milestone-1-workbook.md.
module register_file (
    input  logic        clk,
    input  logic        reset,
    input  logic [2:0]  read_addr_a,
    input  logic [2:0]  read_addr_b,
    output logic [15:0] read_data_a,
    output logic [15:0] read_data_b,
    input  logic        write_enable,
    input  logic [2:0]  write_addr,
    input  logic [15:0] write_data
);
    logic [15:0] regs [0:7];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 8; i++) begin 
                regs[i] <= 16'h0000; // 16-bits hex value of 0000
            end
            // if write high and not writing to 0 then allow write
        end else if (write_enable && write_addr != 3'd0) begin // 3-bits decimal value of 0
            regs[write_addr] <= write_data;
        end
    end

    always_comb begin
        if (read_addr_a == 3d'0) begin
            read_data_a = 16'h0000;
        end else begin
            read_data_a = regs[read_addr_a];
        end

        if (read_addr_b == 3d'0) begin
            read_data_b = 16'h0000;
        end else begin
            read_data_b = regs[read_addr_b];
        end
    end
endmodule
