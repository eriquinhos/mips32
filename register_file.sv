module register_file (
    input  logic        clk,
    input  logic        write_en,
    input  logic        out,
    input  logic [4:0]  reg1,
    input  logic [4:0]  reg2,
    input  logic [4:0]  reg_dst,
    input  logic [31:0] data_in,
    output logic [31:0] A,
    output logic [31:0] B,
    output logic [31:0] data_out
);

    logic [31:0] registers [31:0];

    // Initialization
    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'b0;
        end
    end

    // Write port
    always @(posedge clk) begin
        if (write_en)
            registers[reg_dst] <= data_in;
    end

    // Read ports (combinational)
    assign A = registers[reg1];
    assign B = registers[reg2];

    // Output port (clocked on 'out' signal)
    always_ff @(posedge out)
        data_out <= registers[reg2];

endmodule