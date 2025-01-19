# Clouds: Numerical Integration 

We saw how to do numerical integration in the class. 

You first task is to create a program that can do numerical integration with the function abs(sin(x)). 

Given an interval lower and upper, your code should break up the interval into $N$ subintervals, compute the area of the rectangle at each subinterval and add them all up. 

For example, if you give as input 0 and 3.14159 (which is approximately $\pi$), you should get $1.99…$ which is close to $2$ ($\int \sin 𝑥 = − \cos 𝑥$, ignoring aspects of continuity, which when evaluated in the range gives you $- \cos \pi + \cos 0 = 2$). 

Your program should loop and repeatedly compute numerical integral for $N = 10, 100, 100, 1000, 10k, 100k, 1M$. You will end up getting 7 values, one for each value of $N$. You will see that as $N$ increases, result converges to 2. 

This will also make the integral computation time consuming which will be useful for load testing later.
