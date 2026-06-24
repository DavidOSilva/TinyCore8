import sys

def converter_para_binario_8_bits(valor_str):
    """Converte um valor (decimal, hex, binario) para um string binario de 8 bits."""
    
    # Remove espacos em branco das bordas
    valor_str = valor_str.strip()
    
    # Remove o prefixo '#' se ele existir
    if valor_str.startswith('#'):
        valor_str = valor_str[1:]

    if not valor_str:
        return "00000000"

    try:
        if valor_str.startswith('-'):
            # Trata numeros negativos usando complemento de dois
            valor_int = int(valor_str[1:])
            if valor_int > 128:
                raise ValueError("Valor negativo fora do range de 8 bits")
            # Calcula complemento de dois
            binario = bin((1 << 8) - valor_int)[2:]
            return binario.zfill(8)
            
        elif valor_str.startswith('0x') or valor_str.endswith('h') or valor_str.endswith('H'):
            # Hexadecimal (ex: 0x1A, 1Ah, 1AH)
            valor_str = valor_str.replace('0x', '').replace('h', '').replace('H', '')
            valor_int = int(valor_str, 16)
        
        elif valor_str.startswith('0b'):
            # Binario
            valor_int = int(valor_str[2:], 2)
            
        elif valor_str.isdigit():
            # Decimal
            valor_int = int(valor_str)
            
        else:
            # Tenta tratar como Hexadecimal sem prefixo (ex: 05)
            # Nota: Isso assume que 'FF' e 255 e nao um nome de variavel
            valor_int = int(valor_str, 16)

        if valor_int < 0 or valor_int > 255:
            raise ValueError(f"Valor {valor_int} fora do range de 8 bits (0-255)")
            
        return bin(valor_int)[2:].zfill(8)
            
    except Exception as e:
        print(f"[Erro no Operando] Nao foi possivel converter '{valor_str}': {e}", file=sys.stderr)
        return None

def converter_opcode_4bit(opcode_str):
    """Converte o mnemonico da instrucao para seu opcode binario de 4 bits."""
    
    opcodes_map = {
        # Opcodes Minimos
        'add': '0000',
        'sub': '0001',
        'lda': '0010',
        'sta': '0011',
        'ldb': '0100',
        'stb': '0101',
        'ldc': '0110',
        'jmp': '0111',
        # Opcodes Adicionais
        'and': '1000',
        'or':  '1001',
        'xor': '1010',
        'not': '1011',
        'mul': '1100',
        'div': '1101',
        'cmp': '1110',
        'ldd': '1111'
    }
    
    return opcodes_map.get(opcode_str.lower(), None)

def ler_arquivo(nome_arquivo):
    try:
        with open(nome_arquivo, 'r') as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"[Erro] Arquivo nao encontrado: {nome_arquivo}", file=sys.stderr)
        return None

def escrever_arquivo_mif(nome_arquivo, linhas):
    try:
        with open(nome_arquivo, 'w') as f:
            f.writelines(linhas)
        return True
    except IOError as e:
        print(f"[Erro] Nao foi possivel escrever em {nome_arquivo}: {e}", file=sys.stderr)
        return False