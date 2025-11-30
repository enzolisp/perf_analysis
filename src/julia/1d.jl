# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

function run_simulation(L)
    D = 1.0
    dt = 0.05
    dx = 1.0
    t = 0.0
    tmax = 100.0
    k = D * dt / (dx * dx)

    f = zeros(Float64, L)
    
    a = trunc(Int, L/3)
    b = trunc(Int, 2*L/3)

    f[a+1:b] .= 1.0
    f1 = similar(f)
    f2 = deepcopy(f)

    while t < tmax
        t += dt
		@views @. f1[2:L-1] = f[2:L-1] + k*(f[1:L-2] + f[3:L] - 2*f[2:L-1])
   		f1[L] = f[L] + k*(f[L-1] + f[1] - 2*f[L])
   		f1[1] = f[1] + k*(f[2] + f[L] - 2*f[1])
        f, f1 = f1, f
    end
    
    sum0 = sum(f1)
	sum1 = sum(f2)
	
	return sum0, sum1
    
end

function main()
    if length(ARGS) != 1
        println("Uso: julia 1d_modified.jl <L>")
        exit(1)
    end

    L = parse(Int, ARGS[1])
    
    #JIT compilation
    run_simulation(10)

    # Execução para medição
    stats = @timed run_simulation(L)
    
    sum_inicial, sum_final = stats.value
     
    println("$(sum_inicial),$(sum_final),$(stats.time),$(stats.bytes)")
end

main()
