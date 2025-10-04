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
    
    print("Integral em t=0: %7.4f" % sum0)
    print("Integral em tmax: %7.4f" % sum1)
    
    # A única saída deve ser esta linha pro script de run funcionar
    print(f"{execution_time},{peak}")

if __name__ == "__main__":
    main()
