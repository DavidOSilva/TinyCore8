module Datapath (
    input wire clk,
    input wire rst,

    // --- Entradas do Top-Level ---
    input wire [11:0] instruction,  // ROM de Instrucoes
    input wire [7:0] dataFromRam,   // RAM de Dados (leitura)

    // --- Sinais de Controle (da CPUControl) ---
    // PC
    input wire pcLoadEnable,
    input wire pcIncEnable,
	 
    // Banco de Registradores
    input wire regWriteEnableA,
    input wire regWriteEnableB,
	 
    // Seletores dos MUXes
    input wire regAInMuxSel,        // 0: RAM (LDA), 1: Imediato
    input wire regBInMuxSel,        // 0: RAM (LDB), 1: Imediato
    input wire aluIn2MuxSel,        // 0: Reg B, 1: Zero (para CMP A==0)
    input wire [1:0] ramInMuxSel,   // 00: ALU, 01: Reg A, 10: Reg B
	 
    // ULA
    input wire [3:0] aluSelector,

    // --- Saidas para o Top-Level ---
    output wire [7:0] addrToRom,  // Endereco para ROM de Instrucoes
    output wire [7:0] addrToRam, // Endereco para RAM de Dados
	 
    // Dado para RAM de Dados (escrita)
    output wire [7:0] dataToRam,  
    
    // Saida da ULA (para JMP condicional)
    output wire [7:0] aluOutResult,  
    
    // Saidas dos Registradores (para debug)
    output wire [7:0] registerAOut,
    output wire [7:0] registerBOut
);

    // --- Fios Internos ---
    wire [7:0] immediateValue;

    // Banco de Registradores
    wire [7:0] regInA, regOutA;
    wire [7:0] regInB, regOutB;

    // ULA
    wire [7:0] aluIn1, aluIn2;
    wire [7:0] aluOut;
    wire aluCout;


    assign immediateValue = instruction[7:0];
    assign addrToRam = immediateValue;

    // MUX: Seleciona as entradas dos Registradores A e B (da RAM ou imediato)
    assign regInA = (regAInMuxSel == 1'b0) ? dataFromRam : immediateValue;
    assign regInB = (regBInMuxSel == 1'b0) ? dataFromRam : immediateValue; // LDB : LDD (Carrega uma cte no reg B)

    // Entradas da ULA (RegA e MUX para in2)
    assign aluIn1 = regOutA; // in1 da ULA e sempre o regA
    assign aluIn2 = (aluIn2MuxSel == 1'b0) ? regOutB : 8'h00; // MUX: Seleciona que vai parar in2 da ULA (regB para ADD, SUB etc. ou zero para JMP)

    // MUX: Seleciona o dado a ser escrito na RAM
    reg [7:0] dataToRamMuxOut;
    always @(*) begin
        case (ramInMuxSel)
            2'b00:  dataToRamMuxOut = aluOut;    // Resultado (ADD, SUB)
            2'b01:  dataToRamMuxOut = regOutA;   // Registrador A (STA)
            2'b10:  dataToRamMuxOut = regOutB;   // Registrador B (STB)
            default: dataToRamMuxOut = 8'h00;    // Padrao
        endcase
    end
    assign dataToRam = dataToRamMuxOut;

    ProgramCounter pcInst (
        .clk(clk),
        .reset(rst),
        .loadEnable(pcLoadEnable),
        .incEnable(pcIncEnable),
        .dataIn(immediateValue), // JMP carrega o imediato
        .pcOut(addrToRom)
    );
    
    RegisterBank regBankInst (
        .clk(clk),
        .reset(rst),
        .dataInA(regInA),
        .writeEnableA(regWriteEnableA),
        .dataInB(regInB),
        .writeEnableB(regWriteEnableB),
        .dataOutA(regOutA),
        .dataOutB(regOutB)
    );

    ArithmeticLogicUnit aluInst (
        .in1(aluIn1),
        .in2(aluIn2),
        .selector(aluSelector),
        .out(aluOut),
        .cout(aluCout)
    );
    
    assign aluOutResult = aluOut;
    assign registerAOut = regOutA;
    assign registerBOut = regOutB;

endmodule