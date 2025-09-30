using PyPlot

function run_simulation()
    L = 500 # Aumentado para uma melhor comparação de desempenho
    D = 1.0
    dt = 0.05
    dx = 1.0
    t = 0.0
    tmax = 100.0
    k = D * dt / (dx * dx)

    x = collect(0:1:L-1)
    f = zeros(L)  # Array para o estado atual
    
    a = trunc(Int, L/3)
    b = trunc(Int, 2*L/3)

    f[a+1:b] .= 1.0
    f_inicial = deepcopy(f) # Guarda o estado inicial para o plot
    f1 = deepcopy(f)        # Array para o próximo estado

    # Este é o núcleo computacional
    while t < tmax
        t += dt
		# Use a macro @. APENAS na operação que envolve slices de array ESSE @ FAZ FICAR MAIS EFICIENTE
   		 @views @. f1[2:L-1] = f[2:L-1] + k*(f[1:L-2] + f[3:L] - 2*f[2:L-1])

   		 # Para os elementos únicos nas bordas, a forma original já é eficiente e correta
   		 f1[L] = f[L] + k*(f[L-1] + f[1] - 2*f[L])
   		 f1[1] = f[1] + k*(f[2] + f[L] - 2*f[1])

        # Troca os arrays para a próxima iteração, sem copiar dados
        f, f1 = f1, f
    end

    return f, f_inicial, x
end

# 1. Execução de "aquecimento" para compilar tudo
println("Executando para compilação...")
run_simulation()

# 2. Medindo o tempo de execução real
println("\nExecutando para medição de tempo...")
@time f, f_inicial, x = run_simulation()

sum0 = sum(f)
sum1 = sum(f_inicial)

println("\nIntegral em tmax: ", sum0)
println("Integral em t=0: ", sum1)


plt.plot(x, f, x, f_inicial)
plt.show()
