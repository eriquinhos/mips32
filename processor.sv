// processor.sv — Top-level processor

module processor (
    input  logic        real_clk,
    input  logic        key,
    input  logic        rst,
    input  logic [7:0]  data_in,
    output logic [9:0]  state,
    output logic [31:0] data_out,
    output logic        ctrl_in,
    output logic        ctrl_out
);

    logic [31:0] mem_data_in, stack_in, stack_out;
    logic [31:0] reg_b_out, mem_mux_out, ext_out;
    logic [31:0] reg_a_out, alu_in_a, alu_in_b, alu_out;
    logic [31:0] pc_next, pc_out, alu_reg_out;
    logic [31:0] mem_addr, mem_data_reg_out, instr;
    logic [31:0] mem_reg_out, writeback_data, reg_a_raw, reg_b_raw;

    logic [4:0]  reg_write_addr;

    logic        clk, pop, push, write_pc, write_ir, write_reg;
    logic        write_mem, overflow, zero;
    logic        sel_mux_mem_addr, sel_mux_mem_data, sel_reg1;
    logic        sel_reg2, sel_mux_alu_a, sel_mux_in, sel_mux_stack;
    logic [1:0]  sel_mux_alu_b, sel_mux_pc;
    logic [4:0]  alu_ctrl_sig;

    // PC
    pc_register pc_reg (
        .clk      (clk),
        .reset    (rst),
        .write_en (write_pc),
        .in       (pc_next),
        .out      (pc_out),
        .leds     (state)
    );

    // Stack input select
    mux2_32b mux_stack (
        .sel  (sel_mux_stack),
        .in0  (pc_out),
        .in1  (alu_out),
        .out  (stack_in)
    );

    // Stack
    stack stack_inst (
        .data_in   (stack_in),
        .pop       (pop),
        .push      (push),
        .wclk      (clk),
        .rclk      (clk),
        .data_out  (stack_out),
        .overflow  (),
        .underflow ()
    );

    // Memory address select
    mux2_32b mux_mem_addr (
        .sel  (sel_mux_mem_addr),
        .in0  (pc_out),
        .in1  (alu_out),
        .out  (mem_addr)
    );

    // Memory write data select
    mux2_32b mux_mem_data (
        .sel  (sel_mux_mem_data),
        .in0  (reg_b_out),
        .in1  (stack_out),
        .out  (mem_data_in)
    );

    // Memory
    memory mem_inst (
        .data_in  (mem_data_in),
        .address  (mem_addr[9:0]),
        .write_en (write_mem),
        .wclk     (clk),
        .rclk     (clk),
        .data_out (mem_data_reg_out)
    );

    // Input/memory select
    mux2_32b mux_in (
        .sel  (sel_mux_in),
        .in0  (mem_data_reg_out),
        .in1  ({24'd0, data_in}),
        .out  (mem_mux_out)
    );

    // Memory data register
    reg32b mem_reg (
        .clk      (clk),
        .write_en (1'b1),
        .in       (mem_mux_out),
        .out      (mem_reg_out)
    );

    // Instruction register
    reg32b ir_reg (
        .clk      (clk),
        .write_en (write_ir),
        .in       (mem_data_reg_out),
        .out      (instr)
    );

    // Register write address select
    mux2_5b mux_reg_dst (
        .sel  (sel_reg1),
        .in0  (instr[20:16]),
        .in1  (instr[15:11]),
        .out  (reg_write_addr)
    );

    // Register write data select
    mux2_32b mux_reg_data (
        .sel  (sel_reg2),
        .in0  (alu_reg_out),
        .in1  (mem_reg_out),
        .out  (writeback_data)
    );

    // Register file
    register_file reg_file (
        .clk      (clk),
        .write_en (write_reg),
        .out      (ctrl_out),
        .reg1     (instr[25:21]),
        .reg2     (instr[20:16]),
        .reg_dst  (reg_write_addr),
        .data_in  (writeback_data),
        .A        (reg_a_raw),
        .B        (reg_b_raw),
        .data_out (data_out)
    );

    // A register
    reg32b reg_a (
        .clk      (clk),
        .write_en (1'b1),
        .in       (reg_a_raw),
        .out      (reg_a_out)
    );

    // B register
    reg32b reg_b (
        .clk      (clk),
        .write_en (1'b1),
        .in       (reg_b_raw),
        .out      (reg_b_out)
    );

    // Sign extender
    sign_extender ext (
        .in  (instr[15:0]),
        .out (ext_out)
    );

    // ALU input A select
    mux2_32b mux_alu_a (
        .sel  (sel_mux_alu_a),
        .in0  (mem_addr),
        .in1  (reg_a_out),
        .out  (alu_in_a)
    );

    // ALU input B select
    mux4_32b mux_alu_b (
        .sel  (sel_mux_alu_b),
        .in0  (reg_b_out),
        .in1  (32'd1),
        .in2  (ext_out),
        .in3  (ext_out),
        .out  (alu_in_b)
    );

    // ALU
    alu alu_inst (
        .clk      (clk),
        .ctrl     (alu_ctrl_sig),
        .A        (alu_in_a),
        .B        (alu_in_b),
        .result   (alu_out),
        .overflow (overflow),
        .zero     (zero)
    );

    // ALU output register
    reg32b alu_out_reg (
        .clk      (~clk),
        .write_en (1'b1),
        .in       (alu_out),
        .out      (alu_reg_out)
    );

    // PC source select
    mux4_32b mux_pc (
        .sel  (sel_mux_pc),
        .in0  (alu_out),
        .in1  (alu_reg_out),
        .in2  ({25'd0, instr[6:0]}),
        .in3  (stack_out),
        .out  (pc_next)
    );

    // Clock divider
    clk_divider clk_div (
        .clk    (real_clk),
        .enable (key),
        .div_clk(clk)
    );

    // Control unit
    control_unit ctrl_unit (
        .clk              (clk),
        .reset            (rst),
        .enter            (key),
        .zero             (zero),
        .opcode           (instr[31:26]),
        .funct            (instr[5:0]),
        .state            (),
        .write_pc         (write_pc),
        .write_ir         (write_ir),
        .write_reg        (write_reg),
        .write_mem        (write_mem),
        .ctrl_in          (ctrl_in),
        .ctrl_out         (ctrl_out),
        .pop              (pop),
        .push             (push),
        .sel_mux_mem_addr (sel_mux_mem_addr),
        .sel_mux_mem_data (sel_mux_mem_data),
        .sel_mux_stack    (sel_mux_stack),
        .sel_mux_reg1     (sel_reg1),
        .sel_mux_reg2     (sel_reg2),
        .sel_mux_alu_a    (sel_mux_alu_a),
        .sel_mux_in       (sel_mux_in),
        .sel_mux_alu_b    (sel_mux_alu_b),
        .sel_mux_pc       (sel_mux_pc),
        .alu_ctrl         (alu_ctrl_sig)
    );

endmodule