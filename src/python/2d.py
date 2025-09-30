# FTCS aplicado na equacao da difusao 2D. Linguagem: PYTHON

import numpy as np
import matplotlib.pyplot as plt
import time

# Mede o tempo de execução total
inicio = time.perf_counter()

def init():
    """Define os parâmetros da simulação."""
    L = 200  # Tamanho do grid (L x L)
    D = 1.
    dt = 0.05
    dx = 1.
    t = 0
    tmax = 100.
    k = D * dt / (dx * dx)
    return L, k, dt, t, tmax

# Inicializa os parâmetros
L, k, dt, t, tmax = init()

# Cria as matrizes 2D para o estado atual e o próximo
f = np.zeros((L, L))

# Define a condição inicial como um quadrado de valor 1.0 no centro
a = int(L / 3)
b = int(2 * L / 3)
f[a:b, a:b] = 1.

# Guarda o estado inicial para o plot e cria a matriz para o próximo estado
f_inicial = np.copy(f)
f1 = np.copy(f)

# Loop principal da simulação
while t < tmax:
    t += dt

    # 1. Calcula o próximo estado (f1) para os pontos internos da matriz
    # Usa a discretização da equação do calor em 2D: d_f/d_t = D * (d²f/dx² + d²f/dy²)
    f1[1:L-1, 1:L-1] = f[1:L-1, 1:L-1] + k * (f[0:L-2, 1:L-1] + f[2:L, 1:L-1] + f[1:L-1, 0:L-2] + f[1:L-1, 2:L] - 4 * f[1:L-1, 1:L-1])
    
    # 2. Calcula as condições de contorno periódicas (bordas "enxergam" o lado oposto)
    # Bordas (excluindo os cantos)
    f1[0, 1:L-1] = f[0, 1:L-1] + k * (f[L-1, 1:L-1] + f[1, 1:L-1] + f[0, 0:L-2] + f[0, 2:L] - 4 * f[0, 1:L-1]) # Borda superior
    f1[L-1, 1:L-1] = f[L-1, 1:L-1] + k * (f[L-2, 1:L-1] + f[0, 1:L-1] + f[L-1, 0:L-2] + f[L-1, 2:L] - 4 * f[L-1, 1:L-1]) # Borda inferior
    f1[1:L-1, 0] = f[1:L-1, 0] + k * (f[0:L-2, 0] + f[2:L, 0] + f[1:L-1, L-1] + f[1:L-1, 1] - 4 * f[1:L-1, 0]) # Borda esquerda
    f1[1:L-1, L-1] = f[1:L-1, L-1] + k * (f[0:L-2, L-1] + f[2:L, L-1] + f[1:L-1, L-2] + f[1:L-1, 0] - 4 * f[1:L-1, L-1]) # Borda direita
    
    # Cantos
    f1[0, 0] = f[0, 0] + k * (f[L-1, 0] + f[1, 0] + f[0, L-1] + f[0, 1] - 4 * f[0, 0]) # Canto superior esquerdo
    f1[L-1, 0] = f[L-1, 0] + k * (f[L-2, 0] + f[0, 0] + f[L-1, L-1] + f[L-1, 1] - 4 * f[L-1, 0]) # Canto inferior esquerdo
    f1[0, L-1] = f[0, L-1] + k * (f[L-1, L-1] + f[1, L-1] + f[0, L-2] + f[0, 0] - 4 * f[0, L-1]) # Canto superior direito
    f1[L-1, L-1] = f[L-1, L-1] + k * (f[L-2, L-1] + f[0, L-1] + f[L-1, L-2] + f[L-1, 0] - 4 * f[L-1, L-1]) # Canto inferior direito

    # Troca os arrays para a próxima iteração, uma operação muito eficiente que evita cópia de dados
    f, f1 = f1, f

# Calcula a "integral" (soma dos valores) para verificar a conservação
sum0 = np.sum(f)           # 'f' agora contém o resultado final
sum1 = np.sum(f_inicial)

fim = time.perf_counter()

# Calcula e exibe o tempo decorrido
tempo_execucao = fim - inicio
print(f"O código levou {tempo_execucao:.6f} segundos para ser executado.")

print(f"Integral em tmax: {sum0:7.4f}")
print(f"Integral em t=0:  {sum1:7.4f}")

# Visualização dos resultados
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

ax1.imshow(f_inicial, cmap='hot', interpolation='nearest')
ax1.set_title("Estado Inicial (t=0)")
ax1.set_xlabel("x")
ax1.set_ylabel("y")


ax2.imshow(f, cmap='hot', interpolation='nearest')
ax2.set_title(f"Estado Final (t={tmax})")
ax2.set_xlabel("x")
ax2.set_ylabel("y")


plt.tight_layout()
plt.show()
