import numpy as np
import matplotlib.pyplot as plt

# 1. Construção da Malha Espacial
L = 1.0  # Comprimento da barra
N = 51   # Número de pontos na malha
h = L / (N - 1) # Espaçamento da malha
x = np.linspace(0, L, N)

# 2. Parâmetros da Simulação Temporal
alpha = 0.01  # Difusividade térmica do material
t_final = 5.0 # Tempo total da simulação
dt = 0.0004     # Passo de tempo (dt)

# Critério de estabilidade: alpha * dt / h^2 <= 0.5
# Se o valor for maior que 0.5, a simulação se torna instável.
print(f"Critério de estabilidade: {alpha * dt / h**2:.4f}")

# 3. Condições Iniciais e de Contorno
u = np.sin(np.pi * x) # Condição inicial u(x,0)
u[0] = 0.0  # Condição de contorno em x=0
u[-1] = 0.0 # Condição de contorno em x=L

# Armazenar cópias para plotagem posterior
u_inicial = u.copy()
u_solucoes = [u.copy()]
tempos_plot = [0.0]

# 4. Loop de Evolução no Tempo (O núcleo do método)
t = 0
while t < t_final:
    # Cria uma cópia do vetor da solução do passo de tempo anterior
    u_anterior = u.copy()
    
    # Itera sobre os pontos internos da malha para calcular o novo perfil de temperatura
    for i in range(1, N - 1):
        # Discretização da equação do calor (Método FTCS)
        u[i] = u_anterior[i] + (alpha * dt / h**2) * (u_anterior[i+1] - 2*u_anterior[i] + u_anterior[i-1])
        
    t += dt # Avança no tempo

    # Armazena a solução em intervalos de tempo específicos para visualização
    if len(u_solucoes) < 6 and t >= len(u_solucoes) * (t_final/5):
        u_solucoes.append(u.copy())
        tempos_plot.append(t)

# 5. Visualização dos Resultados
plt.figure(figsize=(10, 6))
for i, sol in enumerate(u_solucoes):
    plt.plot(x, sol, label=f't = {tempos_plot[i]:.2f} s')

plt.title('Evolução da Temperatura (Equação do Calor)')
plt.xlabel('Posição na barra (x)')
plt.ylabel('Temperatura (u)')
plt.legend()
plt.grid(True)
plt.savefig('./a.png')