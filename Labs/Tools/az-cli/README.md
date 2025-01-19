# Azure-CLI

## Connect Using Azure-CLI

To use **OpenTofu** with the **Azure CLI**, you can follow these steps to integrate both tools effectively for provisioning and managing Azure resources.

---

### Prerequisites
1. **Install OpenTofu:**
   Install OpenTofu using Homebrew:
   ```bash
   brew install opentofu
   ```

2. **Install Azure CLI:**
   Ensure the Azure CLI is installed:
   ```bash
   brew install azure-cli
   ```
   > Returns
   ```powershell
   ==> Downloading https://formulae.brew.sh/api/formula.jws.json
   ############################################################################################################ 100.0%
   ==> Downloading https://formulae.brew.sh/api/cask.jws.json
   ############################################################################################################ 100.0%
   ==> Downloading https://ghcr.io/v2/homebrew/core/azure-cli/manifests/2.67.0_1
   ############################################################################################################ 100.0%
   ==> Fetching dependencies for azure-cli: python@3.12
   ==> Downloading https://ghcr.io/v2/homebrew/core/python/3.12/manifests/3.12.8
   Already downloaded: /Users/valiha/Library/Caches/Homebrew/downloads/c8e281b0d5b5a38ad458c87fd3064a69ab50809945e585657d09bcd1c4f0134a--python@3.12-3.12.8.bottle_manifest.json
   ==> Fetching python@3.12
   ==> Downloading https://ghcr.io/v2/homebrew/core/python/3.12/blobs/sha256:20eb89eda4a412238d217124182c11c9410361900
   ############################################################################################################ 100.0%
   ==> Fetching azure-cli
   ==> Downloading https://ghcr.io/v2/homebrew/core/azure-cli/blobs/sha256:625075ddb021f2393e7cf776ec42b449b194b562ead
   ############################################################################################################ 100.0%
   ==> Installing dependencies for azure-cli: python@3.12
   ==> Installing azure-cli dependency: python@3.12
   ==> Downloading https://ghcr.io/v2/homebrew/core/python/3.12/manifests/3.12.8
   Already downloaded: /Users/valiha/Library/Caches/Homebrew/downloads/c8e281b0d5b5a38ad458c87fd3064a69ab50809945e585657d09bcd1c4f0134a--python@3.12-3.12.8.bottle_manifest.json
   ==> Pouring python@3.12--3.12.8.arm64_sequoia.bottle.tar.gz
   ==> /opt/homebrew/Cellar/python@3.12/3.12.8/bin/python3.12 -Im ensurepip
   ==> /opt/homebrew/Cellar/python@3.12/3.12.8/bin/python3.12 -Im pip install -v --no-index --upgrade --isolated --tar
   🍺  /opt/homebrew/Cellar/python@3.12/3.12.8: 3,267 files, 65.5MB
   ==> Installing azure-cli
   ==> Pouring azure-cli--2.67.0_1.arm64_sequoia.bottle.tar.gz
   ==> Caveats
   zsh completions have been installed to:
     /opt/homebrew/share/zsh/site-functions
   ==> Summary
   🍺  /opt/homebrew/Cellar/azure-cli/2.67.0_1: 24,350 files, 578.4MB
   ==> Running `brew cleanup azure-cli`...
   Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
   Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
   ==> Caveats
   ==> azure-cli
   zsh completions have been installed to:
   /opt/homebrew/share/zsh/site-functions
   ```
   
   Verify installation:
   ```bash
   az --version
   ```
   > Returns
   ```powershell
   azure-cli                         2.67.0

   core                              2.67.0
   telemetry                          1.1.0
   
   Dependencies:
   msal                              1.31.0
   azure-mgmt-resource               23.1.1
   
   Python location '/opt/homebrew/Cellar/azure-cli/2.67.0_1/libexec/bin/python'
   Extensions directory '/Users/valiha/.azure/cliextensions'
   
   Python (Darwin) 3.12.8 (main, Dec  3 2024, 18:42:41) [Clang 16.0.0 (clang-1600.0.26.4)]
   
   Legal docs and information: aka.ms/AzureCliLegal
   
   
   Your CLI is up-to-date.
   ```

