import subprocess
import random
import csv
import itertools
import sys
from pathlib import Path

REPLICATIONS = 10
RESULTS_FILE = "results.csv"
LOG_FILE = "experiment.log" 

factors = {
    "linguagem": ["python", "julia"],
    "dimensao": ["1d", "2d"],
    "size": ["low", "high"]
}

size_map = {
    "1d": {"low": 500, "high": 2000},
    "2d": {"low": 200, "high": 500}
}

def checarArqs():
    arqs = [
        "1d.py", "2d.py",
        "1d.jl", "2d.jl"
    ]
    arqsFaltando = [f for f in arqs if not Path(f).exists()]
    if arqsFaltando:
        print("Erro: arquivos não encontrados:")
        for f in arqsFaltando:
            print(f"- {f}")
        sys.exit(1)

def gerarExperimentos():
    """lista de todas as combinações de experimentos possiveis"""
    plan = list(itertools.product(*factors.values()))
    reaplicacoes = plan * REPLICATIONS
    random.shuffle(reaplicacoes)
    return reaplicacoes

def rodarUmaVez(linguagem, dimensao, valorL):
    """Executa um único teste e retorna o resultado e a saída completa."""
    l_value = size_map[dimensao][valorL]
    
    if linguagem == "python":
        nomeScript = f"{dimensao}.py"
        command = ["python3", nomeScript, str(l_value)]
    elif linguagem == "julia":
        nomeScript = f"{dimensao}.jl"
        command = ["julia", "--project", "-O3", "--check-bounds=no", nomeScript, str(l_value)]

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )
        full_output = result.stdout.strip()
        
        # Pega apenas a última linha para os dados de tempo/memória
        last_line = full_output.splitlines()[-1]
        time, memory = map(float, last_line.split(','))
        
        return time, memory, full_output
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o comando: {' '.join(command)}")
        print(f"Saída de erro:\n{e.stderr}")
        return None, None, e.stderr
    except Exception as e:
        print(f"Uma exceção inesperada ocorreu: {e}")
        return None, None, str(e)

def main():
    print("--- Iniciando Experimento de Avaliação de Desempenho ---")
    checarArqs()
    
    plan = gerarExperimentos()
    qtdExecucoes = len(plan)
    print(f"Plano de experimento gerado com {qtdExecucoes} execuções (incluindo replicações).")
    
    # Prepara o arquivo de resultados CSV
    with open(RESULTS_FILE, "w", newline="", encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["linguagem", "dimensao", "size", "l_value", "execution_time_s", "peak_memory_bytes"])
        
    # Limpa/Cria o arquivo de log
    with open(LOG_FILE, "w", encoding='utf-8') as f:
        f.write(f"Log do Experimento - {qtdExecucoes} execuções planejadas\n")
        f.write("="*50 + "\n\n")

    for i, (linguagem, dimensao, valorL) in enumerate(plan, 1):
        l_value = size_map[dimensao][valorL]
        print(f"Executando [{i}/{qtdExecucoes}]: Lang={linguagem}, Dim={dimensao}, Size={valorL} (L={l_value})... ", end="")
        
        time, memory, full_output = rodarUmaVez(linguagem, dimensao, valorL)
        
        # Salva a saída completa no arquivo de log
        with open(LOG_FILE, "a", encoding='utf-8') as f:
            header = f"--- Execução [{i}/{qtdExecucoes}]: {linguagem}, {dimensao}, {valorL} (L={l_value}) ---\n"
            f.write(header)
            f.write(full_output + "\n")
            f.write("-" * len(header) + "\n\n")

        if time is not None:
            # Salva o resultado numérico no CSV
            with open(RESULTS_FILE, "a", newline="", encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow([linguagem, dimensao, valorL, l_value, time, memory])
            print("Concluído.")
        else:
            print("Falhou.")

    print("\n--- Experimento Finalizado ---")
    print(f"Resultados salvos em '{RESULTS_FILE}'.")
    print(f"Log completo salvo em '{LOG_FILE}'.")

if __name__ == "__main__":
    main()
