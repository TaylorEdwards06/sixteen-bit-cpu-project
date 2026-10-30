// Combinational CPU boundary for sixteen-bit data-memory accesses.
module data_memory_interface (
    input  logic        memory_read,
    input  logic        memory_write,
    input  logic [15:0] effective_address,
    input  logic [15:0] store_data,
    input  logic [15:0] memory_read_data,
    output logic [15:0] memory_address,
    output logic [15:0] memory_write_data,
    output logic        memory_read_enable,
    output logic        memory_write_enable,
    output logic [15:0] load_data,
    output logic        access_fault
);
    always_comb begin
        memory_address = effective_address;
        memory_write_data = store_data;
        memory_read_enable = 1'b0;
        memory_write_enable = 1'b0;
        load_data = 16'h0000;
        access_fault = 1'b0;

        if (memory_read && memory_write) begin
            access_fault = 1'b1;
        end else if (memory_write) begin
            if (effective_address[0])begin
                access_fault = 1'b1;
            end else begin
                memory_write_enable = 1'b1;
            end
        end else if (memory_read) begin
            if (effective_address[0]) begin
                access_fault = 1'b1;
            end else begin
                memory_read_enable = 1'b1;
                load_data = memory_read_data;
            end 
        end
    end
endmodule