3. **Authenticate Azure CLI:**
   Log in to Azure using the Azure CLI:
   ```bash
   az login
   ```
   > This will open a browser window for authentication. Once logged in, your credentials will be stored locally for use by OpenTofu.

   ```bash
   az login
   ```
   > Returns
   ```powershell
   A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.
   
   Retrieving tenants and subscriptions for the selection...
   
   [Tenant and subscription selection]
   
   No     Subscription name    Subscription ID                       Tenant
   -----  -------------------  ------------------------------------  -----------------
   [1] *  Azure for Students   effa0000-28e0-0000-9e9d-323FFFFF4eb  Default Directory
   
   The default is marked with an *; the default tenant is 'Default Directory' and subscription is 'Azure for Students' (effa0000-28e0-0000-9e9d-323FFFFF4eb).
   
   Select a subscription and tenant (Type a number or Enter for no changes): 
   
   Tenant: Default Directory
   Subscription: Azure for Students (effa0000-0000-4ec6-9e9d-323FFFFF4eb)
   
   [Announcements]
   With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236
   
   If you encounter any problem, please open an issue at https://aka.ms/azclibug
   
   [Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.
   ```


---

### Step-by-Step Guide to Use OpenTofu with Azure CLI

#### 1. **Configure OpenTofu for Azure**
OpenTofu uses the **Azure provider** to interact with Azure services. Add the Azure provider configuration to your `main.tf` file:

```hcl
provider "azurerm" {
  features {}
}
```

#### 2. **Create an OpenTofu Configuration File**
Here’s an example configuration file to deploy an Azure resource group and a virtual machine:

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
```

---

#### 3. **Run OpenTofu Commands**
1. **Initialize the Configuration:**
   ```bash
   tofu init
   ```
   This downloads the required Azure provider plugins.

2. **Preview the Changes:**
   ```bash
   tofu plan
   ```
   This shows the resources that will be created.

3. **Apply the Configuration:**
   ```bash
   tofu apply
   ```
   Type `yes` when prompted to create the resources.

4. **Verify the Deployment:**
   Use the Azure CLI to check the resources created:
   ```bash
   az group list --output table
   az vm list --output table
   ```

---

### 4. **Managing Resources**
- **Update Resources:**
  Modify the `main.tf` file and run:
  ```bash
  tofu plan
  tofu apply
  ```

- **Destroy Resources:**
  To remove all resources managed by OpenTofu:
  ```bash
  tofu destroy
  ```

---

### 5. **Best Practices**
- **Use Azure CLI for Authentication:**
  By default, the Azure provider in OpenTofu uses the credentials from `az login`.
  
- **Store Secrets Securely:**
  Use Azure Key Vault or environment variables to manage sensitive data like passwords or keys.

- **Integrate Monitoring:**
  Combine Azure Monitor with OpenTofu deployments to keep track of resource performance and logs.

---

## **basic Azure CLI commands**

Here’s a list of **basic Azure CLI commands** grouped by common use cases. These commands will help you navigate and manage Azure resources efficiently.

---

### **General Commands**
- **Login to Azure:**
  ```bash
  az login
  ```
- **Check Your Azure CLI Version:**
  ```bash
  az --version
  ```
- **List All Available Commands:**
  ```bash
  az --help
  ```

---

### **Resource Group Management**
- **List Resource Groups:**
  ```bash
  az group list --output table
  ```
- **Create a Resource Group:**
  ```bash
  az group create --name <resource-group-name> --location <location>
  ```
  Example:
  ```bash
  az group create --name myResourceGroup --location "East US"
  ```
- **Delete a Resource Group:**
  ```bash
  az group delete --name <resource-group-name> --yes --no-wait
  ```

---

### **Virtual Machines (VMs)**
- **List All VMs:**
  ```bash
  az vm list --output table
  ```
- **Create a VM:**
  ```bash
  az vm create \
    --resource-group <resource-group-name> \
    --name <vm-name> \
    --image UbuntuLTS \
    --admin-username <username> \
    --admin-password <password>
  ```
  Example:
  ```bash
  az vm create \
    --resource-group myResourceGroup \
    --name myVM \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password P@ssw0rd123!
  ```
- **Start a VM:**
  ```bash
  az vm start --resource-group <resource-group-name> --name <vm-name>
  ```
- **Stop a VM:**
  ```bash
  az vm stop --resource-group <resource-group-name> --name <vm-name>
  ```
- **Delete a VM:**
  ```bash
  az vm delete --resource-group <resource-group-name> --name <vm-name> --yes
  ```

---

### **Storage Accounts**
- **List Storage Accounts:**
  ```bash
  az storage account list --output table
  ```
- **Create a Storage Account:**
  ```bash
  az storage account create \
    --name <storage-account-name> \
    --resource-group <resource-group-name> \
    --location <location> \
    --sku Standard_LRS
  ```
- **Delete a Storage Account:**
  ```bash
  az storage account delete --name <storage-account-name> --resource-group <resource-group-name>
  ```

---

### **Networking**
- **List Virtual Networks:**
  ```bash
  az network vnet list --output table
  ```
- **Create a Virtual Network:**
  ```bash
  az network vnet create \
    --resource-group <resource-group-name> \
    --name <vnet-name> \
    --address-prefix 10.0.0.0/16
  ```
- **Create a Subnet:**
  ```bash
  az network vnet subnet create \
    --resource-group <resource-group-name> \
    --vnet-name <vnet-name> \
    --name <subnet-name> \
    --address-prefix 10.0.0.0/24
  ```

---

### **Azure Kubernetes Service (AKS)**
- **List AKS Clusters:**
  ```bash
  az aks list --output table
  ```
- **Create an AKS Cluster:**
  ```bash
  az aks create \
    --resource-group <resource-group-name> \
    --name <aks-cluster-name> \
    --node-count 3 \
    --generate-ssh-keys
  ```
- **Get AKS Cluster Credentials:**
  ```bash
  az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
  ```
- **Delete an AKS Cluster:**
  ```bash
  az aks delete --resource-group <resource-group-name> --name <aks-cluster-name> --yes
  ```

---

### **Monitoring and Logs**
- **View Azure Activity Logs:**
  ```bash
  az monitor activity-log list --output table
  ```
- **View Metrics for a Resource:**
  ```bash
  az monitor metrics list --resource <resource-id> --output table
  ```
- **Set up Azure Monitor Alerts:**
  ```bash
  az monitor alert create \
    --name <alert-name> \
    --resource-group <resource-group-name> \
    --scopes <resource-id> \
    --condition "avg Percentage CPU > 80"
  ```

---

### **Miscellaneous**
- **Get Your Azure Account Information:**
  ```bash
  az account show
  ```
- **List Available Locations:**
  ```bash
  az account list-locations --output table
  ```
- **Check Resource Usage:**
  ```bash
  az vm list-usage --location <location> --output table
  ```

---

## **func**


### **Step 1: Install Azure Functions Core Tools**
The Azure Functions Core Tools allow you to create, test, and publish Azure Functions from your local environment.

#### macOS Installation with Homebrew:
If you’re on macOS, the easiest way to install the tools is with Homebrew:
```bash
brew tap azure/functions
brew install azure-functions-core-tools@4
```
:x: requires XTool to be updated (too long)

#### macOS Installation with Homebrew:
If you’re on macOS, the easiest way to install the tools is with node:

```
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```
> Results
```powershell

