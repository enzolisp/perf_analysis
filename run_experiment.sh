#!/bin/bash

# ==============================================================================
# CONFIGURAÇÕES
# ==============================================================================
SRC_DIR=$(pwd)/src
PLANO_FILE=plano.csv
OUTPUT_DIR=stats
PERFORMANCE_DIR=${OUTPUT_DIR}/performance
RESULTS_DIR=${OUTPUT_DIR}/results
IMAGE_NAME="calor:latest"

CPU_SET="0"

# Cria diretórios
mkdir -p "$PERFORMANCE_DIR"
mkdir -p "$RESULTS_DIR"

# Limpa arquivos antigos
rm -f "${PERFORMANCE_DIR}"/*.csv
rm -f "${RESULTS_DIR}"/*.csv

# Função para definir L
get_l_value() {
    local dim=$1
    local sz=$2
    case "$dim" in
        "1d") case "$sz" in "low") echo 1000 ;; "mid") echo 2000 ;; "high") echo 10000 ;; *) echo 1000 ;; esac ;;
        "2d") case "$sz" in "low") echo 500 ;; "mid") echo 750 ;; "high") echo 1000 ;; *) echo 500 ;; esac ;;
        "3d") case "$sz" in "low") echo 50 ;; "mid") echo 75 ;; "high") echo 100 ;; *) echo 50 ;; esac ;;
    esac
}

# ==============================================================================
# LOOP DE EXECUÇÃO
# ==============================================================================
echo "Iniciando experimentos..."

while IFS=, read -r language dimension size; do
    # Limpeza de strings
    language=$(echo "$language" | tr -d '"' | xargs)
    dimension=$(echo "$dimension" | tr -d '"' | xargs)
    size=$(echo "$size" | tr -d '"' | xargs)

    if [[ "$language" == "linguagem" || -z "$language" ]]; then continue; fi

    if [[ "$language" == "julia" ]]; then ext="jl"; cmd="julia"; else ext="py"; cmd="python"; fi
    
    script="${language}/${dimension}.${ext}"
    l_val=$(get_l_value "$dimension" "$size")
    path="/app/${script}"
    
    # Argumentos (CORREÇÃO 3D INCLUÍDA)
    if [[ "$dimension" == "1d" ]]; then args="$l_val"; 
    elif [[ "$dimension" == "2d" ]]; then args="$l_val $l_val"; 
    else args="$l_val $l_val $l_val"; fi

    echo ">>> Executando: $language | $dimension | $size (L=$l_val)"

    # 1. Inicia Container em Background
    container_id=$(docker run -d --cpuset-cpus="$CPU_SET" -v "${SRC_DIR}:/app" "$IMAGE_NAME" $cmd $path $args)

    # Define arquivos de saída
    perf_file="${PERFORMANCE_DIR}/${language}_${dimension}_performance.csv"
    res_file="${RESULTS_DIR}/${language}_${dimension}_results.csv"

    # Cria cabeçalhos se necessário
    if [[ ! -s "$perf_file" ]]; then
        echo "ContainerID,language,dimension,Size,L_Value,Timestamp,CPUPerc,MemUsed,MemLimit,NetReceived,NetSent,BlockRead,BlockWritten" > "$perf_file"
    fi
    if [[ ! -s "$res_file" ]]; then
        echo "ContainerID,language,dimension,Size,L_Value,Timestamp,sum_t0,sum_tmax,t_exec,peak_mem" > "$res_file"
    fi

    # 2. Loop de Monitoramento (Docker Stats)
    # Coleta estatísticas a cada 1s enquanto o container estiver rodando
    while docker ps -q | grep -q "^${container_id:0:12}"; do
        timestamp=$(date +%T)
        
        # Pega stats em formato CSV puro
        stats=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}}" "$container_id")
        
        if [[ -n "$stats" ]]; then
            # Limpa formatação do Docker Stats (ex: separa MemUsed / MemLimit)
            # Formato original: 10.5%, 100MiB / 1GiB, 1kB / 2kB, 0B / 0B
            
            # Remove espaços
            stats=$(echo "$stats" | tr -d ' ')
            
            # Separa os campos compostos (/)
            cpu=$(echo "$stats" | cut -d',' -f1)
            mem_full=$(echo "$stats" | cut -d',' -f2)
            net_full=$(echo "$stats" | cut -d',' -f3)
            blk_full=$(echo "$stats" | cut -d',' -f4)
            
            mem_used=$(echo "$mem_full" | cut -d'/' -f1)
            mem_limit=$(echo "$mem_full" | cut -d'/' -f2)
            net_rx=$(echo "$net_full" | cut -d'/' -f1)
            net_tx=$(echo "$net_full" | cut -d'/' -f2)
            blk_read=$(echo "$blk_full" | cut -d'/' -f1)
            blk_write=$(echo "$blk_full" | cut -d'/' -f2)

            # Salva no arquivo de Performance
            echo "${container_id:0:12},$language,$dimension,$size,$l_val,$timestamp,$cpu,$mem_used,$mem_limit,$net_rx,$net_tx,$blk_read,$blk_write" >> "$perf_file"
        fi
        
        sleep 1
    done

    # 3. Captura Resultados Finais (Do Script Interno)
    logs=$(docker logs "$container_id" 2>&1 | tail -n 1 | tr -d '\r')
    docker rm "$container_id" > /dev/null 2>&1

    if [[ "$logs" == *","* ]]; then
        sum0=$(echo "$logs" | cut -d',' -f1)
        sum1=$(echo "$logs" | cut -d',' -f2)
        exec_time=$(echo "$logs" | cut -d',' -f3)
        peak_mem=$(echo "$logs" | cut -d',' -f4)
        
        timestamp_end=$(date +%T)
        echo "${container_id:0:12},$language,$dimension,$size,$l_val,$timestamp_end,$sum0,$sum1,$exec_time,$peak_mem" >> "$res_file"
        echo "    Finalizado: Tempo=${exec_time}s"
    else
        echo "    ERRO: Script falhou ou não retornou CSV. Logs: $logs"
    fi

done < "$PLANO_FILE"

echo "Experimento concluído."
