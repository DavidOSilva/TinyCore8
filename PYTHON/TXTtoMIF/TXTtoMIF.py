from utils import *

def TXT_to_MIF(arquivo_txt, arquivo_mif):
    
    linhas_txt = ler_arquivo(arquivo_txt)
    linhas_mif_originais = ler_arquivo(arquivo_mif)
    
    if linhas_txt is None or linhas_mif_originais is None:
        print("Conversao falhou: Nao foi possivel ler os arquivos de entrada.")
        return

    # --- Encontra o cabecalho do MIF ---
    try:
        content_begin_index = -1
        for i, linha in enumerate(linhas_mif_originais):
            if "CONTENT BEGIN" in linha.upper():
                content_begin_index = i
                break
        
        if content_begin_index == -1:
            print("[Erro] Arquivo .mif de entrada nao parece ter um cabecalho valido (Faltando 'CONTENT BEGIN').")
            return
            
        novo_mif_header = linhas_mif_originais[:content_begin_index + 1]
        
    except Exception as e:
        print(f"[Erro] Falha ao processar o cabecalho do .mif: {e}")
        return

    # --- Processa o .txt e gera o programa ---
    programa_mif = []
    linha_atual_txt = 0
    
    for i, linha_raw in enumerate(linhas_txt):
        linha_limpa = linha_raw.strip()
        
        # Ignora comentarios (iniciados com -- ou #) e linhas vazias
        if not linha_limpa or linha_limpa.startswith('--') or linha_limpa.startswith('#'):
            continue
            
        if linha_atual_txt > 255:
            print(f"[Erro] O programa .txt tem mais de 256 instrucoes. Limite da ROM excedido.")
            return

        elementos = linha_limpa.split(maxsplit=1)
        opcode_str = elementos[0]
        operando_str = elementos[1] if len(elementos) > 1 else ""

        # Converte opcode
        opcode_bin = converter_opcode_4bit(opcode_str)
        if opcode_bin is None:
            print(f"[Erro na Linha {i+1}] Opcode desconhecido: '{opcode_str}'")
            return

        # Converte operando (agora com suporte a #)
        operando_bin = converter_para_binario_8_bits(operando_str)
        if operando_bin is None:
            print(f"[Erro na Linha {i+1}] Operando invalido: '{operando_str}'")
            return

        # --- Formata a linha .mif (12 bits) ---
        instrucao_bin_12bits = f"{opcode_bin}{operando_bin}"
        linha_mif_formatada = f"\t{linha_atual_txt}\t:\t{instrucao_bin_12bits};\n"
        
        programa_mif.append(linha_mif_formatada)
        linha_atual_txt += 1

    # --- Preenche o resto da ROM ---
    if linha_atual_txt < 256:
        default_fill_inst = "111111111111" # LDD #0
        programa_mif.append(f"\t[{linha_atual_txt}..255]\t:\t{default_fill_inst};\n")

    programa_mif.append("END;\n")

    # --- Monta e escreve o arquivo final ---
    novo_mif_completo = novo_mif_header + programa_mif
    
    if escrever_arquivo_mif(arquivo_mif, novo_mif_completo):
        print(f"Sucesso! Arquivo '{arquivo_mif}' foi atualizado com o programa de '{arquivo_txt}'.")

# --- Exemplo de Uso ---
if __name__ == "__main__": 
    # Tenta rodar a conversao
    TXT_to_MIF("programa.txt", r"../TinyCore8/ProgramData.mif")