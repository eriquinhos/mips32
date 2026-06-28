module alu (
    input  logic        clk,
    input  logic [4:0]  ctrl,
    input  logic [31:0] A, B,
    output logic [31:0] result,
    output logic        overflow,
    output logic        zero
);

    always_ff @(posedge clk) begin
        overflow <= 1'b0;   // default — overridden where needed
        zero     <= 1'b0;   // default — overridden where needed

        unique case (ctrl)
            5'd0:  result <= A + B;                         // add
            5'd1:  result <= A - B;                         // sub
            5'd2:  begin                                    // mul
                       overflow <= A[16] & B[16];
                       result   <= A * B;
                   end
            5'd3:  result <= A / B;                         // div
            5'd4:  result <= A & B;                         // and
            5'd5:  result <= A | B;                         // or
            5'd6:  result <= ~(A & B);                      // nand
            5'd7:  result <= ~(A | B);                      // nor
            5'd8:  begin result <= B; zero <= (A == B); end // beq
            5'd9:  begin result <= B; zero <= (A != B); end // bne
            5'd10: begin result <= B; zero <= (A >  B); end // bgt
            5'd11: begin result <= B; zero <= (A <  B); end // blt
            5'd12: result <= 32'(A <  B);                   // slt
            5'd13: result <= 32'(A <= B);                   // sle
            5'd14: result <= 32'(A >= B);                   // sge
            5'd30: result <= B;                             // pass B
            default: ; // hold — no assignment keeps registered values
        endcase
    end

endmodule