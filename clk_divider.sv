module clk_divider (
    input  logic clk,
    input  logic enable,
    output logic div_clk
);

    //localparam int unsigned DIVISOR = 1_000_000;
    localparam int unsigned DIVISOR = 4;
    logic [26:0] counter;

    initial begin
        counter = '0;
        div_clk = 1'b0;
    end

    always @(posedge clk) begin
        if (!enable) begin
            counter <= '0;
            div_clk <= 1'b0;
        end else if (counter == DIVISOR-1) begin
            counter <= '0;
            div_clk <= 1'b1;
        end else begin
            counter <= counter + 1'b1;
            div_clk <= 1'b0;
        end
    end

endmodule