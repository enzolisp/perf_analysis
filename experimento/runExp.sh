#!/bin/bash

DOCKER_IMAGE="calor" #nome que defini quando docker build -t calor:latest .
PLANO_CSV="plano.csv"
SRC_DIR="${PWD}/src"
STATS_DIR="${PWD}/docker_stats_results"
LOGS_DIR="${PWD}/docker_logs"
SAMPLING_RATE=0.00001 # Intervalo do docker stats em segundos

get_l_value() {
    local dimensao=$1
    local size=$2
    case "$dimensao" in
        "1d")
            case "$size" in
                "low")  echo 500 ;;
                "mid")  echo 1250 ;;
                "high") echo 2000 ;;
            esac
            ;;
        "2d")
            case "$size" in
                "low")  echo 200 ;;
                "mid")  echo 350 ;;
                "high") echo 500 ;;
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
mkdir -p "$STATS_DIR"
mkdir -p "$LOGS_DIR"

# Lê o CSV, pulando a primeira linha (cabeçalho)
tail -n +2 "$PLANO_CSV" | while IFS=',' read -r linguagem dimensao size; do
    # Remove aspas que podem vir do CSV
    linguagem=$(echo "$linguagem" | tr -d '"')
    dimensao=$(echo "$dimensao" | tr -d '"')
    size=$(echo "$size" | tr -d '"')

    # Obter o valor de L
    l_value=$(get_l_value "$dimensao" "$size")
    if [[ -z "$l_value" ]]; then
        echo "AVISO: Combinação inválida encontrada: $dimensao, $size. Pulando..."
        continue
    fi

    script_file="${dimensao}.$( [[ $linguagem == "python" ]] && echo "py" || echo "jl" )"
    run_command="$linguagem $script_file $l_value"
    
    timestamp=$(date +"%Y%m%d-%H%M%S")
    output_prefix="${timestamp}_${linguagem}_${dimensao}_${size}_L${l_value}"
    stats_file="${STATS_DIR}/${output_prefix}_stats.csv"
    log_file="${LOGS_DIR}/${output_prefix}_log.txt"

    echo "-------------------------------------------------------------"
    echo "Executando: $run_command"
    
    container_id=$(docker run -d \
        -v "${SRC_DIR}:/app" \
        -w /app \
        "$DOCKER_IMAGE" \
        $run_command)

    echo "Contêiner iniciado com ID: ${container_id:0:12}"
    echo "Coletando stats em: $stats_file"
    echo "Logs serão salvos em: $log_file"

    (
      echo "Timestamp,ContainerID,CPUPerc,MemUsage,NetIO,BlockIO"
      while docker top "$container_id" &>/dev/null; do
          timestamp_log=$(date --iso-8601=seconds)
          stats_line=$(docker stats --no-stream --format "{{.ID}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}}" "$container_id")
          echo "$timestamp_log,$stats_line"
          sleep "$SAMPLING_RATE"
      done
    ) > "$stats_file" &

    docker wait "$container_id" > /dev/null

    docker logs "$container_id" > "$log_file" 2>&1

    echo "Execução finalizada."

done

echo "-------------------------------------------------------------"
echo "Plano de experimento concluído!"
