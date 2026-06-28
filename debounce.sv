module debounce (
    input  logic clk,
    input  logic n_reset,
    input  logic button_in,
    output logic db_out
);

    parameter int N = 11;

    logic [N-1:0] q_reg, q_next;
    logic dff1, dff2;
    logic q_add, q_reset;

    assign q_reset = dff1 ^ dff2;
    assign q_add   = ~q_reg[N-1];

    always_comb begin
        unique case ({q_reset, q_add})
            2'b00:   q_next = q_reg;
            2'b01:   q_next = q_reg + 1'b1;
            default: q_next = '0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!n_reset) begin
            dff1  <= 1'b0;
            dff2  <= 1'b0;
            q_reg <= '0;
        end else begin
            dff1  <= button_in;
            dff2  <= dff1;
            q_reg <= q_next;
        end
    end

    always_ff @(posedge clk) begin
        if (q_reg[N-1])
            db_out <= dff2;
    end

endmodule