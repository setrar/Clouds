#  **microservice with OpenTofu**

Here’s how you can set up a **microservice with OpenTofu** using Python and deploy it on Azure App Service.

---

### **Step 1: Write the Python Microservice**
We’ll use **Flask**, a lightweight framework for building web services.

#### **Create the Microservice** in the `src` directory
Create a file named `src/app.py`:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, World! This is a Python microservice running on Azure!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
```

---

### **Step 2: Package the Application**
1. Create a **src/requirements.txt** file to list dependencies:
   ```text
   flask
   gunicorn
   ```

2. Zip the application files for deployment:
   ```bash
   zip -r app.zip src/
   ```

---

### **Step 3: OpenTofu Configuration**
Define the Azure resources needed for the microservice deployment using OpenTofu.

#### **`main.tf`**
```hcl
# Define Resource Group
resource "azurerm_resource_group" "lab2_rg" {
  name     = "lab2"
  location = "East US"
}

# Define App Service Plan
resource "azurerm_app_service_plan" "lab2_plan" {
  name                = "lab2-plan"
  location            = azurerm_resource_group.lab2_rg.location
  resource_group_name = azurerm_resource_group.lab2_rg.name
  sku {
    tier = "Basic" # Adjust as needed (e.g., B1, F1)
    size = "B1"
  }
}

# Define App Service
resource "azurerm_linux_web_app" "lab2_app" {
  name                = "lab2-python-app"
  location            = azurerm_resource_group.lab2_rg.location
  resource_group_name = azurerm_resource_group.lab2_rg.name
  service_plan_id     = azurerm_app_service_plan.lab2_plan.id

  site_config {
    linux_fx_version = "PYTHON|3.9" # Specify Python version
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1" # Enable deployment from package
  }
}
```

---

### **Step 4: Deploy the Application**
1. Initialize OpenTofu:
   ```bash
   tofu init
   ```
   > Returns
   ```powershell
       
    Initializing the backend...
    
    Initializing provider plugins...
    - Reusing previous version of hashicorp/azurerm from the dependency lock file
    - Using previously-installed hashicorp/azurerm v4.15.0
    
    OpenTofu has been successfully initialized!
    
    You may now begin working with OpenTofu. Try running "tofu plan" to see
    any changes that are required for your infrastructure. All OpenTofu commands
    should now work.
    
    If you ever set or change modules or backend configuration for OpenTofu,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

2. Validate the configuration:
   ```bash
   tofu validate
   ```
   > Success! The configuration is valid.

3. Plan the deployment:
   ```bash
   tofu plan
   ```
   > Returns
    ```powershell
    azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-28FF-4eFF-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
    azurerm_virtual_network.lab1: Refreshing state... [id=/subscriptions/effa7872-28FF-4eFF-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
    
    OpenTofu used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      + create
    
    OpenTofu will perform the following actions:
    
      # azurerm_linux_web_app.lab2_app will be created
      + resource "azurerm_linux_web_app" "lab2_app" {
          + app_settings                                   = {
              + "FUNCTIONS_WORKER_RUNTIME" = "python"
              + "WEBSITE_RUN_FROM_PACKAGE" = "1"
            }
          + client_affinity_enabled                        = false
          + client_certificate_enabled                     = false
          + client_certificate_mode                        = "Required"
          + custom_domain_verification_id                  = (sensitive value)
          + default_hostname                               = (known after apply)
          + enabled                                        = true
          + ftp_publish_basic_authentication_enabled       = true
          + hosting_environment_id                         = (known after apply)
          + https_only                                     = false
          + id                                             = (known after apply)
          + key_vault_reference_identity_id                = (known after apply)
          + kind                                           = (known after apply)
          + location                                       = "eastus"
          + name                                           = "lab2-python-app"
          + outbound_ip_address_list                       = (known after apply)
          + outbound_ip_addresses                          = (known after apply)
          + possible_outbound_ip_address_list              = (known after apply)
          + possible_outbound_ip_addresses                 = (known after apply)
          + public_network_access_enabled                  = true
          + resource_group_name                            = "lab2"
          + service_plan_id                                = (known after apply)
          + site_credential                                = (sensitive value)
          + webdeploy_publish_basic_authentication_enabled = true
          + zip_deploy_file                                = (known after apply)
    
          + site_config {
              + always_on                               = true
              + container_registry_use_managed_identity = false
              + default_documents                       = (known after apply)
              + detailed_error_logging_enabled          = (known after apply)
              + ftps_state                              = "Disabled"
              + http2_enabled                           = false
              + ip_restriction_default_action           = "Allow"
              + linux_fx_version                        = (known after apply)
              + load_balancing_mode                     = "LeastRequests"
              + local_mysql_enabled                     = false
              + managed_pipeline_mode                   = "Integrated"
              + minimum_tls_version                     = "1.2"
              + remote_debugging_enabled                = false
              + remote_debugging_version                = (known after apply)
              + scm_ip_restriction_default_action       = "Allow"
              + scm_minimum_tls_version                 = "1.2"
              + scm_type                                = (known after apply)
              + scm_use_main_ip_restriction             = false
              + use_32_bit_worker                       = true
              + vnet_route_all_enabled                  = false
              + websockets_enabled                      = false
              + worker_count                            = (known after apply)
    
              + application_stack {
                  + python_version = "3.9"
                }
            }
        }
    
      # azurerm_resource_group.lab2_rg will be created
      + resource "azurerm_resource_group" "lab2_rg" {
          + id       = (known after apply)
          + location = "eastus"
          + name     = "lab2"
        }
    
      # azurerm_service_plan.lab2_plan will be created
      + resource "azurerm_service_plan" "lab2_plan" {
          + id                           = (known after apply)
          + kind                         = (known after apply)
          + location                     = "eastus"
          + maximum_elastic_worker_count = (known after apply)
          + name                         = "lab2-plan"
          + os_type                      = "Linux"
          + per_site_scaling_enabled     = false
          + reserved                     = (known after apply)
          + resource_group_name          = "lab2"
          + sku_name                     = "B1"
          + worker_count                 = (known after apply)
        }
    
    Plan: 3 to add, 0 to change, 0 to destroy.
    
    ──────────────────────────────────────────────────────────────────────────────────────────────────────
    
    Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly
    these actions if you run "tofu apply" now.
    ```

4. Apply the deployment:
   ```bash
   tofu apply
   ```

---

### **Step 5: Upload the Application Package**
After deploying the infrastructure, upload your `app.zip` file to Azure using the Azure CLI:

```bash
az webapp deployment source config-zip --resource-group lab2 --name lab2-python-app --src app.zip
```

---

### **Step 6: Access the Microservice**
Retrieve the public URL of the deployed app:

```bash
az webapp show --name lab2-python-app --resource-group lab2 --query "defaultHostName" -o tsv
```

Visit the URL in your browser to see the Python microservice in action.

---

### **Optional Enhancements**
1. **Custom Domain**: Add a custom domain to your App Service.
2. **Autoscaling**: Configure scaling rules for the App Service Plan.
3. **Monitoring**: Enable Azure Application Insights for telemetry and logs.
4. **CI/CD Pipeline**: Use GitHub Actions or Azure DevOps for automated deployments.

This configuration is simple, scalable, and can be extended to include databases or integrate with other Azure services.
