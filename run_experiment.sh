# Stage 2 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

#!/bin/bash

DOCKER_IMAGE="calor" #nome que defini quando docker build -t calor:latest .
PLANO_CSV="plano.csv"
SRC_DIR="${PWD}/src"
STATS_DIR="${PWD}/stats"
SAMPLING_RATE=0.000001 # Intervalo do docker stats em segundos

get_l_value() {
    local dimension=$1
    local size=$2
    case "$dimension" in
        "1d")
            case "$size" in
                "low")  echo 500000 ;;
                "mid")  echo 1000000 ;;
                "high") echo 5000000 ;;
            esac
            ;;
        "2d")
            case "$size" in
                "low")  echo 500 ;;
                "mid")  echo 750 ;;
                "high") echo 1000 ;;
            esac
            ;;
    esac
}

echo "Verificando a imagem Docker '$DOCKER_IMAGE'..."
if [[ "$(docker images -q $DOCKER_IMAGE 2> /dev/null)" == "" ]]; then
    echo "ERRO: A imagem Docker '$DOCKER_IMAGE' não foi encontrada."
    echo "Por favor, construa a imagem usando o Dockerfile fornecido e tente novamente."
    exit 1
fi

echo "Preparando diretórios para resultados..."
mkdir -p "$STATS_DIR/performance"
mkdir -p "$STATS_DIR/results"

 if ls -A "$STATS_DIR/performance" | read -r || ls -A "$STATS_DIR/results" | read -r; then
    echo "Limpando resultados de execuções anteriores..."
    rm -vf "${STATS_DIR}"/performance/*.csv
    rm -vf "${STATS_DIR}"/results/*.csv
fi

# Lê o CSV, pulando a primeira linha (cabeçalho)
tail -n +2 "$PLANO_CSV" | while IFS=',' read -r language dimension size; do
    # Remove aspas que podem vir do CSV
    language=$(echo "$language" | tr -d '"')
    dimension=$(echo "$dimension" | tr -d '"')
    size=$(echo "$size" | tr -d '"')

    # Obter o valor de L
    l_value=$(get_l_value "$dimension" "$size")
    if [[ -z "$l_value" ]]; then
        echo "AVISO: Combinação inválida encontrada: $dimension, $size. Pulando..."
        continue
    fi

    script_file="${language}/${dimension}.$( [[ $language == "python" ]] && echo "py" || echo "jl" )"
    
    # rodar usando valores de L iguais para todas as dimensoes
    if [[ $dimension == "1d" ]]; then
        run_command="$language $script_file $l_value"
    elif [[ $dimension == "2d" ]]; then
        run_command="$language $script_file $l_value $l_value"
    elif [[ $dimension == "3d" ]]; then
        run_command="$language $script_file $l_value $l_value"
    fi

    performance_stats_file="${STATS_DIR}/performance/${language}_${dimension}_performance.csv"
    results_stats_file="${STATS_DIR}/results/${language}_${dimension}_results.csv"

    if [ ! -f "$performance_stats_file" ]; then
    	echo "ContainerID,language,dimension,Size,L_Value,Timestamp,CPUPerc,MemUsed,MemLimit,NetReceived,NetSent,BlockRead,BlockWritten" > "$performance_stats_file"
    fi
    
    if [ ! -f "$results_stats_file" ]; then
    	echo "ContainerID,language,dimension,Size,L_Value,Timestamp,sum_t0,sum_tmax,t_exec,peak_mem" > "$results_stats_file"
    fi

    echo "-------------------------------------------------------------"
    echo "Executando: $run_command"
    
    container_id=$(docker run -d \
        -v "${SRC_DIR}:/app" \
        -w /app \
        "$DOCKER_IMAGE" \
        $run_command)

    echo "Contêiner iniciado com ID: ${container_id:0:12}"
    echo "Inserindo perfomance em: $performance_stats_file"
    echo "Inserindo resultados em: $results_stats_file"
    
    ( 
    while docker top "$container_id" &>/dev/null; do
        #timestamp_log=$(date --iso-8601=seconds)
        timestamp_log=$(date +'%H:%M:%S') # Formato ISO 8601 com fuso horário

        # Usa um separador diferente (pipe '|') para facilitar a leitura em variáveis
        raw_stats=$(docker stats --no-stream --format "{{.ID}}|{{.CPUPerc}}|{{.MemUsage}}|{{.NetIO}}|{{.BlockIO}}" "$container_id")
        
        # Lê a string raw_stats e a divide em variáveis usando o separador '|'
        IFS='|' read -r c_id c_cpu c_mem c_net c_block <<< "$raw_stats"

        # Separa MemUsage ("Usado / Limite")
        mem_used="${c_mem% / *}"
        mem_limit="${c_mem#* / }"

        # Separa NetIO ("Recebido / Enviado")
        net_received="${c_net% / *}"
        net_sent="${c_net#* / }"

        # Separa BlockIO ("Lido / Escrito")
        block_read="${c_block% / *}"
        block_written="${c_block#* / }"

        # extrai as metricas provenientes dos programas
        IFS=',' read -r sum_t0 sum_tmax t_exec peak_mem <<< "$(docker logs "$container_id")"
        
        if [ -z "$sum_t0" ] && [ -z "$sum_tmax" ] && [ -z "$t_exec" ] && [ -z "$peak_mem" ]; then
            echo "$c_id,$language,$dimension,$size,$l_value,$timestamp_log,$c_cpu,$mem_used,$mem_limit,$net_received,$net_sent,$block_read,$block_written" >> "$performance_stats_file"  #>> concatenar e nao sobrescrever            
        else
            echo "$c_id,$language,$dimension,$size,$l_value,$timestamp_log,$sum_t0,$sum_tmax,$t_exec,$peak_mem" >> "$results_stats_file"  #>> concatenar e nao sobrescrever
        fi
        
        sleep "$SAMPLING_RATE"
        
    done
    ) 

    docker wait "$container_id" > /dev/null

    echo "Execução finalizada."

done

echo "-------------------------------------------------------------"
echo "Plano de experimento concluído!"
