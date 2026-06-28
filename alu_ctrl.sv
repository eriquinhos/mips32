module alu_ctrl (
    input  logic        clk,
    input  logic [5:0]  opcode,
    input  logic [5:0]  funct,
    input  logic [1:0]  op_alu,
    output logic [4:0]  ctrl
);

    // Opcodes
    typedef enum logic [5:0] {
        OP_R    = 6'b000000, OP_ADDI = 6'b000001, OP_SUBI = 6'b000010,
        OP_DIVI = 6'b000011, OP_MULI = 6'b000100, OP_ANDI = 6'b000101,
        OP_ORI  = 6'b000110, OP_NORI = 6'b000111, OP_SLEI = 6'b001000,
        OP_SLTI = 6'b001001, OP_BEQ  = 6'b001010, OP_BNE  = 6'b001011,
        OP_BLT  = 6'b001100, OP_BGT  = 6'b001101, OP_STI  = 6'b001110,
        OP_LDI  = 6'b001111, OP_STR  = 6'b010000, OP_LDR  = 6'b010001,
        OP_HLT  = 6'b010010, OP_IN   = 6'b010011, OP_OUT  = 6'b010100,
        OP_JMP  = 6'b010101, OP_JAL  = 6'b010110, OP_JST  = 6'b010111
    } opcode_t;

    // Funct codes (R-type)
    typedef enum logic [5:0] {
        FN_ADD  = 6'b000000, FN_SUB  = 6'b000001, FN_MUL  = 6'b000010,
        FN_DIV  = 6'b000011, FN_AND  = 6'b000100, FN_OR   = 6'b000101,
        FN_NAND = 6'b000110, FN_NOR  = 6'b000111, FN_SLE  = 6'b001000,
        FN_SLT  = 6'b001001, FN_SGE  = 6'b001010
    } funct_t;

    always_comb begin
        ctrl = 5'd0; // default

        if (opcode == 6'(OP_R)) begin       // R-type: decode funct
            unique case (funct_t'(funct))
                FN_ADD:  ctrl = 5'd0;
                FN_SUB:  ctrl = 5'd1;
                FN_MUL:  ctrl = 5'd2;
                FN_DIV:  ctrl = 5'd3;
                FN_AND:  ctrl = 5'd4;
                FN_OR:   ctrl = 5'd5;
                FN_NAND: ctrl = 5'd6;
                FN_NOR:  ctrl = 5'd7;
                FN_SLT:  ctrl = 5'd12;
                FN_SLE:  ctrl = 5'd13;
                FN_SGE:  ctrl = 5'd14;
                default: ;
            endcase

        end else begin                      // I/J-type: decode opcode
            unique case (opcode_t'(opcode))
                OP_ADDI: ctrl = 5'd0;
                OP_SUBI: ctrl = 5'd1;
                OP_MULI: ctrl = 5'd2;
                OP_DIVI: ctrl = 5'd3;
                OP_ANDI: ctrl = 5'd4;
                OP_ORI:  ctrl = 5'd5;
                OP_NORI: ctrl = 5'd7;
                OP_BEQ:  ctrl = 5'd8;
                OP_BNE:  ctrl = 5'd9;
                OP_BGT:  ctrl = 5'd10;
                OP_BLT:  ctrl = 5'd11;
                OP_SLTI: ctrl = 5'd12;
                OP_SLEI: ctrl = 5'd13;
                default: ;
            endcase
        end

        // op_alu override — highest priority
        if (op_alu != 2'b00)
            unique case (op_alu)
                2'b01: ctrl = 5'd0;
                2'b10: ctrl = 5'd31;
                2'b11: ctrl = 5'd30;
                default: ;
            endcase
    end

endmodule