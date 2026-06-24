`include "Definitions.v"

module ControlUnit (
    input wire clk,
    input wire rst,

    // --- Entradas ---
    input wire [11:0] instruction,
    input wire [7:0] aluResult,

    // --- Saidas para o Datapath ---
    output reg pcLoadEnable,
    output reg pcIncEnable,
    output reg regWriteEnableA,
    output reg regWriteEnableB,
    output reg regAInMuxSel,  // 0: RAM, 1: Imediato
    output reg regBInMuxSel,  // 0: RAM, 1: Imediato
    output reg aluIn2MuxSel,  // 0: Reg B, 1: Zero
    output reg [1:0] ramInMuxSel, // 00: ALU, 01: Reg A, 10: Reg B
    output reg [3:0] aluSelector, 

    // --- Saida para a RAM ---
    output reg ramWriteEnable
);

    wire [3:0] opcode;
    assign opcode = instruction[11:8];

    reg [3:0] state, nextState;
    reg [3:0] instructionRegister; // Armazena o opcode da instrucao atual

    // --- Logica Sequencial (Registradores de Estado) ---
    always @(posedge clk) begin
        if (rst) begin
            state <= `RESET;
            instructionRegister <= `LDD; // Reseta para um NOP/Padrao
        end else begin
            state <= nextState;
            if (state == `DECODE) begin // "Trava" o opcode no estado DECODE para usa-lo depois
                instructionRegister <= opcode;
            end
        end
    end

    // --- Logica Combinacional (Saidas e Proximo Estado) ---
    always @(*) begin
        // Valores Padrao, evitar latches.
        pcLoadEnable    = 1'b0;
        pcIncEnable     = 1'b0;
        regWriteEnableA = 1'b0;
        regWriteEnableB = 1'b0;
        regAInMuxSel    = 1'b0;
        regBInMuxSel    = 1'b0;
        aluIn2MuxSel    = 1'b0;     // Padrao: Reg B
        ramInMuxSel     = 2'b00;    // Padrao: ALU
        ramWriteEnable  = 1'b0;
        aluSelector     = `LDD;     // Padrao
        nextState       = `FETCH;

        // Logica de Estados
        case (state)
            `RESET: nextState = `FETCH;
            `FETCH: nextState = `DECODE;

            `DECODE: begin
                case (opcode)
                    `LDC: nextState = `EXEC_LDC;
                    `LDD: nextState = `EXEC_LDD; // Vai para o novo estado
                    `STA: nextState = `EXEC_STA;
                    `STB: nextState = `EXEC_STB;
                    `LDA: nextState = `EXEC_LDA;
                    `LDB: nextState = `EXEC_LDB;
                    `JMP: nextState = `EXEC_JMP;
                    `ADD, `SUB, `AND, `OR, `XOR, `MUL, `DIV, `NOT, `CMP: 
                        nextState = `EXEC_ALU;
                    default: nextState = `FETCH;
                endcase
            end

            // --- Estados 1 Ciclo ---
            `EXEC_LDC: begin
                regAInMuxSel    = 1'b1; // Imediato
                regWriteEnableA = 1'b1; // Habilita escrita em REGA
                pcIncEnable     = 1'b1;
                nextState       = `FETCH;
            end
            `EXEC_LDD: begin
                regBInMuxSel    = 1'b1;
                regWriteEnableB = 1'b1;
                pcIncEnable     = 1'b1;
                nextState       = `FETCH;
            end
            `EXEC_STA: begin
                ramInMuxSel    = 2'b01;
                ramWriteEnable = 1'b1;
                pcIncEnable    = 1'b1;
                nextState      = `FETCH;
            end
            `EXEC_STB: begin
                ramInMuxSel    = 2'b10;
                ramWriteEnable = 1'b1;
                pcIncEnable    = 1'b1;
                nextState      = `FETCH;
            end


            // --- Estados Multi-Ciclo ---
            `EXEC_LDA: begin
                regAInMuxSel = 1'b0;
                nextState    = `WRITE_REGA;
            end
            `WRITE_REGA: begin
                regWriteEnableA = 1'b1;
                pcIncEnable     = 1'b1;
                nextState       = `FETCH;
            end
            `EXEC_LDB: begin
                regBInMuxSel = 1'b0;
                nextState    = `WRITE_REGB;
            end
            `WRITE_REGB: begin
                regWriteEnableB = 1'b1;
                pcIncEnable     = 1'b1;
                nextState       = `FETCH;
            end

            // --- Estados da ALU ---
            `EXEC_ALU: begin
                aluIn2MuxSel = 1'b0; // Seleciona Reg B
                aluSelector  = instructionRegister; // Usa o opcode que foi "travado" no registrador
                nextState    = `WRITE_RAM;
            end
            
            `WRITE_RAM: begin
                aluIn2MuxSel = 1'b0; // MANTEM os sinais da ULA estaveis
                aluSelector  = instructionRegister;
                ramInMuxSel    = 2'b00; // Seleciona resultado da ALU
                ramWriteEnable = 1'b1;  // Escreve na RAM
                pcIncEnable    = 1'b1;
                nextState      = `FETCH;
            end

            `EXEC_JMP: begin
                aluIn2MuxSel = 1'b1; // Seleciona Zero
                aluSelector  = `CMP; // Forca Comparacao
                nextState    = `EXEC_JMP_2;
            end
            
            `EXEC_JMP_2: begin
                // MANTEM os sinais da ULA estaveis
                aluIn2MuxSel = 1'b1;
                aluSelector  = `CMP;
                
                if (aluResult == 8'h00) begin 
                    pcLoadEnable = 1'b1; // Pula
                end else begin
                    pcIncEnable = 1'b1; // Nao Pula
                end
                nextState = `FETCH;
            end

            default: begin
                nextState = `RESET;
            end
        endcase
    end

endmodule