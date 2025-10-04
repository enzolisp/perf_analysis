# Stage 2 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

function run_simulation_2d(L1, L2)
    D = 1.0
    dt = 0.05
    dx = 1.0
    t = 0.0
    tmax = 100.0
    k = D * dt / (dx * dx)

    f = zeros(Float64, L1, L2)
    
    a1 = trunc(Int, L1 / 3)
    b1 = trunc(Int, 2 * L1 / 3)
    a2 = trunc(Int, L2 / 3)
    b2 = trunc(Int, 2 * L2 / 3)
  
    f[a1+1:b1, a2+1:b2] .= 1.0
    f1 = similar(f)
    f2 = deepcopy(f)

    while t < tmax
        t += dt
        
        @views @. f1[2:L1-1, 2:L2-1] = f[2:L1-1, 2:L2-1] + k * (f[1:L1-2, 2:L2-1] + f[3:L1, 2:L2-1] + f[2:L1-1, 1:L2-2] + f[2:L1-1, 3:L2] - 4 * f[2:L1-1, 2:L2-1])
        @views @. f1[1, 2:L2-1] = f[1, 2:L2-1] + k * (f[L1, 2:L2-1] + f[2, 2:L2-1] + f[1, 1:L2-2] + f[1, 3:L2] - 4 * f[1, 2:L2-1])
        @views @. f1[L1, 2:L2-1] = f[L1, 2:L2-1] + k * (f[L1-1, 2:L2-1] + f[1, 2:L2-1] + f[L1, 1:L2-2] + f[L1, 3:L2] - 4 * f[L1, 2:L2-1])
        @views @. f1[2:L1-1, 1] = f[2:L1-1, 1] + k * (f[1:L1-2, 1] + f[3:L1, 1] + f[2:L1-1, L2] + f[2:L1-1, 2] - 4 * f[2:L1-1, 1])
        @views @. f1[2:L1-1, L2] = f[2:L1-1, L2] + k * (f[1:L1-2, L2] + f[3:L1, L2] + f[2:L1-1, L2-1] + f[2:L1-1, 1] - 4 * f[2:L1-1, L2])
        f1[1, 1] = f[1, 1] + k * (f[L1, 1] + f[2, 1] + f[1, L2] + f[1, 2] - 4 * f[1, 1])
        f1[L1, 1] = f[L1, 1] + k * (f[L1-1, 1] + f[1, 1] + f[L1, L2] + f[L1, 2] - 4 * f[L1, 1])
        f1[1, L2] = f[1, L2] + k * (f[L1, L2] + f[2, L2] + f[1, L2-1] + f[1, 1] - 4 * f[1, L2])
        f1[L1, L2] = f[L1, L2] + k * (f[L1-1, L2] + f[1, L2] + f[L1, L2-1] + f[L1, 1] - 4 * f[L1, L2])

        f, f1 = f1, f
    end
    
    sum0 = sum(f1)
	sum1 = sum(f2)
	
	return sum0, sum1
    
end

function main()
    if length(ARGS) != 2
        println("Uso: julia 2d_modified.jl <L>")
        exit(1)
    end
    L1 = parse(Int, ARGS[1])
    L2 = parse(Int, ARGS[2])

    # Aquecimento
    run_simulation_2d(10,10)

    # Medição
    stats = @timed run_simulation_2d(L1,L2)
    
    sum_inicial, sum_final = stats.value
    
    println("Integral em t=0: ", sum_inicial)
	println("Integral em tmax: ", sum_final)
    
    println("$(stats.time),$(stats.bytes)")
end

main()
