# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

import numpy as np
import time
import tracemalloc
import sys

def run_simulation(L1,L2):
    # Parâmetros
    D = 1.
    dt = 0.05
    dx = 1.
    t = 0
    tmax = 100.
    k = D * dt / (dx * dx)

    # Condição inicial
    f = np.zeros((L1, L2), dtype=np.float64)
    a1 = int(L1 / 3)
    b1 = int(2 * L1 / 3)
    a2 = int(L2 / 3)
    b2 = int(2 * L2 / 3)
    f[a1:b1, a2:b2] = 1.
    f1 = np.copy(f)
    f2 = np.copy(f)

    # Loop principal
    while t < tmax:
        t += dt
        # Miolo
        f1[1:L1-1, 1:L2-1] = f[1:L1-1, 1:L2-1] + k * (f[0:L1-2, 1:L2-1] + f[2:L1, 1:L2-1] + f[1:L1-1, 0:L2-2] + f[1:L1-1, 2:L2] - 4 * f[1:L1-1, 1:L2-1])
        # Bordas
        f1[0, 1:L2-1] = f[0, 1:L2-1] + k * (f[L1-1, 1:L2-1] + f[1, 1:L2-1] + f[0, 0:L2-2] + f[0, 2:L2] - 4 * f[0, 1:L2-1])
        f1[L1-1, 1:L2-1] = f[L1-1, 1:L2-1] + k * (f[L1-2, 1:L2-1] + f[0, 1:L2-1] + f[L1-1, 0:L2-2] + f[L1-1, 2:L2] - 4 * f[L1-1, 1:L2-1])
        f1[1:L1-1, 0] = f[1:L1-1, 0] + k * (f[0:L1-2, 0] + f[2:L1, 0] + f[1:L1-1, L2-1] + f[1:L1-1, 1] - 4 * f[1:L1-1, 0])
        f1[1:L1-1, L2-1] = f[1:L1-1, L2-1] + k * (f[0:L1-2, L2-1] + f[2:L1, L2-1] + f[1:L1-1, L2-2] + f[1:L1-1, 0] - 4 * f[1:L1-1, L2-1])
        # Cantos
        f1[0, 0] = f[0, 0] + k * (f[L1-1, 0] + f[1, 0] + f[0, L2-1] + f[0, 1] - 4 * f[0, 0])
        f1[L1-1, 0] = f[L1-1, 0] + k * (f[L1-2, 0] + f[0, 0] + f[L1-1, L2-1] + f[L1-1, 1] - 4 * f[L1-1, 0])
        f1[0, L2-1] = f[0, L2-1] + k * (f[L1-1, L2-1] + f[1, L2-1] + f[0, L2-2] + f[0, 0] - 4 * f[0, L2-1])
        f1[L1-1, L2-1] = f[L1-1, L2-1] + k * (f[L1-2, L2-1] + f[0, L2-1] + f[L1-1, L2-2] + f[L1-1, 0] - 4 * f[L1-1, L2-1])
        
        f, f1 = f1, f
        
    sum0=np.sum(f1)
    sum1=np.sum(f2)
    
    return sum0, sum1

def main():
    if len(sys.argv) != 3:
        print("Uso: python 2d_modified.py <L>")
        sys.exit(1)
    
    L1 = int(sys.argv[1])
    L2 = int(sys.argv[2])
    
    tracemalloc.start()
    start_time = time.perf_counter()
    
    sum0, sum1 = run_simulation(L1,L2)
    
    end_time = time.perf_counter()
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    
    execution_time = end_time - start_time

    print(f"{sum0},{sum1},{execution_time},{peak}")

if __name__ == "__main__":
    main()
