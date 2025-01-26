# Locust

## Local Testing

- [ ] Run the `NumericalIntegration` App on your computer

```
git clone https://github.com/setrar/CloudsNumericalIntegration && cd CloudsNumericalIntegration
```

- [ ] Run the app (note: install the required libraries first, not shown here)


```
python app.py
```
> Returns
```powershell
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://192.168.1.103:8080
Press CTRL+C to quit
```

- [ ] Run locust locally

```
HOST=http://192.168.1.103:8080
locust -f locustfile.py --host=${HOST} \
         --headless --users 10 --spawn-rate 2 --run-time 3m  \
         --csv=logs/locust_log-local-u10r2t3.csv
```



```
HOST=https://webappclouds2025nibr.azurewebsites.net
locust -f locustfile.py --host=${HOST} \
         --headless --users 10 --spawn-rate 2 --run-time 3m  \
         --csv=logs/locust_log-webapp-u10r2t3.csv
```

## Remote Testing

- [ ] Run the `NumericalIntegration` WebApp on Azure

```
HOST=https://webappclouds2025nibr.azurewebsites.net
locust -f locustfile.py --host=${HOST} \
         --headless --users 10 --spawn-rate 2 --run-time 3m  \
         --csv=logs/locust_log-webapp-u10r2t3.csv
```

- [ ] Run the `NumericalIntegration` Function on Azure

:x: Note: Only one user was used for load testing, the function couldn't keep up

```
HOST=https://clouds25lab2eurbrnifnc.azurewebsites.net/api
locust -f locustfile.py --host=${HOST} \
         --headless --users 1 --spawn-rate 2 --run-time 3m  \
         --csv=logs/locust_log-function-u10r2t3.csv
```
