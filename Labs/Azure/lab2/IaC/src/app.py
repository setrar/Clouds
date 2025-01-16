from flask import Flask
from flask import Response
import math
import time

app = Flask(__name__)

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
        x_mid = lower + (i + 0.5) * dx
        total_area += abs(math.sin(x_mid)) * dx
    return total_area

@app.route('/numericalintegralservice/<path:lower>/<path:upper>', methods=['GET'])
def integrate_any(lower, upper):
    try:
        # Convert to float
        lower = float(lower)
        upper = float(upper)

        if lower >= upper:
            return f"Error: Lower bound must be less than upper bound.", 400

        # Perform numerical integration
        subintervals = [10, 100, 1000, 10000, 100000, 1000000, 10000000]  # 7 values for N
        results = []

        for N in subintervals:
            start_time = time.time()
            result = numerical_integration_abs_sin(lower, upper, N)
            elapsed_time = time.time() - start_time
            results.append(f"N = {N:7d}, Result = {result:.10f}, Time = {elapsed_time:.6f} seconds")

        # Return plain text response
       #  return "Numerical integration of |sin(x)| from {} to {}:\n".format(lower, upper) + "\n".join(results)
        # Return plain text response with each result on a new line
        response = "Numerical integration of |sin(x)| from {} to {}:\n\n".format(lower, upper)
        response += "\n".join(results)
        return Response(response, mimetype="text/plain")

    except ValueError as e:
        return f"Error: Bounds must be valid numbers: {str(e)}", 400

@app.route('/')
def home():
    return ("Welcome to the Numerical Integration Microservice!<br>"
            "Use /numericalintegralservice/<lower>/<upper> with the bounds of the integration as part of the URL.")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
