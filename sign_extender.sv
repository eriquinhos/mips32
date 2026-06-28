module sign_extender (
    input  logic [15:0] in,
    output logic [31:0] out
);

    always_comb begin
        out = {{16{in[15]}}, in};
    end

endmodule