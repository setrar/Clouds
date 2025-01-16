import math
import time

def numerical_integration_abs_sin(lower, upper, N):
    """
    Perform numerical integration of |sin(x)| using the rectangle method.

    Parameters:
        lower (float): Lower bound of the interval.
        upper (float): Upper bound of the interval.
        N (int): Number of subintervals.

    Returns:
        float: Numerical approximation of the integral.
    """
    dx = (upper - lower) / N
    total_area = 0

    for i in range(N):
        # Calculate the midpoint of each subinterval
        x_mid = lower + (i + 0.5) * dx
        total_area += abs(math.sin(x_mid)) * dx

    return total_area

def main():
    lower = 0
    upper = math.pi
    subintervals = [10, 100, 1000, 10000, 100000, 1000000, 10000000]

    print(f"Numerical integration of |sin(x)| from {lower} to {upper}:")
    for N in subintervals:
        start_time = time.time()
        result = numerical_integration_abs_sin(lower, upper, N)
        elapsed_time = time.time() - start_time
        print(f"N = {N:7d}, Result = {result:.10f}, Time = {elapsed_time:.6f} seconds")

if __name__ == "__main__":
    main()

