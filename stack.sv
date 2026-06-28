// 10-word stack with push/pop control
module stack (
    input  logic [31:0] data_in,
    input  logic        pop,
    input  logic        push,
    input  logic        wclk,
    input  logic        rclk,
    output logic [31:0] data_out,
    output logic        overflow,
    output logic        underflow
);

    logic [31:0] stack_mem [0:9];
    logic [3:0]  pointer;

    initial pointer = 4'd0;

    always @(posedge wclk) begin
        overflow  <= 1'b0;
        underflow <= 1'b0;

        if (push) begin
            if (pointer < 4'd10) begin
                stack_mem[pointer] <= data_in;
                pointer <= pointer + 4'd1;
            end else begin
                overflow <= 1'b1;
            end
        end

        if (pop) begin
            if (pointer > 4'd0) begin
                pointer <= pointer - 4'd1;
            end else begin
                underflow <= 1'b1;
            end
        end
    end

    always_ff @(negedge rclk)
        data_out <= stack_mem[pointer - 4'd1];

endmodule