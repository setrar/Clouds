# Azure-CLI

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

Would you like help with a specific use case or further customization of the configurations?
