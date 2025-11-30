# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

function run_simulation_3d(L1, L2, L3)
    D = 1.0
    dt = 0.05
    dx = 1.0
    t = 0.0
    tmax = 100.0
    k = D * dt / (dx * dx)

    f = zeros(Float64, L1, L2, L3)
    
    a1 = trunc(Int, L1 / 3)
    b1 = trunc(Int, 2 * L1 / 3)
    a2 = trunc(Int, L2 / 3)
    b2 = trunc(Int, 2 * L2 / 3)
    a3 = trunc(Int, L3 / 3)
    b3 = trunc(Int, 2 * L3 / 3)
  
    f[a1+1:b1, a2+1:b2, a3+1:b3] .= 1.0
    f1 = similar(f)
    f2 = deepcopy(f)

    while t < tmax
        t += dt
        
        # --- Miolo (Core) ---
        # Usa @views @. pois opera em blocos 3D
        @views @. f1[2:L1-1, 2:L2-1, 2:L3-1] = f[2:L1-1, 2:L2-1, 2:L3-1] + k * (f[1:L1-2, 2:L2-1, 2:L3-1] + f[3:L1, 2:L2-1, 2:L3-1] + f[2:L1-1, 1:L2-2, 2:L3-1] + f[2:L1-1, 3:L2, 2:L3-1] + f[2:L1-1, 2:L2-1, 1:L3-2] + f[2:L1-1, 2:L2-1, 3:L3] - 6 * f[2:L1-1, 2:L2-1, 2:L3-1])

        # --- Faces ---
        # Usa @views @. pois opera em fatias 2D
        @views @. f1[1, 2:L2-1, 2:L3-1] = f[1, 2:L2-1, 2:L3-1] + k * (f[L1, 2:L2-1, 2:L3-1] + f[2, 2:L2-1, 2:L3-1] + f[1, 1:L2-2, 2:L3-1] + f[1, 3:L2, 2:L3-1] + f[1, 2:L2-1, 1:L3-2] + f[1, 2:L2-1, 3:L3] - 6 * f[1, 2:L2-1, 2:L3-1])
        @views @. f1[2:L1-1, 1, 2:L3-1] = f[2:L1-1, 1, 2:L3-1] + k * (f[1:L1-2, 1, 2:L3-1] + f[3:L1, 1, 2:L3-1] + f[2:L1-1, L2, 2:L3-1] + f[2:L1-1, 2, 2:L3-1] + f[2:L1-1, 1, 1:L3-2] + f[2:L1-1, 1, 3:L3] - 6 * f[2:L1-1, 1, 2:L3-1])
        @views @. f1[2:L1-1, 2:L2-1, 1] = f[2:L1-1, 2:L2-1, 1] + k * (f[1:L1-2, 2:L2-1, 1] + f[3:L1, 2:L2-1, 1] + f[2:L1-1, 1:L2-2, 1] + f[2:L1-1, 3:L2, 1] + f[2:L1-1, 2:L2-1, L3] + f[2:L1-1, 2:L2-1, 2] - 6 * f[2:L1-1, 2:L2-1, 1])
        @views @. f1[2:L1-1, 2:L2-1, L3] = f[2:L1-1, 2:L2-1, L3] + k * (f[1:L1-2, 2:L2-1, L3] + f[3:L1, 2:L2-1, L3] + f[2:L1-1, 1:L2-2, L3] + f[2:L1-1, 3:L2, L3] + f[2:L1-1, 2:L2-1, L3-1] + f[2:L1-1, 2:L2-1, 1] - 6 * f[2:L1-1, 2:L2-1, L3])
        @views @. f1[2:L1-1, L2, 2:L3-1] = f[2:L1-1, L2, 2:L3-1] + k * (f[1:L1-2, L2, 2:L3-1] + f[3:L1, L2, 2:L3-1] + f[2:L1-1, L2-1, 2:L3-1] + f[2:L1-1, 1, 2:L3-1] + f[2:L1-1, L2, 1:L3-2] + f[2:L1-1, L2, 3:L3] - 6 * f[2:L1-1, L2, 2:L3-1])
        @views @. f1[L1, 2:L2-1, 2:L3-1] = f[L1, 2:L2-1, 2:L3-1] + k * (f[L1-1, 2:L2-1, 2:L3-1] + f[1, 2:L2-1, 2:L3-1] + f[L1, 1:L2-2, 2:L3-1] + f[L1, 3:L2, 2:L3-1] + f[L1, 2:L2-1, 1:L3-2] + f[L1, 2:L2-1, 3:L3] - 6 * f[L1, 2:L2-1, 2:L3-1])

        # --- Arestas (Edges) ---
        # Usa @views @. pois opera em linhas 1D
        @views @. f1[1, 1, 2:L3-1] = f[1, 1, 2:L3-1] + k * (f[L1, 1, 2:L3-1] + f[2, 1, 2:L3-1] + f[1, L2, 2:L3-1] + f[1, 2, 2:L3-1] + f[1, 1, 1:L3-2] + f[1, 1, 3:L3] - 6 * f[1, 1, 2:L3-1])
        @views @. f1[1, 2:L2-1, 1] = f[1, 2:L2-1, 1] + k * (f[L1, 2:L2-1, 1] + f[2, 2:L2-1, 1] + f[1, 1:L2-2, 1] + f[1, 3:L2, 1] + f[1, 2:L2-1, L3] + f[1, 2:L2-1, 2] - 6 * f[1, 2:L2-1, 1])
        @views @. f1[1, 2:L2-1, L3] = f[1, 2:L2-1, L3] + k * (f[L1, 2:L2-1, L3] + f[2, 2:L2-1, L3] + f[1, 1:L2-2, L3] + f[1, 3:L2, L3] + f[1, 2:L2-1, L3-1] + f[1, 2:L2-1, 1] - 6 * f[1, 2:L2-1, L3])
        @views @. f1[1, L2, 2:L3-1] = f[1, L2, 2:L3-1] + k * (f[L1, L2, 2:L3-1] + f[2, L2, 2:L3-1] + f[1, L2-1, 2:L3-1] + f[1, 1, 2:L3-1] + f[1, L2, 1:L3-2] + f[1, L2, 3:L3] - 6 * f[1, L2, 2:L3-1])
        @views @. f1[2:L1-1, 1, 1] = f[2:L1-1, 1, 1] + k * (f[1:L1-2, 1, 1] + f[3:L1, 1, 1] + f[2:L1-1, L2, 1] + f[2:L1-1, 2, 1] + f[2:L1-1, 1, L3] + f[2:L1-1, 1, 2] - 6 * f[2:L1-1, 1, 1])
        @views @. f1[2:L1-1, 1, L3] = f[2:L1-1, 1, L3] + k * (f[1:L1-2, 1, L3] + f[3:L1, 1, L3] + f[2:L1-1, L2, L3] + f[2:L1-1, 2, L3] + f[2:L1-1, 1, L3-1] + f[2:L1-1, 1, 1] - 6 * f[2:L1-1, 1, L3])
        @views @. f1[2:L1-1, L2, 1] = f[2:L1-1, L2, 1] + k * (f[1:L1-2, L2, 1] + f[3:L1, L2, 1] + f[2:L1-1, L2-1, 1] + f[2:L1-1, 1, 1] + f[2:L1-1, L2, L3] + f[2:L1-1, L2, 2] - 6 * f[2:L1-1, L2, 1])
        @views @. f1[2:L1-1, L2, L3] = f[2:L1-1, L2, L3] + k * (f[1:L1-2, L2, L3] + f[3:L1, L2, L3] + f[2:L1-1, L2-1, L3] + f[2:L1-1, 1, L3] + f[2:L1-1, L2, L3-1] + f[2:L1-1, L2, 1] - 6 * f[2:L1-1, L2, L3])
        @views @. f1[L1, 1, 2:L3-1] = f[L1, 1, 2:L3-1] + k * (f[L1-1, 1, 2:L3-1] + f[1, 1, 2:L3-1] + f[L1, L2, 2:L3-1] + f[L1, 2, 2:L3-1] + f[L1, 1, 1:L3-2] + f[L1, 1, 3:L3] - 6 * f[L1, 1, 2:L3-1])
        @views @. f1[L1, 2:L2-1, 1] = f[L1, 2:L2-1, 1] + k * (f[L1-1, 2:L2-1, 1] + f[1, 2:L2-1, 1] + f[L1, 1:L2-2, 1] + f[L1, 3:L2, 1] + f[L1, 2:L2-1, L3] + f[L1, 2:L2-1, 2] - 6 * f[L1, 2:L2-1, 1])
        @views @. f1[L1, 2:L2-1, L3] = f[L1, 2:L2-1, L3] + k * (f[L1-1, 2:L2-1, L3] + f[1, 2:L2-1, L3] + f[L1, 1:L2-2, L3] + f[L1, 3:L2, L3] + f[L1, 2:L2-1, L3-1] + f[L1, 2:L2-1, 1] - 6 * f[L1, 2:L2-1, L3])
        @views @. f1[L1, L2, 2:L3-1] = f[L1, L2, 2:L3-1] + k * (f[L1-1, L2, 2:L3-1] + f[1, L2, 2:L3-1] + f[L1, L2-1, 2:L3-1] + f[L1, 1, 2:L3-1] + f[L1, L2, 1:L3-2] + f[L1, L2, 3:L3] - 6 * f[L1, L2, 2:L3-1])

        # --- Cantos (Corners) ---
        # CORREÇÃO: SEM @views @. (são escalares)
        f1[1, 1, 1] = f[1, 1, 1] + k * (f[L1, 1, 1] + f[2, 1, 1] + f[1, L2, 1] + f[1, 2, 1] + f[1, 1, L3] + f[1, 1, 2] - 6 * f[1, 1, 1])
        f1[1, 1, L3] = f[1, 1, L3] + k * (f[L1, 1, L3] + f[2, 1, L3] + f[1, L2, L3] + f[1, 2, L3] + f[1, 1, L3-1] + f[1, 1, 1] - 6 * f[1, 1, L3])
        f1[1, L2, 1] = f[1, L2, 1] + k * (f[L1, L2, 1] + f[2, L2, 1] + f[1, L2-1, 1] + f[1, 1, 1] + f[1, L2, L3] + f[1, L2, 2] - 6 * f[1, L2, 1])
        f1[1, L2, L3] = f[1, L2, L3] + k * (f[L1, L2, L3] + f[2, L2, L3] + f[1, L2-1, L3] + f[1, 1, L3] + f[1, L2, L3-1] + f[1, L2, 1] - 6 * f[1, L2, L3])
        f1[L1, 1, 1] = f[L1, 1, 1] + k * (f[L1-1, 1, 1] + f[1, 1, 1] + f[L1, L2, 1] + f[L1, 2, 1] + f[L1, 1, L3] + f[L1, 1, 2] - 6 * f[L1, 1, 1])
        f1[L1, 1, L3] = f[L1, 1, L3] + k * (f[L1-1, 1, L3] + f[1, 1, L3] + f[L1, L2, L3] + f[L1, 2, L3] + f[L1, 1, L3-1] + f[L1, 1, 1] - 6 * f[L1, 1, L3])
        f1[L1, L2, 1] = f[L1, L2, 1] + k * (f[L1-1, L2, 1] + f[1, L2, 1] + f[L1, L2-1, 1] + f[L1, 1, 1] + f[L1, L2, L3] + f[L1, L2, 2] - 6 * f[L1, L2, 1])
        f1[L1, L2, L3] = f[L1, L2, L3] + k * (f[L1-1, L2, L3] + f[1, L2, L3] + f[L1, L2-1, L3] + f[L1, 1, L3] + f[L1, L2, L3-1] + f[L1, L2, 1] - 6 * f[L1, L2, L3])

        f, f1 = f1, f
    end
    
    sum0 = sum(f1)
	sum1 = sum(f2)
	
	return sum0, sum1
    
end

function main()
    if length(ARGS) != 3
        println("Uso: julia 3d.jl <L1> <L2> <L3>")
        exit(1)
    end
    L1 = parse(Int, ARGS[1])
    L2 = parse(Int, ARGS[2])
    L3 = parse(Int, ARGS[3])

    # Aquecimento
    run_simulation_3d(10,10,10)

    # Medição
    stats = @timed run_simulation_3d(L1,L2,L3)
    
    sum_inicial, sum_final = stats.value
    
    println("$(sum_inicial),$(sum_final),$(stats.time),$(stats.bytes)")
end

main()
