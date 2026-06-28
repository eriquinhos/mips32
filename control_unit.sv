module control_unit (
    input  logic        clk,
    input  logic        reset,
    input  logic        enter,
    input  logic        zero,
    input  logic [5:0]  opcode,
    input  logic [5:0]  funct,

    output logic [4:0]  state,

    // Memory control signals
    output logic        write_pc,
    output logic        write_ir,
    output logic        write_reg,
    output logic        write_mem,
    output logic        ctrl_in,
    output logic        ctrl_out,
    output logic        pop,
    output logic        push,

    // Mux selectors
    output logic        sel_mux_mem_addr,
    output logic        sel_mux_mem_data,
    output logic        sel_mux_stack,
    output logic        sel_mux_reg1,
    output logic        sel_mux_reg2,
    output logic        sel_mux_alu_a,
    output logic        sel_mux_in,
    output logic [1:0]  sel_mux_alu_b,
    output logic [1:0]  sel_mux_pc,

    // ALU control
    output logic [4:0]  alu_ctrl
);

    logic [4:0] next_state;
    logic [1:0] op_alu;

    // -------------------------------------------------------------------------
    // States
    // -------------------------------------------------------------------------
    typedef enum logic [4:0] {
        S0  = 5'd0,  S1  = 5'd1,  S2  = 5'd2,  S3  = 5'd3,
        S4  = 5'd4,  S5  = 5'd5,  S6  = 5'd6,  S7  = 5'd7,
        S8  = 5'd8,  S9  = 5'd9,  S10 = 5'd10, S11 = 5'd11,
        S12 = 5'd12, S13 = 5'd13, S14 = 5'd14, S15 = 5'd15,
        S16 = 5'd16, S17 = 5'd17, S18 = 5'd18, S19 = 5'd19,
        S20 = 5'd20
    } state_t;

    state_t state_r, next_state_r;
    assign state = state_r;

    // -------------------------------------------------------------------------
    // Opcodes
    // -------------------------------------------------------------------------
    typedef enum logic [5:0] {
        OP_R    = 6'b000000,
        OP_ADDI = 6'b000001,
        OP_SUBI = 6'b000010,
        OP_DIVI = 6'b000011,
        OP_MULI = 6'b000100,
        OP_ANDI = 6'b000101,
        OP_ORI  = 6'b000110,
        OP_NORI = 6'b000111,
        OP_SLEI = 6'b001000,
        OP_SLTI = 6'b001001,
        OP_BEQ  = 6'b001010,
        OP_BNE  = 6'b001011,
        OP_BLT  = 6'b001100,
        OP_BGT  = 6'b001101,
        OP_STI  = 6'b001110,
        OP_LDI  = 6'b001111,
        OP_STR  = 6'b010000,
        OP_LDR  = 6'b010001,
        OP_HLT  = 6'b010010,
        OP_IN   = 6'b010011,
        OP_OUT  = 6'b010100,
        OP_JMP  = 6'b010101,
        OP_JAL  = 6'b010110,
        OP_JST  = 6'b010111,
        OP_LSTK = 6'b011100,
        OP_SSTK = 6'b011101
    } opcode_t;

    // -------------------------------------------------------------------------
    // ALU control submodule
    // -------------------------------------------------------------------------
    alu_ctrl ctrl_alu (
        .opcode  (opcode),
        .funct   (funct),
        .op_alu  (op_alu),
        .ctrl    (alu_ctrl),
        .clk     (clk)
    );

    // -------------------------------------------------------------------------
    // State register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) state_r <= state_t'(S0);
        else       state_r <= next_state_r;
    end

    // -------------------------------------------------------------------------
    // Next-state logic + output logic (negedge clk)
    // -------------------------------------------------------------------------
    always_ff @(negedge clk) begin

        unique case (state_r)

            // ------------------------------------------------------------------
            S0: begin // Fetch instruction
                write_pc      <= 1'b0;
                write_ir      <= 1'b1;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b01;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b01;
                sel_mux_in    <= 1'b1;
                next_state_r  <= state_t'(S1);
            end

            // ------------------------------------------------------------------
            S1: begin // Decode instruction
                write_pc      <= (opcode == OP_HLT) ? 1'b0 : 1'b1;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= (opcode == OP_OUT) ? 1'b1 : 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b01;
                sel_mux_in    <= 1'b0;

                unique case (opcode)
                    OP_OUT:  next_state_r <= state_t'(S20);
                    OP_IN:   next_state_r <= state_t'(S12);
                    OP_STI:  next_state_r <= state_t'(S2);
                    OP_LDI:  next_state_r <= state_t'(S2);
                    OP_STR:  next_state_r <= state_t'(S2);
                    OP_LDR:  next_state_r <= state_t'(S2);
                    OP_R:    next_state_r <= state_t'(S6);
                    OP_BLT:  next_state_r <= state_t'(S8);
                    OP_BGT:  next_state_r <= state_t'(S8);
                    OP_BEQ:  next_state_r <= state_t'(S8);
                    OP_BNE:  next_state_r <= state_t'(S8);
                    OP_JMP:  next_state_r <= state_t'(S9);
                    OP_JAL:  next_state_r <= state_t'(S9);
                    OP_JST:  next_state_r <= state_t'(S10);
                    OP_HLT:  next_state_r <= state_t'(S14);
                    OP_LSTK: next_state_r  = state_t'(S16);
                    OP_SSTK: next_state_r  = state_t'(S18);
                    default: next_state_r <= state_t'(S11); // I-type
                endcase
            end

            // ------------------------------------------------------------------
            S2: begin // Compute memory address via ALU
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= (opcode == OP_STI || opcode == OP_LDI) ? 2'b11 : 2'b01;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b11;
                sel_mux_in    <= 1'b0;

                unique case (opcode)
                    OP_LDI:  next_state_r <= state_t'(S3);
                    OP_LDR:  next_state_r <= state_t'(S3);
                    OP_STI:  next_state_r <= state_t'(S5);
                    OP_STR:  next_state_r <= state_t'(S5);
                    default: next_state_r <= state_t'(S0);
                endcase
            end

            // ------------------------------------------------------------------
            S3: begin // Read data from memory
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b1;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S4);
            end

            // ------------------------------------------------------------------
            S4: begin // Write memory data to register file
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b1;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b1;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S13);
            end

            // ------------------------------------------------------------------
            S5: begin // Write register data to memory
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b1;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= (opcode == OP_SSTK) ? 1'b1 : 1'b0;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S15);
            end

            // ------------------------------------------------------------------
            S6: begin // R-type: compute A op B
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b1;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S7);
            end

            // ------------------------------------------------------------------
            S7: begin // Write ALU result to register file
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b1;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= (opcode == OP_R) ? 1'b1 : 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= (opcode == OP_R) ? 2'b00 : 2'b11;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S0);
            end

            // ------------------------------------------------------------------
            S8: begin // Compute branch target address
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b01;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S10);
            end

            // ------------------------------------------------------------------
            S9: begin // Execute jump
                write_pc      <= 1'b1;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b11;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S13);
            end

            // ------------------------------------------------------------------
            S10: begin // Update PC (branch / JST)
                write_pc      <= (zero || opcode == OP_JST) ? 1'b1 : 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= (opcode == OP_JST) ? 1'b1 : 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= (opcode == OP_JST) ? 2'b11 : 2'b10;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S0);
            end

            // ------------------------------------------------------------------
            S11: begin // I-type: compute A op Imm
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b11;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S7);
            end

            // ------------------------------------------------------------------
            S12: begin // Wait for input data
                write_pc        <= 1'b0;
                write_ir        <= 1'b0;
                write_reg       <= 1'b1;
                write_mem       <= 1'b0;
                ctrl_in         <= 1'b1;
                ctrl_out        <= 1'b0;
                op_alu          <= 2'b00;
                pop             <= 1'b0;
                push            <= 1'b0;
                sel_mux_pc      <= 2'b00;
                sel_mux_stack   <= 1'b0;
                sel_mux_mem_data<= 1'b0;
                sel_mux_mem_addr<= 1'b0;
                sel_mux_reg1    <= 1'b0;
                sel_mux_reg2    <= 1'b0;
                sel_mux_alu_a   <= 1'b0;
                sel_mux_alu_b   <= 2'b00;
                sel_mux_in      <= 1'b1;
                next_state_r    <= (enter) ? state_t'(S15) : state_t'(S12);
            end

            // ------------------------------------------------------------------
            S13: begin // Finalize JMP / JAL / LW
                write_pc      <= (opcode == OP_JMP || opcode == OP_JAL) ? 1'b1 : 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= (opcode == OP_LDI) ? 1'b1 : 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= (opcode == OP_JAL) ? 1'b1 : 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b1;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S0);
            end

            // ------------------------------------------------------------------
            S14: begin // HLT — halt processor
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S14); // Stay halted
            end

            // ------------------------------------------------------------------
            S15: begin // Commit write / finalize IN or OUT
                write_pc        <= 1'b0;
                write_ir        <= 1'b0;
                write_reg       <= (opcode == OP_STI || opcode == OP_OUT) ? 1'b0 : 1'b1;
                write_mem       <= 1'b0;
                ctrl_in         <= 1'b0;
                ctrl_out        <= 1'b0;
                op_alu          <= 2'b00;
                pop             <= (opcode == OP_SSTK) ? 1'b1 : 1'b0;
                push            <= 1'b0;
                sel_mux_pc      <= 2'b00;
                sel_mux_stack   <= 1'b0;
                sel_mux_mem_data<= 1'b0;
                sel_mux_mem_addr<= 1'b0;
                sel_mux_reg1    <= 1'b0;
                sel_mux_reg2    <= 1'b1;
                sel_mux_alu_a   <= 1'b0;
                sel_mux_alu_b   <= 2'b00;
                sel_mux_in      <= 1'b1;
                next_state_r    <= state_t'(S0);
            end

            // ------------------------------------------------------------------
            S16: begin // LSTK: fetch address from register file
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b1;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S17);
            end

            // ------------------------------------------------------------------
            S17: begin // LSTK: push address onto stack
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b1;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b1;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S0);
            end

            // ------------------------------------------------------------------
            S18: begin // SSTK: load ALU output
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b1;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S19);
            end

            // ------------------------------------------------------------------
            S19: begin // SSTK: flush stack to memory
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b1;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b0;
                op_alu        <= 2'b11;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b1;
                sel_mux_mem_addr <= 1'b1;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b1;
                sel_mux_alu_b <= 2'b00;
                sel_mux_in    <= 1'b0;
                next_state_r  <= state_t'(S15);
            end

            // ------------------------------------------------------------------
            S20: begin // OUT: drive output port
                write_pc      <= 1'b0;
                write_ir      <= 1'b0;
                write_reg     <= 1'b0;
                write_mem     <= 1'b0;
                ctrl_in       <= 1'b0;
                ctrl_out      <= 1'b1;
                op_alu        <= 2'b00;
                pop           <= 1'b0;
                push          <= 1'b0;
                sel_mux_pc    <= 2'b00;
                sel_mux_stack <= 1'b0;
                sel_mux_mem_data <= 1'b0;
                sel_mux_mem_addr <= 1'b0;
                sel_mux_reg1  <= 1'b0;
                sel_mux_reg2  <= 1'b0;
                sel_mux_alu_a <= 1'b0;
                sel_mux_alu_b <= 2'b01;
                sel_mux_in    <= 1'b0;
                if (enter) next_state_r <= state_t'(S15);
            end

            default: next_state_r <= state_t'(S0);

        endcase
    end

endmodule