# Clouds: Numerical Integration 

We saw how to do numerical integration in the class. 

You first task is to create a program that can do numerical integration with the function abs(sin(x)). 

Given an interval lower and upper, your code should break up the interval into $N$ subintervals, compute the area of the rectangle at each subinterval and add them all up. 

For example, if you give as input 0 and 3.14159 (which is approximately $\pi$), you should get $1.99…$ which is close to $2$ ($\int \sin 𝑥 = − \cos 𝑥$, ignoring aspects of continuity, which when evaluated in the range gives you $- \cos \pi + \cos 0 = 2$). 

Your program should loop and repeatedly compute numerical integral for $N = 10, 100, 100, 1000, 10k, 100k, 1M$. You will end up getting 7 values, one for each value of $N$. You will see that as $N$ increases, result converges to 2. 

This will also make the integral computation time consuming which will be useful for load testing later.

```
resource "azurerm_monitor_autoscale_setting" "webapp_autoscale" {
  name                = "webapp-autoscale"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  target_resource_id  = azurerm_service_plan.lab2.id # App Service Plan ID

  profile {
    name = "autoscale-cpu-rule"

    capacity {
      minimum = 1
      maximum = 3
      default = 1
    }

    rule {
      metric_trigger {
        metric_name        = "CPUPercentage"
        metric_resource_id = azurerm_linux_web_app.lab2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 50 # Scale out when avg CPU usage > 50%
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CPUPercentage"
        metric_resource_id = azurerm_linux_web_app.lab2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 50 # Scale in when avg CPU usage < 50%
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
```
