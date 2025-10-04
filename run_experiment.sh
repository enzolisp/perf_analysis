# Stage 2 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

#!/bin/bash

DOCKER_IMAGE="calor" #nome que defini quando docker build -t calor:latest .
PLANO_CSV="plano.csv"
SRC_DIR="${PWD}/src"
STATS_DIR="${PWD}/docker_stats_results"
LOGS_DIR="${PWD}/docker_logs"
SAMPLING_RATE=0.000001 # Intervalo do docker stats em segundos

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
                "low")  echo 200 200 ;;
                "mid")  echo 350 350 ;;
                "high") echo 500 500 ;;
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

echo "Limpando resultados de execuções anteriores..."
rm -vf "${STATS_DIR}"/*.csv
rm -vf "${LOGS_DIR}"/*.txt

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
    
    stats_file="${STATS_DIR}/${linguagem}_${dimensao}stats.csv"
    log_file="${LOGS_DIR}/${linguagem}_${dimensao}_log.txt"
    
    if [ ! -f "$stats_file" ]; then
    	echo "Timestamp,ContainerID,CPUPerc,MemUsed,MemLimit,NetReceived,NetSent,BlockRead,BlockWritten,Size,L_Value,linguagem,dimensao" > "$stats_file"
    fi
    

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
      #echo "Timestamp,ContainerID,CPUPerc,MemUsage,NetIO,BlockIO"
      while docker top "$container_id" &>/dev/null; do
          timestamp_log=$(date --iso-8601=seconds)
          
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

          # Monta e salva a nova linha do CSV com todas as colunas separadas
          echo "$timestamp_log,$c_id,$c_cpu,$mem_used,$mem_limit,$net_received,$net_sent,$block_read,$block_written,$size,$l_value,$linguagem,$dimensao"
          
          sleep "$SAMPLING_RATE"
		
      done
    ) >> "$stats_file" & #>> concatenar e nao sobrescrever

    docker wait "$container_id" > /dev/null

    (
        echo "-------------------------------------------------------------"
        echo "Run: $linguagem, $dimensao, $size, L=$l_value, Container=${container_id:0:12}"
        echo "Timestamp: $(date +"%Y%m%d-%H%M%S")"
        echo "-------------------------------------------------------------"
        docker logs "$container_id"
        echo "" # Adiciona uma linha em branco para espaçamento
    ) >> "$log_file" 2>&1

    echo "Execução finalizada."

done

echo "-------------------------------------------------------------"
echo "Plano de experimento concluído!"
