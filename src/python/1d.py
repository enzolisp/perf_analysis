# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

import numpy as np
import time
import tracemalloc
import sys

def run_simulation(L):
    # Parâmetros
    D = 1.
    dt = 0.05
    dx = 1.
    t = 0
    tmax = 100.
    k = D * dt / (dx * dx)

    # Condição inicial
    f = np.zeros(L, dtype=np.float64)
    a = int(L / 3)
    b = int(2 * L / 3)
    f[a:b] = 1.
    f1 = np.copy(f)
    f2 = np.copy(f)

    # Loop principal da simulação
    while t < tmax:
        t += dt
        f1[1:L-1] = f[1:L-1] + k * (f[0:L-2] + f[2:L] - 2*f[1:L-1])
        f1[L-1] = f[L-1] + k * (f[L-2] + f[0] - 2*f[L-1])
        f1[0] = f[0] + k * (f[1] + f[L-1] - 2*f[0])
        f, f1 = f1, f
        
    sum0=sum(f1)
    sum1=sum(f2)
    
    return sum0, sum1

def main():
    if len(sys.argv) != 2:
        print("Uso: python 1d_modified.py <L>")
        sys.exit(1)
    
    L = int(sys.argv[1])
    
    tracemalloc.start()
    start_time = time.perf_counter()
    
    sum0, sum1 = run_simulation(L)
    
    end_time = time.perf_counter()
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    
    execution_time = end_time - start_time
        
    print(f"{sum0},{sum1},{execution_time},{peak}")

if __name__ == "__main__":
    main()
