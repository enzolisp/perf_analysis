# Importa a biblioteca de plotagem, similar ao Matplotlib do Python
using PyPlot

function run_simulation_2d()
    # Parâmetros da simulação
    L = 200
    D = 1.0
    dt = 0.05
    dx = 1.0
    t = 0.0
    tmax = 100.0
    k = D * dt / (dx * dx)

    f = zeros(L, L)
    
    a = trunc(Int, L / 3)
    b = trunc(Int, 2 * L / 3)
    f[a+1:b, a+1:b] .= 1.0

    # ALTERAÇÃO 1: Usar copy() é mais eficiente que deepcopy() para arrays simples.
    f_inicial = copy(f)
    
    # ALTERAÇÃO 2: Usar similar() é a forma ideal para criar um array "buffer".
    # Ele aloca um array com o mesmo tamanho e tipo, mas sem copiar os valores.
    f1 = similar(f)

    while t < tmax
        t += dt
        
        # O núcleo computacional permanece o mesmo...
        @views @. f1[2:L-1, 2:L-1] = f[2:L-1, 2:L-1] + k * (f[1:L-2, 2:L-1] + f[3:L, 2:L-1] + f[2:L-1, 1:L-2] + f[2:L-1, 3:L] - 4 * f[2:L-1, 2:L-1])
        
        @views @. f1[1, 2:L-1] = f[1, 2:L-1] + k * (f[L, 2:L-1] + f[2, 2:L-1] + f[1, 1:L-2] + f[1, 3:L] - 4 * f[1, 2:L-1])
        @views @. f1[L, 2:L-1] = f[L, 2:L-1] + k * (f[L-1, 2:L-1] + f[1, 2:L-1] + f[L, 1:L-2] + f[L, 3:L] - 4 * f[L, 2:L-1])
        @views @. f1[2:L-1, 1] = f[2:L-1, 1] + k * (f[1:L-2, 1] + f[3:L, 1] + f[2:L-1, L] + f[2:L-1, 2] - 4 * f[2:L-1, 1])
        @views @. f1[2:L-1, L] = f[2:L-1, L] + k * (f[1:L-2, L] + f[3:L, L] + f[2:L-1, L-1] + f[2:L-1, 1] - 4 * f[2:L-1, L])
        
        f1[1, 1] = f[1, 1] + k * (f[L, 1] + f[2, 1] + f[1, L] + f[1, 2] - 4 * f[1, 1])
        f1[L, 1] = f[L, 1] + k * (f[L-1, 1] + f[1, 1] + f[L, L] + f[L, 2] - 4 * f[L, 1])
        f1[1, L] = f[1, L] + k * (f[L, L] + f[2, L] + f[1, L-1] + f[1, 1] - 4 * f[1, L])
        f1[L, L] = f[L, L] + k * (f[L-1, L] + f[1, L] + f[L, L-1] + f[L, 1] - 4 * f[L, L])

        f, f1 = f1, f
    end

    # ALTERAÇÃO 3: Retornar tmax para que possa ser usado fora da função.
    return f, f_inicial, tmax
end

println("Executando para compilação...")
run_simulation_2d()

println("\nExecutando para medição de tempo...")
# ALTERAÇÃO 4: Capturar o valor de tmax retornado pela função.
@time f, f_inicial, tmax = run_simulation_2d()

sum0 = sum(f)
sum1 = sum(f_inicial)

println("\nIntegral em tmax: ", sum0)
println("Integral em t=0: ", sum1)

fig, axes = plt.subplots(1, 2, figsize=(10, 5))

axes[1].imshow(f_inicial, cmap="hot", origin="lower")
axes[1].set_title("Estado Inicial (t=0)")

# Agora esta linha funciona corretamente pois `tmax` existe neste escopo.
axes[2].imshow(f, cmap="hot", origin="lower")
axes[2].set_title("Estado Final (t=$tmax)")

plt.tight_layout()
plt.show()
