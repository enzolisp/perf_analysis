#one script to rull them all
import subprocess
import sys
import os

def run_command(command, work_dir=None):
    dir_msg = f" (em {work_dir})" if work_dir else ""
    print(f"Executando: {' '.join(command)}{dir_msg}")
    
    try:
        subprocess.run(command, check=True, cwd=work_dir)
    except subprocess.CalledProcessError as e:
        print(f"Erro na execução. Código de saída: {e.returncode}")
        sys.exit(1)
    except FileNotFoundError:
        print(f"Comando não encontrado: {command[0]}")
        sys.exit(1)

def main():
    while True:
        resposta = input("Deseja rodar o experimento completo (Docker build + Run)? [s/n]: ").strip().lower()
        if resposta in ['s', 'n']:
            break

    if resposta == 's':
        run_command(["docker", "build", "-t", "calor:latest", "."])

        if os.path.exists("rand_exp.R"):
            run_command(["Rscript", "rand_exp.R"])
        else:
            print("AVISO: rand_exp.R não encontrado.")
            
        if os.path.exists("run_experiment.sh"):
            os.chmod("run_experiment.sh", 0o755)
            run_command(["./run_experiment.sh"])
        else:
            print("ERRO: run_experiment.sh não encontrado.")
            sys.exit(1)

    print("\n--- Geração de Gráficos ---")

    scripts_raiz = [
        "regressaoMemPeak.R",
        "gerarGraficos.R", 
        "regressaoMediaMem.R",
        "regressao_varianca.R"
    ]

    for script in scripts_raiz:
        if os.path.exists(script):
            run_command(["Rscript", script])
        else:
            print(f"AVISO: Script não encontrado na raiz: {script}")

    dir_perf = "stats/performance"
    script_perf = "plotMemUse.R"
    if os.path.exists(os.path.join(dir_perf, script_perf)):
        run_command(["Rscript", script_perf], work_dir=dir_perf)
    else:
        print(f"AVISO: {script_perf} não encontrado em {dir_perf}")

    dir_results = "stats/results"
    script_results = "gerarBoxplot.R"
    
    if os.path.exists(os.path.join(dir_results, script_results)):
        run_command(["Rscript", script_results], work_dir=dir_results)
    else:
        print(f"AVISO: {script_results} não encontrado em {dir_results}")

    print("\nProcesso totalmente concluído.")

if __name__ == "__main__":
    main()