added 35 packages in 14m

5 packages are looking for funding
  run `npm fund` for details
npm notice
npm notice New major version of npm available! 10.9.2 -> 11.0.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.0.0
npm notice To update run: npm install -g npm@11.0.0
npm notice
```

#### Verify the Installation:
After installation, confirm that the `func` command is available:
```bash
func --version
```
> 4.0.6821

---

### **Step 2: Add `func` to Your `PATH` (If Necessary)**
If `func` is installed but still not recognized, ensure its binary is in your `PATH`. For example:
1. Locate the installation directory:
   ```bash
   which func
   ```
2. Add the directory to your shell configuration (e.g., `.zshrc` or `.bashrc`):
   ```bash
   export PATH=$PATH:/path/to/azure-functions-core-tools
   ```
3. Reload the shell configuration:
   ```bash
   source ~/.zshrc
   ```

---

### **Step 3: Publish Your Azure Function**
Once the `func` tool is installed and accessible, you can publish your Azure Function to the specified Azure Function App:
```bash
func azure functionapp publish <your-function-app-name>
```

---

### **Troubleshooting Tips**
- **Azure CLI Installation:** Ensure that the Azure CLI is installed and authenticated:
  ```bash
  az login
  ```
- **Function App Name:** Replace `<your-function-app-name>` with the name of your Azure Function App.

## **azurite**

```
npm install -g azurite
```
> Returns
```powershell
npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
npm warn deprecated uuid@3.4.0: Please upgrade  to version 7 or higher.  Older versions may use Math.random() in certain circumstances, which is known to be problematic.  See https://v8.dev/blog/math-random for details.
⠙
```
