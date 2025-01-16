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

3. Plan the deployment:
   ```bash
   tofu plan
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
