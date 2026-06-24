// --- OPCODES DAS INSTRUÇÕES---
// Minimos:
`define ADD 4'b0000
`define SUB 4'b0001
`define LDA 4'b0010
`define STA 4'b0011
`define LDB 4'b0100
`define STB 4'b0101
`define LDC 4'b0110
`define JMP 4'b0111
// Adicionais:
`define AND 4'b1000
`define  OR 4'b1001
`define XOR 4'b1010
`define NOT 4'b1011
`define MUL 4'b1100
`define DIV 4'b1101
`define CMP 4'b1110
`define LDD 4'b1111 // Semelhante ao LDC, mas com reg B.


// --- ESTADOS DA FSM ---
`define RESET       4'h0
`define FETCH       4'h1
`define DECODE      4'h2
`define EXEC_LDC    4'h3
`define EXEC_STA    4'h4
`define EXEC_STB    4'h5
`define EXEC_LDA    4'h6
`define WRITE_REGA  4'h7
`define EXEC_LDB    4'h8
`define WRITE_REGB  4'h9
`define EXEC_ALU    4'hA
`define WRITE_RAM   4'hB
`define EXEC_JMP    4'hC
`define EXEC_JMP_2  4'hD
`define EXEC_LDD    4'hE