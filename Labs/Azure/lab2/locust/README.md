

```
HOST=https://webappclouds2025nibr.azurewebsites.net
locust -f locustfile.py --host=${HOST} \
         --headless --users 10 --spawn-rate 2 --run-time 3m  \
         --csv=logs/locust_log-u10r2t2.csv
```
