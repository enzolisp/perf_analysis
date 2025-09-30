# FTCS aplicado na equacao da difusao. Linguagem: PYTHON

import numpy as np
import matplotlib.pyplot as plt
import time

inicio = time.perf_counter()

def init():
    L = 500  # Aumentado para uma melhor comparação de desempenho
    D = 1.
    dt = 0.05
    dx = 1.
    t = 0
    tmax = 100.
    k = D * dt / (dx * dx)
    return L, k, dt, t, tmax

L, k, dt, t, tmax = init()

x = np.arange(0, L, 1)
f = np.zeros(x.shape)  # Array para o estado atual

a = int(L / 3)
b = int(2 * L / 3)
f[a:b] = 1.
f_inicial = np.copy(f) # Guarda o estado inicial para o plot
f1 = np.copy(f)       # Array para o próximo estado

while t < tmax:
    t += dt
    # Calcula o próximo estado (f1) com base no estado atual (f)
    f1[1:L-1] = f[1:L-1] + k * (f[0:L-2] + f[2:L] - 2*f[1:L-1])
    f1[L-1] = f[L-1] + k * (f[L-2] + f[0] - 2*f[L-1])
    f1[0] = f[0] + k * (f[1] + f[L-1] - 2*f[0])

    # Troca os arrays para a próxima iteração, sem copiar dados
    f, f1 = f1, f

sum0 = sum(f)           # 'f' agora contém o resultado final
sum1 = sum(f_inicial)

fim = time.perf_counter()

# Calcula e exibe o tempo decorrido
tempo_execucao = fim - inicio
print(f"O código levou {tempo_execucao:.6f} segundos para ser executado.")

print(f"Integral em tmax: {sum0:7.4f}")
print(f"Integral em t=0: {sum1:7.4f}")


plt.plot(x, f, x, f_inicial)
plt.show()
