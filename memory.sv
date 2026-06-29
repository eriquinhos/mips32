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
        ram[0]  = {6'b000001, 5'd0, 5'd8, 16'd0};        // addi r8, r0, 0;
        ram[1]  = {6'b000001, 5'd0, 5'd9, 16'd5};        // addi r9, r0, 5;
        ram[2]  = {6'b010011, 5'd0, 5'd1, 16'd0};        // in   r1; [LOOP]
        ram[3]  = {6'b010000, 5'd8, 5'd1, 16'd361};      // str r1, r8, 361;
        ram[4]  = {6'b000001, 5'd8, 5'd8, 16'd1};        // addi r8, r8, 1; k++
        ram[5]  = {6'b001100, 5'd8, 5'd9, 16'd2};        // blt  r8, r9, 2;
        ram[6]  = {6'b000001, 5'd0, 5'd1, 16'd0};        // addi r1, r0, 0;
        ram[7]  = {6'b000001, 5'd0, 5'd3, 16'd4};        // addi r3, r0, 4;
        ram[8]  = {6'b001100, 5'd1, 5'd3, 16'd10};       // blt  r1, r3, 10; [LOOP 1]
        ram[9]  = {6'b010101, 5'd0, 5'd0, 16'd24};       // jmp  24;
        ram[10] = {6'b000001, 5'd0, 5'd2, 16'd0};        // addi r2, r0, 0   
        ram[11] = {6'b001100, 5'd2, 5'd3, 16'd13};       // blt  r2, r3, 13; [LOOP 2]
        ram[12] = {6'b010101, 5'd0, 5'd0, 16'd22};       // jmp  22;
        ram[13] = {6'b010001, 5'd2, 5'd4, 16'd361};      // ldr r4, r2, 361;
        ram[14] = {6'b000001, 5'd2, 5'd6, 16'd1};        // addi r6, r2, 1;
        ram[15] = {6'b010001, 5'd6, 5'd5, 16'd361};      // ldr r5, r6, 361;
        ram[16] = {6'b001101, 5'd4, 5'd5, 16'd18};       // bgt  r4, r5, 18;
        ram[17] = {6'b010101, 5'd0, 5'd0, 16'd20};       // jmp  20;
        ram[18] = {6'b010000, 5'd2, 5'd5, 16'd361};      // str r5, r2, 361;
        ram[19] = {6'b010000, 5'd6, 5'd4, 16'd361};      // str r4, r6, 361;
        ram[20] = {6'b000001, 5'd2, 5'd2, 16'd1};        // addi r2, r2, 1;
        ram[21] = {6'b010101, 5'd0, 5'd0, 16'd11};       // jmp  11;
        ram[22] = {6'b000001, 5'd1, 5'd1, 16'd1};        // addi r1, r1, 1;
        ram[23] = {6'b010101, 5'd0, 5'd0, 16'd8};        // jmp  8;
        ram[24] = {6'b000001, 5'd0, 5'd8, 16'd0};        // addi r8, r0, 0;
        ram[25] = {6'b000001, 5'd0, 5'd9, 16'd5};        // addi r9, r0, 5;
        ram[26] = {6'b010001, 5'd8, 5'd1, 16'd361};      // ldr r1, r8, 361;
        ram[27] = {6'b010100, 5'd0, 5'd1, 16'd0};        // out  r1; 
        ram[28] = {6'b000001, 5'd8, 5'd8, 16'd1};        // addi r8, r8, 1;
        ram[29] = {6'b001100, 5'd8, 5'd9, 16'd26};       // blt  r8, r9, 26 ;
        ram[30] = {6'b010010, 5'd0, 5'd0, 16'd0};        // hlt
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

// PROGRAMA: lê 5 números (via "in"), ordena em ordem crescente com
// BUBBLE SORT (usando LOOPS) e imprime um de cada vez no display de
// 7 segmentos (via "out").
//
// Diferente da versão desenrolada, aqui o vetor fica na MEMÓRIA DE DADOS
// (região de variáveis globais, base = 361) e é acessado com endereçamento
// indexado por registrador (str/ldr), o que permite usar laços de verdade.
//
// ---------------------------------------------------------------------------
// Mapa de registradores
//   r0           -> sempre 0 (nunca é escrito)
//   r1           -> dado lido / valor a exibir / temporário
//   r2 (j)       -> índice do laço interno
//   r3 (limit)   -> N-1 = 4
//   r4 (a[j])    -> elemento atual
//   r5 (a[j+1])  -> próximo elemento
//   r6 (j+1)     -> índice do próximo elemento
//   r8 (k / i)   -> contador (leitura, laço externo, impressão)
//   r9 (N)       -> constante 5
// ---------------------------------------------------------------------------