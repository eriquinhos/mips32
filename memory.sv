// memory.sv — Dual-clock synchronous RAM, 512 x 32-bit

module memory (
    input  logic [31:0] data_in,
    input  logic [9:0]  address,
    input  logic        write_en,
    input  logic        wclk,
    input  logic        rclk,
    output logic [31:0] data_out
);

    logic [31:0] ram [0:511];

    // Opcode reference:
    // R=00  addi=01  subi=02  divi=03  muli=04  andi=05  ori=06  nori=07
    // slei=08  slti=09  beq=0A  bne=0B  blt=0C  bgt=0D  sti=0E  ldi=0F
    // str=10  ldr=11  hlt=12  in=13  out=14  jmp=15  jal=16  jst=17
    // sdsk=18  ldsk=19  slp=1A  wake=1B  lstk=1C  sstk=1D

    initial begin
        ram[0] = {6'b010011, 5'd0, 5'd1, 16'd0};                   // in r1
        ram[1] = {6'b000001, 5'd0, 5'd11, 16'd1};                  // addi r11, r0, 1
        ram[2] = {6'b000001, 5'd0, 5'd8, 16'd1};                   // addi r8,  r0, 1
        ram[3] = {6'b000001, 5'd0, 5'd9, 16'd1};                   // addi r9,  r0, 1
        ram[4] = {6'b000001, 5'd0, 5'd2, 16'd1};                   // addi r2,  r0, 1
        ram[5] = {6'b010100, 5'd0, 5'd8, 16'd0};                   // out  r8
        ram[6] = {6'b001010, 5'd2, 5'd1, 16'd11};                  // beq  r2, r1, 11
        ram[7] = {6'b000001, 5'd2, 5'd2, 16'd1};                   // addi r2, r2, 1
        ram[8] = {6'b010100, 5'd0, 5'd9, 16'd0};                   // out  r9
        ram[9] = {6'b001010, 5'd2, 5'd1, 16'd8};                   // beq  r2, r1, 8
        ram[10] = {6'b000001, 5'd2, 5'd2, 16'd1};                  // addi r2, r2, 1
        ram[11] = {6'b000000, 5'd8, 5'd9, 5'd10, 5'd0, 6'b000000}; // add  r10, r8, r9  [LOOP]
        ram[12] = {6'b010100, 5'd0, 5'd10, 16'd0};                 // out  r10
        ram[13] = {6'b000001, 5'd9, 5'd8, 16'd0};                  // addi r8, r9, 0
        ram[14] = {6'b000001, 5'd10, 5'd9, 16'd0};                 // addi r9, r10, 0
        ram[15] = {6'b000001, 5'd2, 5'd2, 16'd1};                  // addi r2, r2, 1
        ram[16] = {6'b001010, 5'd2, 5'd1, 16'd1};                  // beq  r2, r1, 1
        ram[17] = {6'b010101, 5'd0, 5'd0, 16'd11};                 // jmp  11
        ram[18] = {6'b010010, 5'd0, 5'd0, 16'd0};                  // hlt
    end

    // Write port — posedge, gated by write_en
    always @(posedge wclk) begin
        if (write_en)
            ram[address] <= data_in;
    end

    // Read port — negedge, registered output
    always_ff @(negedge rclk)
        data_out <= ram[address];

endmodule