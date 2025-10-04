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
    f = np.zeros((L, L), dtype=np.float64)
    a = int(L / 3)
    b = int(2 * L / 3)
    f[a:b, a:b] = 1.
    f1 = np.copy(f)
    f2 = np.copy(f)

    # Loop principal
    while t < tmax:
        t += dt
        # Miolo
        f1[1:L-1, 1:L-1] = f[1:L-1, 1:L-1] + k * (f[0:L-2, 1:L-1] + f[2:L, 1:L-1] + f[1:L-1, 0:L-2] + f[1:L-1, 2:L] - 4 * f[1:L-1, 1:L-1])
        # Bordas
        f1[0, 1:L-1] = f[0, 1:L-1] + k * (f[L-1, 1:L-1] + f[1, 1:L-1] + f[0, 0:L-2] + f[0, 2:L] - 4 * f[0, 1:L-1])
        f1[L-1, 1:L-1] = f[L-1, 1:L-1] + k * (f[L-2, 1:L-1] + f[0, 1:L-1] + f[L-1, 0:L-2] + f[L-1, 2:L] - 4 * f[L-1, 1:L-1])
        f1[1:L-1, 0] = f[1:L-1, 0] + k * (f[0:L-2, 0] + f[2:L, 0] + f[1:L-1, L-1] + f[1:L-1, 1] - 4 * f[1:L-1, 0])
        f1[1:L-1, L-1] = f[1:L-1, L-1] + k * (f[0:L-2, L-1] + f[2:L, L-1] + f[1:L-1, L-2] + f[1:L-1, 0] - 4 * f[1:L-1, L-1])
        # Cantos
        f1[0, 0] = f[0, 0] + k * (f[L-1, 0] + f[1, 0] + f[0, L-1] + f[0, 1] - 4 * f[0, 0])
        f1[L-1, 0] = f[L-1, 0] + k * (f[L-2, 0] + f[0, 0] + f[L-1, L-1] + f[L-1, 1] - 4 * f[L-1, 0])
        f1[0, L-1] = f[0, L-1] + k * (f[L-1, L-1] + f[1, L-1] + f[0, L-2] + f[0, 0] - 4 * f[0, L-1])
        f1[L-1, L-1] = f[L-1, L-1] + k * (f[L-2, L-1] + f[0, L-1] + f[L-1, L-2] + f[L-1, 0] - 4 * f[L-1, L-1])
        
        f, f1 = f1, f
        
    sum0=np.sum(f1)
    sum1=np.sum(f2)
    
    return sum0, sum1

def main():
    if len(sys.argv) != 2:
        print("Uso: python 2d_modified.py <L>")
        sys.exit(1)
    
    L = int(sys.argv[1])
    
    tracemalloc.start()
    start_time = time.perf_counter()
    
    sum0, sum1 = run_simulation(L)
    
    end_time = time.perf_counter()
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    
    execution_time = end_time - start_time
    
    print("Integral em t=0: %7.4f" % sum0)
    print("Integral em tmax: %7.4f" % sum1)
    
    print(f"{execution_time},{peak}")

if __name__ == "__main__":
    main()
