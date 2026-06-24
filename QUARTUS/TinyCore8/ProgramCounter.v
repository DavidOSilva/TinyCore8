module ProgramCounter (
    input wire clk,
    input wire reset,

    // Sinais de controle vindos da FSM
    input wire loadEnable,   // Habilita a carga de um novo endereco (JMP)
    input wire incEnable,    // Habilita o incremento do PC (proxima instrucao)

    // Barramento de dados de entrada (para o JMP)
    input wire [7:0] dataIn,

    // Saida do endereco atual
    output wire [7:0] pcOut
);

    // Registrador interno que armazena o PC
    reg [7:0] pcReg = 8'h00;

    always @(posedge clk) begin
        if (reset) begin
            pcReg <= 8'h00;
        end
        else if (loadEnable) begin
            // Prioriza o JUMP (carga) sobre o incremento
            pcReg <= dataIn;
        end
        else if (incEnable) begin
            pcReg <= pcReg + 1;
        end
    end

    // Disponibiliza o valor do PC na saida
    assign pcOut = pcReg;

endmodule