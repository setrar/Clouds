#  **OpenTofu** with the **Azure CLI**

## Use **OpenTofu** with the **Azure CLI**

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
   Verify installation:
   ```bash
   az --version
   ```

3. **Authenticate Azure CLI:**
   Log in to Azure using the Azure CLI:
   ```bash
   az login
   ```
   This will open a browser window for authentication. Once logged in, your credentials will be stored locally for use by OpenTofu.

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
Here’s a `lab1` configuration file to deploy an Azure resource group and a virtual machine:

```hcl
# Resource Group
resource "azurerm_resource_group" "lab1" {
  name     = "lab1-resources"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "lab1_vnet" {
  name                = "lab1-vnet"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "lab1_subnet" {
  name                 = "lab1-subnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.lab1_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "lab1_public_ip" {
  name                = "lab1-public-ip"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "lab1_nic" {
  name                = "lab1-nic"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab1_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab1_public_ip.id
  }
}

# Virtual Machine

resource "azurerm_linux_virtual_machine" "lab1_vm" {
  name                = "lab1-vm"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  size                = "Standard_B1ls"  # Free tier or low-cost instance
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/robert@eurecom.fr.pub") # Path to your SSH public key
  }

  network_interface_ids = [
    azurerm_network_interface.lab1_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Cloud-Init Script
  custom_data = filebase64("cloud-init.yaml")  # Automatically Base64-encodes the file

}

# Security Group
resource "azurerm_network_security_group" "lab1_nsg" {
  name                = "lab1-nsg"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "lab1_subnet_nsg" {
  subnet_id                 = azurerm_subnet.lab1_subnet.id
  network_security_group_id = azurerm_network_security_group.lab1_nsg.id
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

## Structuring the project

Yes, you can absolutely separate the `provider` and `subscription_id` configuration into a different `.tf` file. Terraform/OpenTofu automatically combines all `.tf` files in the same directory during initialization and execution, so separating these configurations is a clean and effective way to organize your project.

---

### Example Structure

Here’s how you can organize your project:

#### **1. File Structure**
```
project-directory/
├── main.tf         # Contains resource definitions
├── provider.tf     # Contains provider and subscription configuration
├── variables.tf    # Contains variable definitions
└── terraform.tfvars # (Optional) Contains variable values
```

#### **2. `provider.tf` File**
This file contains the Azure provider configuration:
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

#### **3. `variables.tf` File**
Declare the `subscription_id` variable here:
```hcl
variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
```

#### **4. `terraform.tfvars` File**
Define the value of the `subscription_id` here (this file should not be uploaded to version control):
```hcl
subscription_id = "your-azure-subscription-id"
```

How to retrieve your `subscription ID`
```
az account show --query id --output tsv
```
> effaFFFF-0000-4ec6-9e9d-3235dFFFFFeb

#### **5. `main.tf` File**
Keep resource definitions here, like this:
```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}
```

---

### Benefits of This Approach
1. **Better Organization:** Cleanly separates provider configurations from resource definitions.
2. **Security:** By using `.tfvars` or environment variables, you can avoid committing sensitive data to your repository.
3. **Reusability:** You can reuse the `provider.tf` configuration across multiple projects with minimal changes.

---

### Protecting Sensitive Files
To ensure that sensitive files like `terraform.tfvars` are not accidentally uploaded to GitHub, add them to `.gitignore`:
```bash
echo "terraform.tfvars" >> .gitignore
```

---

### Running OpenTofu
To apply your configuration with the separate files:
1. Initialize:
   ```bash
   tofu init
   ```
      > Returns
   ```powershell
      
   Initializing the backend...
   
   Initializing provider plugins...
   - Finding latest version of hashicorp/azurerm...
   - Installing hashicorp/azurerm v4.15.0...
   - Installed hashicorp/azurerm v4.15.0 (signed, key ID 0C0AF313E5FD9F80)
   
   Providers are signed by their developers.
   If you''d like to know more about provider signing, you can read about it here:
   https://opentofu.org/docs/cli/plugins/signing/
   
   OpenTofu has created a lock file .terraform.lock.hcl to record the provider
   selections it made above. Include this file in your version control repository
   so that OpenTofu can guarantee to make the same selections by default when
   you run "tofu init" in the future.
   
   OpenTofu has been successfully initialized!
   
   You may now begin working with OpenTofu. Try running "tofu plan" to see
   any changes that are required for your infrastructure. All OpenTofu commands
   should now work.
   
   If you ever set or change modules or backend configuration for OpenTofu,
   rerun this command to reinitialize your working directory. If you forget, other
   commands will detect it and remind you to do so if necessary.
   ```

2. Plan:
   ```bash
   tofu plan
   ```
   > Returns
   ```powershell   
   
   OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
   the following symbols:
     + create
   
   OpenTofu will perform the following actions:
   
     # azurerm_linux_virtual_machine.lab1_vm will be created
     + resource "azurerm_linux_virtual_machine" "lab1_vm" {
         + admin_username                                         = "azureuser"
         + allow_extension_operations                             = true
         + bypass_platform_safety_checks_on_user_schedule_enabled = false
         + computer_name                                          = (known after apply)
         + custom_data                                            = (sensitive value)
         + disable_password_authentication                        = true
         + disk_controller_type                                   = (known after apply)
         + extensions_time_budget                                 = "PT1H30M"
         + id                                                     = (known after apply)
         + location                                               = "eastus"
         + max_bid_price                                          = -1
         + name                                                   = "lab1-vm"
         + network_interface_ids                                  = (known after apply)
         + patch_assessment_mode                                  = "ImageDefault"
         + patch_mode                                             = "ImageDefault"
         + platform_fault_domain                                  = -1
         + priority                                               = "Regular"
         + private_ip_address                                     = (known after apply)
         + private_ip_addresses                                   = (known after apply)
         + provision_vm_agent                                     = true
         + public_ip_address                                      = (known after apply)
         + public_ip_addresses                                    = (known after apply)
         + resource_group_name                                    = "lab1-resources"
         + size                                                   = "Standard_B1ls"
         + virtual_machine_id                                     = (known after apply)
         + vm_agent_platform_updates_enabled                      = false
   
         + admin_ssh_key {
             + public_key = <<-EOT
                   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDONOtoMa5/y6apillwwATeBV2HivPitn1OkfZlJKHwD+R+jHToz+bfx5RnGspH/5VwdWfFJiOKPYUxhYY7pxDBLQ04dD6LbizqE1OtF1voX9uFUbTcPkrMRUr9lg7Qrl/UefWGFbaaTcaJ0eNRqKlZQJ7IToU16Bdxjfwv0eg41aAOUjICH+sMaBBIttWM27kwSdaiaT3/tWaC0FrNYNUAm08ibP7FtNJelYXe5Crt0ttXCN/rFZkqfb5NdPupyCMnPKKq0lar8zZ3RMKoNZFhCvQ2D4IJXPs7Px9PeCdWb3/3YKGjy7WaHXT+cR7jJL+S+JnkdwXJHAGJrDdpKN6uBUTA5jK/86FHlap26YJDqg7+QGmD62GhTVKVLLF1W4uYEycN4eSj/aZ21LZIcVmbHp8hnzMibKIfOnYf3HurXFK8TRPLM3nJtWpKRJ6nVj+92/BNp5G9Vwy97J/FvO5/DLj72haC/Jli6N8Sc5h83japn3A6Zu327HAdBqWZNwM= robert@saipal.eurecom.fr
               EOT
             + username   = "azureuser"
           }
   
         + os_disk {
             + caching                   = "ReadWrite"
             + disk_size_gb              = (known after apply)
             + id                        = (known after apply)
             + name                      = (known after apply)
             + storage_account_type      = "Standard_LRS"
             + write_accelerator_enabled = false
           }
   
         + source_image_reference {
             + offer     = "UbuntuServer"
             + publisher = "Canonical"
             + sku       = "18.04-LTS"
             + version   = "latest"
           }
   
         + termination_notification (known after apply)
       }
   
     # azurerm_network_interface.lab1_nic will be created
     + resource "azurerm_network_interface" "lab1_nic" {
         + accelerated_networking_enabled = false
         + applied_dns_servers            = (known after apply)
         + id                             = (known after apply)
         + internal_domain_name_suffix    = (known after apply)
         + ip_forwarding_enabled          = false
         + location                       = "eastus"
         + mac_address                    = (known after apply)
         + name                           = "lab1-nic"
         + private_ip_address             = (known after apply)
         + private_ip_addresses           = (known after apply)
         + resource_group_name            = "lab1-resources"
         + virtual_machine_id             = (known after apply)
   
         + ip_configuration {
             + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
             + name                                               = "internal"
             + primary                                            = (known after apply)
             + private_ip_address                                 = (known after apply)
             + private_ip_address_allocation                      = "Dynamic"
             + private_ip_address_version                         = "IPv4"
             + public_ip_address_id                               = (known after apply)
             + subnet_id                                          = (known after apply)
           }
       }
   
     # azurerm_network_security_group.lab1_nsg will be created
     + resource "azurerm_network_security_group" "lab1_nsg" {
         + id                  = (known after apply)
         + location            = "eastus"
         + name                = "lab1-nsg"
         + resource_group_name = "lab1-resources"
         + security_rule       = [
             + {
                 + access                                     = "Allow"
                 + description                                = ""
                 + destination_address_prefix                 = "*"
                 + destination_address_prefixes               = []
                 + destination_application_security_group_ids = []
                 + destination_port_range                     = "22"
                 + destination_port_ranges                    = []
                 + direction                                  = "Inbound"
                 + name                                       = "AllowSSH"
                 + priority                                   = 1000
                 + protocol                                   = "Tcp"
                 + source_address_prefix                      = "*"
                 + source_address_prefixes                    = []
                 + source_application_security_group_ids      = []
                 + source_port_range                          = "*"
                 + source_port_ranges                         = []
               },
             + {
                 + access                                     = "Allow"
                 + description                                = ""
                 + destination_address_prefix                 = "*"
                 + destination_address_prefixes               = []
                 + destination_application_security_group_ids = []
                 + destination_port_range                     = "80"
                 + destination_port_ranges                    = []
                 + direction                                  = "Inbound"
                 + name                                       = "AllowHTTP"
                 + priority                                   = 1001
                 + protocol                                   = "Tcp"
                 + source_address_prefix                      = "*"
                 + source_address_prefixes                    = []
                 + source_application_security_group_ids      = []
                 + source_port_range                          = "*"
                 + source_port_ranges                         = []
               },
           ]
       }
   
     # azurerm_public_ip.lab1_public_ip will be created
     + resource "azurerm_public_ip" "lab1_public_ip" {
         + allocation_method       = "Static"
         + ddos_protection_mode    = "VirtualNetworkInherited"
         + fqdn                    = (known after apply)
         + id                      = (known after apply)
         + idle_timeout_in_minutes = 4
         + ip_address              = (known after apply)
         + ip_version              = "IPv4"
         + location                = "eastus"
         + name                    = "lab1-public-ip"
         + resource_group_name     = "lab1-resources"
         + sku                     = "Standard"
         + sku_tier                = "Regional"
       }
   
     # azurerm_resource_group.lab1 will be created
     + resource "azurerm_resource_group" "lab1" {
         + id       = (known after apply)
         + location = "eastus"
         + name     = "lab1-resources"
       }
   
     # azurerm_subnet.lab1_subnet will be created
     + resource "azurerm_subnet" "lab1_subnet" {
         + address_prefixes                              = [
             + "10.0.1.0/24",
           ]
         + default_outbound_access_enabled               = true
         + id                                            = (known after apply)
         + name                                          = "lab1-subnet"
         + private_endpoint_network_policies             = "Disabled"
         + private_link_service_network_policies_enabled = true
         + resource_group_name                           = "lab1-resources"
         + virtual_network_name                          = "lab1-vnet"
       }
   
     # azurerm_subnet_network_security_group_association.lab1_subnet_nsg will be created
     + resource "azurerm_subnet_network_security_group_association" "lab1_subnet_nsg" {
         + id                        = (known after apply)
         + network_security_group_id = (known after apply)
         + subnet_id                 = (known after apply)
       }
   
     # azurerm_virtual_network.lab1_vnet will be created
     + resource "azurerm_virtual_network" "lab1_vnet" {
         + address_space                  = [
             + "10.0.0.0/16",
           ]
         + dns_servers                    = (known after apply)
         + guid                           = (known after apply)
         + id                             = (known after apply)
         + location                       = "eastus"
         + name                           = "lab1-vnet"
         + private_endpoint_vnet_policies = "Disabled"
         + resource_group_name            = "lab1-resources"
         + subnet                         = (known after apply)
       }
   
   Plan: 8 to add, 0 to change, 0 to destroy.
   
   ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   
   Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly these actions
   if you run "tofu apply" now.
   ```

3. Apply:
   ```bash
   tofu apply
   ```
   > Returns
   ```powershell
   
   OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
   the following symbols:
     + create
   
   OpenTofu will perform the following actions:
   
     # azurerm_linux_virtual_machine.lab1_vm will be created
     + resource "azurerm_linux_virtual_machine" "lab1_vm" {
         + admin_username                                         = "azureuser"
         + allow_extension_operations                             = true
         + bypass_platform_safety_checks_on_user_schedule_enabled = false
         + computer_name                                          = (known after apply)
         + custom_data                                            = (sensitive value)
         + disable_password_authentication                        = true
         + disk_controller_type                                   = (known after apply)
         + extensions_time_budget                                 = "PT1H30M"
         + id                                                     = (known after apply)
         + location                                               = "eastus"
         + max_bid_price                                          = -1
         + name                                                   = "lab1-vm"
         + network_interface_ids                                  = (known after apply)
         + patch_assessment_mode                                  = "ImageDefault"
         + patch_mode                                             = "ImageDefault"
         + platform_fault_domain                                  = -1
         + priority                                               = "Regular"
         + private_ip_address                                     = (known after apply)
         + private_ip_addresses                                   = (known after apply)
         + provision_vm_agent                                     = true
         + public_ip_address                                      = (known after apply)
         + public_ip_addresses                                    = (known after apply)
         + resource_group_name                                    = "lab1-resources"
         + size                                                   = "Standard_B1ls"
         + virtual_machine_id                                     = (known after apply)
         + vm_agent_platform_updates_enabled                      = false
   
         + admin_ssh_key {
             + public_key = <<-EOT
                   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDONOtoMa5/y6apillwwATeBV2HivPitn1OkfZlJKHwD+R+jHToz+bfx5RnGspH/5VwdWfFJiOKPYUxhYY7pxDBLQ04dD6LbizqE1OtF1voX9uFUbTcPkrMRUr9lg7Qrl/UefWGFbaaTcaJ0eNRqKlZQJ7IToU16Bdxjfwv0eg41aAOUjICH+sMaBBIttWM27kwSdaiaT3/tWaC0FrNYNUAm08ibP7FtNJelYXe5Crt0ttXCN/rFZkqfb5NdPupyCMnPKKq0lar8zZ3RMKoNZFhCvQ2D4IJXPs7Px9PeCdWb3/3YKGjy7WaHXT+cR7jJL+S+JnkdwXJHAGJrDdpKN6uBUTA5jK/86FHlap26YJDqg7+QGmD62GhTVKVLLF1W4uYEycN4eSj/aZ21LZIcVmbHp8hnzMibKIfOnYf3HurXFK8TRPLM3nJtWpKRJ6nVj+92/BNp5G9Vwy97J/FvO5/DLj72haC/Jli6N8Sc5h83japn3A6Zu327HAdBqWZNwM= robert@saipal.eurecom.fr
               EOT
             + username   = "azureuser"
           }
   
         + os_disk {
             + caching                   = "ReadWrite"
             + disk_size_gb              = (known after apply)
             + id                        = (known after apply)
             + name                      = (known after apply)
             + storage_account_type      = "Standard_LRS"
             + write_accelerator_enabled = false
           }
   
         + source_image_reference {
             + offer     = "UbuntuServer"
             + publisher = "Canonical"
             + sku       = "18.04-LTS"
             + version   = "latest"
           }
   
         + termination_notification (known after apply)
       }
   
     # azurerm_network_interface.lab1_nic will be created
     + resource "azurerm_network_interface" "lab1_nic" {
         + accelerated_networking_enabled = false
         + applied_dns_servers            = (known after apply)
         + id                             = (known after apply)
         + internal_domain_name_suffix    = (known after apply)
         + ip_forwarding_enabled          = false
         + location                       = "eastus"
         + mac_address                    = (known after apply)
         + name                           = "lab1-nic"
         + private_ip_address             = (known after apply)
         + private_ip_addresses           = (known after apply)
         + resource_group_name            = "lab1-resources"
         + virtual_machine_id             = (known after apply)
   
         + ip_configuration {
             + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
             + name                                               = "internal"
             + primary                                            = (known after apply)
             + private_ip_address                                 = (known after apply)
             + private_ip_address_allocation                      = "Dynamic"
             + private_ip_address_version                         = "IPv4"
             + public_ip_address_id                               = (known after apply)
             + subnet_id                                          = (known after apply)
           }
       }
   
     # azurerm_network_security_group.lab1_nsg will be created
     + resource "azurerm_network_security_group" "lab1_nsg" {
         + id                  = (known after apply)
         + location            = "eastus"
         + name                = "lab1-nsg"
         + resource_group_name = "lab1-resources"
         + security_rule       = [
             + {
                 + access                                     = "Allow"
                 + description                                = ""
                 + destination_address_prefix                 = "*"
                 + destination_address_prefixes               = []
                 + destination_application_security_group_ids = []
                 + destination_port_range                     = "22"
                 + destination_port_ranges                    = []
                 + direction                                  = "Inbound"
                 + name                                       = "AllowSSH"
                 + priority                                   = 1000
                 + protocol                                   = "Tcp"
                 + source_address_prefix                      = "*"
                 + source_address_prefixes                    = []
                 + source_application_security_group_ids      = []
                 + source_port_range                          = "*"
                 + source_port_ranges                         = []
               },
             + {
                 + access                                     = "Allow"
                 + description                                = ""
                 + destination_address_prefix                 = "*"
                 + destination_address_prefixes               = []
                 + destination_application_security_group_ids = []
                 + destination_port_range                     = "80"
                 + destination_port_ranges                    = []
                 + direction                                  = "Inbound"
                 + name                                       = "AllowHTTP"
                 + priority                                   = 1001
                 + protocol                                   = "Tcp"
                 + source_address_prefix                      = "*"
                 + source_address_prefixes                    = []
                 + source_application_security_group_ids      = []
                 + source_port_range                          = "*"
                 + source_port_ranges                         = []
               },
           ]
       }
   
     # azurerm_public_ip.lab1_public_ip will be created
     + resource "azurerm_public_ip" "lab1_public_ip" {
         + allocation_method       = "Static"
         + ddos_protection_mode    = "VirtualNetworkInherited"
         + fqdn                    = (known after apply)
         + id                      = (known after apply)
         + idle_timeout_in_minutes = 4
         + ip_address              = (known after apply)
         + ip_version              = "IPv4"
         + location                = "eastus"
         + name                    = "lab1-public-ip"
         + resource_group_name     = "lab1-resources"
         + sku                     = "Standard"
         + sku_tier                = "Regional"
       }
   
     # azurerm_resource_group.lab1 will be created
     + resource "azurerm_resource_group" "lab1" {
         + id       = (known after apply)
         + location = "eastus"
         + name     = "lab1-resources"
       }
   
     # azurerm_subnet.lab1_subnet will be created
     + resource "azurerm_subnet" "lab1_subnet" {
         + address_prefixes                              = [
             + "10.0.1.0/24",
           ]
         + default_outbound_access_enabled               = true
         + id                                            = (known after apply)
         + name                                          = "lab1-subnet"
         + private_endpoint_network_policies             = "Disabled"
         + private_link_service_network_policies_enabled = true
         + resource_group_name                           = "lab1-resources"
         + virtual_network_name                          = "lab1-vnet"
       }
   
     # azurerm_subnet_network_security_group_association.lab1_subnet_nsg will be created
     + resource "azurerm_subnet_network_security_group_association" "lab1_subnet_nsg" {
         + id                        = (known after apply)
         + network_security_group_id = (known after apply)
         + subnet_id                 = (known after apply)
       }
   
     # azurerm_virtual_network.lab1_vnet will be created
     + resource "azurerm_virtual_network" "lab1_vnet" {
         + address_space                  = [
             + "10.0.0.0/16",
           ]
         + dns_servers                    = (known after apply)
         + guid                           = (known after apply)
         + id                             = (known after apply)
         + location                       = "eastus"
         + name                           = "lab1-vnet"
         + private_endpoint_vnet_policies = "Disabled"
         + resource_group_name            = "lab1-resources"
         + subnet                         = (known after apply)
       }
   
   Plan: 8 to add, 0 to change, 0 to destroy.
   
   Do you want to perform these actions?
     OpenTofu will perform the actions described above.
     Only 'yes' will be accepted to approve.
   
     Enter a value: yes
   
   azurerm_resource_group.lab1: Creating...
   azurerm_resource_group.lab1: Still creating... [10s elapsed]
   azurerm_resource_group.lab1: Creation complete after 17s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
   azurerm_virtual_network.lab1_vnet: Creating...
   azurerm_public_ip.lab1_public_ip: Creating...
   azurerm_network_security_group.lab1_nsg: Creating...
   azurerm_network_security_group.lab1_nsg: Creation complete after 6s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg]
   azurerm_public_ip.lab1_public_ip: Creation complete after 7s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
   azurerm_virtual_network.lab1_vnet: Creation complete after 10s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
   azurerm_subnet.lab1_subnet: Creating...
   azurerm_subnet.lab1_subnet: Still creating... [10s elapsed]
   azurerm_subnet.lab1_subnet: Creation complete after 10s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
   azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Creating...
   azurerm_network_interface.lab1_nic: Creating...
   azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Creation complete after 9s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
   azurerm_network_interface.lab1_nic: Still creating... [10s elapsed]
   azurerm_network_interface.lab1_nic: Creation complete after 14s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
   azurerm_linux_virtual_machine.lab1_vm: Creating...
   azurerm_linux_virtual_machine.lab1_vm: Still creating... [10s elapsed]
   azurerm_linux_virtual_machine.lab1_vm: Still creating... [20s elapsed]
   azurerm_linux_virtual_machine.lab1_vm: Still creating... [30s elapsed]
   azurerm_linux_virtual_machine.lab1_vm: Still creating... [40s elapsed]
   azurerm_linux_virtual_machine.lab1_vm: Still creating... [50s elapsed]
   azurerm_linux_virtual_machine.lab1_vm: Creation complete after 56s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
   
   Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
   ```

This setup is modular and easy to manage, especially in larger projects.

```
az vm list-ip-addresses --resource-group lab1-resources --output table
```
> Returns
```powershell
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
lab1-vm           172.191.25.162       10.0.1.4
```

### Destroy

   ```
   tofu destroy
   ```
   > Returns
   ```powershell
azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
azurerm_public_ip.lab1_public_ip: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
azurerm_virtual_network.lab1_vnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_network_security_group.lab1_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg]
azurerm_subnet.lab1_subnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_network_interface.lab1_nic: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_linux_virtual_machine.lab1_vm: Refreshing state... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

OpenTofu will perform the following actions:

  # azurerm_linux_virtual_machine.lab1_vm will be destroyed
  - resource "azurerm_linux_virtual_machine" "lab1_vm" {
      - admin_username                                         = "azureuser" -> null
      - allow_extension_operations                             = true -> null
      - bypass_platform_safety_checks_on_user_schedule_enabled = false -> null
      - computer_name                                          = "lab1-vm" -> null
      - custom_data                                            = (sensitive value) -> null
      - disable_password_authentication                        = true -> null
      - encryption_at_host_enabled                             = false -> null
      - extensions_time_budget                                 = "PT1H30M" -> null
      - id                                                     = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm" -> null
      - location                                               = "eastus" -> null
      - max_bid_price                                          = -1 -> null
      - name                                                   = "lab1-vm" -> null
      - network_interface_ids                                  = [
          - "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic",
        ] -> null
      - patch_assessment_mode                                  = "ImageDefault" -> null
      - patch_mode                                             = "ImageDefault" -> null
      - platform_fault_domain                                  = -1 -> null
      - priority                                               = "Regular" -> null
      - private_ip_address                                     = "10.0.1.4" -> null
      - private_ip_addresses                                   = [
          - "10.0.1.4",
        ] -> null
      - provision_vm_agent                                     = true -> null
      - public_ip_address                                      = "172.191.193.25" -> null
      - public_ip_addresses                                    = [
          - "172.191.193.25",
        ] -> null
      - resource_group_name                                    = "lab1-resources" -> null
      - secure_boot_enabled                                    = false -> null
      - size                                                   = "Standard_B1ls" -> null
      - tags                                                   = {} -> null
      - virtual_machine_id                                     = "ca4d1e69-bbba-41cf-9e18-e40ba1be851d" -> null
      - vm_agent_platform_updates_enabled                      = false -> null
      - vtpm_enabled                                           = false -> null

      - admin_ssh_key {
          - public_key = <<-EOT
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDONOtoMa5/y6apillwwATeBV2HivPitn1OkfZlJKHwD+R+jHToz+bfx5RnGspH/5VwdWfFJiOKPYUxhYY7pxDBLQ04dD6LbizqE1OtF1voX9uFUbTcPkrMRUr9lg7Qrl/UefWGFbaaTcaJ0eNRqKlZQJ7IToU16Bdxjfwv0eg41aAOUjICH+sMaBBIttWM27kwSdaiaT3/tWaC0FrNYNUAm08ibP7FtNJelYXe5Crt0ttXCN/rFZkqfb5NdPupyCMnPKKq0lar8zZ3RMKoNZFhCvQ2D4IJXPs7Px9PeCdWb3/3YKGjy7WaHXT+cR7jJL+S+JnkdwXJHAGJrDdpKN6uBUTA5jK/86FHlap26YJDqg7+QGmD62GhTVKVLLF1W4uYEycN4eSj/aZ21LZIcVmbHp8hnzMibKIfOnYf3HurXFK8TRPLM3nJtWpKRJ6nVj+92/BNp5G9Vwy97J/FvO5/DLj72haC/Jli6N8Sc5h83japn3A6Zu327HAdBqWZNwM= robert@saipal.eurecom.fr
            EOT -> null
          - username   = "azureuser" -> null
        }

      - os_disk {
          - caching                   = "ReadWrite" -> null
          - disk_size_gb              = 30 -> null
          - id                        = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/lab1-vm_OsDisk_1_4f43c3792f404c10a6d03fc3656eee59" -> null
          - name                      = "lab1-vm_OsDisk_1_4f43c3792f404c10a6d03fc3656eee59" -> null
          - storage_account_type      = "Standard_LRS" -> null
          - write_accelerator_enabled = false -> null
        }

      - source_image_reference {
          - offer     = "UbuntuServer" -> null
          - publisher = "Canonical" -> null
          - sku       = "18.04-LTS" -> null
          - version   = "latest" -> null
        }
    }

  # azurerm_network_interface.lab1_nic will be destroyed
  - resource "azurerm_network_interface" "lab1_nic" {
      - accelerated_networking_enabled = false -> null
      - applied_dns_servers            = [] -> null
      - dns_servers                    = [] -> null
      - id                             = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic" -> null
      - ip_forwarding_enabled          = false -> null
      - location                       = "eastus" -> null
      - mac_address                    = "60-45-BD-DB-61-8D" -> null
      - name                           = "lab1-nic" -> null
      - private_ip_address             = "10.0.1.4" -> null
      - private_ip_addresses           = [
          - "10.0.1.4",
        ] -> null
      - resource_group_name            = "lab1-resources" -> null
      - tags                           = {} -> null
      - virtual_machine_id             = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm" -> null

      - ip_configuration {
          - name                          = "internal" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.1.4" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - public_ip_address_id          = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip" -> null
          - subnet_id                     = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
        }
    }

  # azurerm_network_security_group.lab1_nsg will be destroyed
  - resource "azurerm_network_security_group" "lab1_nsg" {
      - id                  = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg" -> null
      - location            = "eastus" -> null
      - name                = "lab1-nsg" -> null
      - resource_group_name = "lab1-resources" -> null
      - security_rule       = [
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "22"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowSSH"
              - priority                                   = 1000
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "80"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowHTTP"
              - priority                                   = 1001
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
        ] -> null
      - tags                = {} -> null
    }

  # azurerm_public_ip.lab1_public_ip will be destroyed
  - resource "azurerm_public_ip" "lab1_public_ip" {
      - allocation_method       = "Static" -> null
      - ddos_protection_mode    = "VirtualNetworkInherited" -> null
      - id                      = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip" -> null
      - idle_timeout_in_minutes = 4 -> null
      - ip_address              = "172.191.193.25" -> null
      - ip_tags                 = {} -> null
      - ip_version              = "IPv4" -> null
      - location                = "eastus" -> null
      - name                    = "lab1-public-ip" -> null
      - resource_group_name     = "lab1-resources" -> null
      - sku                     = "Standard" -> null
      - sku_tier                = "Regional" -> null
      - tags                    = {} -> null
      - zones                   = [] -> null
    }

  # azurerm_resource_group.lab1 will be destroyed
  - resource "azurerm_resource_group" "lab1" {
      - id       = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources" -> null
      - location = "eastus" -> null
      - name     = "lab1-resources" -> null
      - tags     = {} -> null
    }

  # azurerm_subnet.lab1_subnet will be destroyed
  - resource "azurerm_subnet" "lab1_subnet" {
      - address_prefixes                              = [
          - "10.0.1.0/24",
        ] -> null
      - default_outbound_access_enabled               = true -> null
      - id                                            = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
      - name                                          = "lab1-subnet" -> null
      - private_endpoint_network_policies             = "Disabled" -> null
      - private_link_service_network_policies_enabled = true -> null
      - resource_group_name                           = "lab1-resources" -> null
      - service_endpoint_policy_ids                   = [] -> null
      - service_endpoints                             = [] -> null
      - virtual_network_name                          = "lab1-vnet" -> null
    }

  # azurerm_subnet_network_security_group_association.lab1_subnet_nsg will be destroyed
  - resource "azurerm_subnet_network_security_group_association" "lab1_subnet_nsg" {
      - id                        = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
      - network_security_group_id = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg" -> null
      - subnet_id                 = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
    }

  # azurerm_virtual_network.lab1_vnet will be destroyed
  - resource "azurerm_virtual_network" "lab1_vnet" {
      - address_space                  = [
          - "10.0.0.0/16",
        ] -> null
      - dns_servers                    = [] -> null
      - flow_timeout_in_minutes        = 0 -> null
      - guid                           = "1d8336d6-8d21-4fe6-ada7-638054f1f90b" -> null
      - id                             = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet" -> null
      - location                       = "eastus" -> null
      - name                           = "lab1-vnet" -> null
      - private_endpoint_vnet_policies = "Disabled" -> null
      - resource_group_name            = "lab1-resources" -> null
      - subnet                         = [
          - {
              - address_prefixes                              = [
                  - "10.0.1.0/24",
                ]
              - default_outbound_access_enabled               = true
              - delegation                                    = []
              - id                                            = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet"
              - name                                          = "lab1-subnet"
              - private_endpoint_network_policies             = "Disabled"
              - private_link_service_network_policies_enabled = true
              - route_table_id                                = ""
              - security_group                                = "/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg"
              - service_endpoint_policy_ids                   = []
              - service_endpoints                             = []
            },
        ] -> null
      - tags                           = {} -> null
    }

Plan: 0 to add, 0 to change, 8 to destroy.

Do you really want to destroy all resources?
  OpenTofu will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_linux_virtual_machine.lab1_vm: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Destruction complete after 6s
azurerm_network_security_group.lab1_nsg: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg]
azurerm_linux_virtual_machine.lab1_vm: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 10s elapsed]
azurerm_network_security_group.lab1_nsg: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...Network/networkSecurityGroups/lab1-nsg, 10s elapsed]
azurerm_network_security_group.lab1_nsg: Destruction complete after 12s
azurerm_linux_virtual_machine.lab1_vm: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 20s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 30s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 40s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 50s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Destruction complete after 51s
azurerm_network_interface.lab1_nic: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_network_interface.lab1_nic: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...oft.Network/networkInterfaces/lab1-nic, 10s elapsed]
azurerm_network_interface.lab1_nic: Destruction complete after 13s
azurerm_subnet.lab1_subnet: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_public_ip.lab1_public_ip: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
azurerm_public_ip.lab1_public_ip: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...twork/publicIPAddresses/lab1-public-ip, 10s elapsed]
azurerm_subnet.lab1_subnet: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...Networks/lab1-vnet/subnets/lab1-subnet, 10s elapsed]
azurerm_subnet.lab1_subnet: Destruction complete after 12s
azurerm_virtual_network.lab1_vnet: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_public_ip.lab1_public_ip: Destruction complete after 12s
azurerm_virtual_network.lab1_vnet: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...soft.Network/virtualNetworks/lab1-vnet, 10s elapsed]
azurerm_virtual_network.lab1_vnet: Destruction complete after 11s
azurerm_resource_group.lab1: Destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...d3e6b4eb/resourceGroups/lab1-resources, 10s elapsed]
azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/effa7872-2FF0-4006-9e9d-...d3e6b4eb/resourceGroups/lab1-resources, 20s elapsed]
azurerm_resource_group.lab1: Destruction complete after 22s

Destroy complete! Resources: 8 destroyed.
```

## Resize the VM

```
az vm deallocate --name lab1-vm --resource-group lab1-resources
```


```
tofu plan
```
> Returns
```powershell
azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
azurerm_network_security_group.lab1_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg]
azurerm_managed_disk.standard_ssd_disk: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/standard-ssd-disk]
azurerm_virtual_network.lab1_vnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_public_ip.lab1_public_ip: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
azurerm_managed_disk.premium_ssd_disk: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/premium-ssd-disk]
azurerm_subnet.lab1_subnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_network_interface.lab1_nic: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_linux_virtual_machine.lab1_vm: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  ~ update in-place

OpenTofu will perform the following actions:

  # azurerm_linux_virtual_machine.lab1_vm will be updated in-place
  ~ resource "azurerm_linux_virtual_machine" "lab1_vm" {
        id                                                     = "/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm"
        name                                                   = "lab1-vm"
      ~ size                                                   = "Standard_DS2_v2" -> "Standard_B1ls"
        tags                                                   = {}
        # (25 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly these actions
if you run "tofu apply" now.
```

```
tofu apply -var="vm_size=Standard_DS2_v2" -target=azurerm_linux_virtual_machine.lab1_vm
```
> Returns
```powershell
azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
azurerm_public_ip.lab1_public_ip: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
azurerm_virtual_network.lab1_vnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_subnet.lab1_subnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_network_interface.lab1_nic: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_linux_virtual_machine.lab1_vm: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  ~ update in-place

OpenTofu will perform the following actions:

  # azurerm_linux_virtual_machine.lab1_vm will be updated in-place
  ~ resource "azurerm_linux_virtual_machine" "lab1_vm" {
        id                                                     = "/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm"
        name                                                   = "lab1-vm"
      ~ size                                                   = "Standard_B1ls" -> "Standard_DS2_v2"
        tags                                                   = {}
        # (25 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│ 
│ You are creating a plan with either the -target option or the -exclude option, which means that the result of
│ this plan may not represent all of the changes requested by the current configuration.
│ 
│ The -target and -exclude options are not for routine use, and are provided only for exceptional situations such
│ as recovering from errors or mistakes, or when OpenTofu specifically suggests to use it as part of an error
│ message.
╵

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_linux_virtual_machine.lab1_vm: Modifying... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
azurerm_linux_virtual_machine.lab1_vm: Still modifying... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 10s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still modifying... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 20s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still modifying... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 30s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Still modifying... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 40s elapsed]
azurerm_linux_virtual_machine.lab1_vm: Modifications complete after 44s [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
╷
│ Warning: Applied changes may be incomplete
│ 
│ The plan was created with the -target or the -exclude option in effect, so some changes requested in the
│ configuration may have been ignored and the output values may not be fully updated. Run the following command to
│ verify that no other changes are pending:
│     tofu plan
│ 	
│ Note that the -target and -exclude options are not suitable for routine use, and are provided only for
│ exceptional situations such as recovering from errors or mistakes, or when OpenTofu specifically suggests to use
│ it as part of an error message.
╵

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

```
az vm start --name lab1-vm --resource-group lab1-resources
```

## WebApp

```
tofu plan
```
> Returns 
```powershell
azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources]
azurerm_managed_disk.premium_ssd_disk: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/premium-ssd-disk]
azurerm_managed_disk.standard_ssd_disk: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/standard-ssd-disk]
azurerm_network_security_group.lab1_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkSecurityGroups/lab1-nsg]
azurerm_public_ip.lab1_public_ip: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/publicIPAddresses/lab1-public-ip]
azurerm_virtual_network.lab1_vnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_subnet.lab1_subnet: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_subnet_network_security_group_association.lab1_subnet_nsg: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_network_interface.lab1_nic: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_linux_virtual_machine.lab1_vm: Refreshing state... [id=/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

OpenTofu will perform the following actions:

  # azurerm_storage_account.lab1-sa will be created
  + resource "azurerm_storage_account" "lab1-sa" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = false
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "eastus"
      + min_tls_version                    = "TLS1_2"
      + name                               = "lab1webapp"
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = "lab1-resources"
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"

      + blob_properties (known after apply)

      + network_rules (known after apply)

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)

      + static_website (known after apply)
    }

  # azurerm_storage_account_static_website.static_site will be created
  + resource "azurerm_storage_account_static_website" "static_site" {
      + id                 = (known after apply)
      + index_document     = "index.html"
      + storage_account_id = (known after apply)
    }

  # azurerm_storage_blob.html will be created
  + resource "azurerm_storage_blob" "html" {
      + access_tier            = (known after apply)
      + content_type           = "application/octet-stream"
      + id                     = (known after apply)
      + metadata               = (known after apply)
      + name                   = "webapp.html"
      + parallelism            = 8
      + size                   = 0
      + source                 = "./index.html"
      + storage_account_name   = "lab1webapp"
      + storage_container_name = "$web"
      + type                   = "Block"
      + url                    = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + static_site_url = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly these actions
if you run "tofu apply" now.
```

## Resizing VM

```
az vm stop --name lab1-vm --resource-group lab1-resources
```
> Returns
```powershell
About to power off the specified VM...
It will continue to be billed. To deallocate a VM, run: az vm deallocate.
```


```
az vm resize --name lab1-vm --resource-group lab1-resources --size Standard_DS2_v2
```
> Returns
```json
{
  "additionalCapabilities": null,
  "applicationProfile": null,
  "availabilitySet": null,
  "billingProfile": null,
  "capacityReservation": null,
  "diagnosticsProfile": {
    "bootDiagnostics": {
      "enabled": false,
      "storageUri": null
    }
  },
  "etag": "\"4\"",
  "evictionPolicy": null,
  "extendedLocation": null,
  "extensionsTimeBudget": "PT1H30M",
  "hardwareProfile": {
    "vmSize": "Standard_DS2_v2",
    "vmSizeProperties": null
  },
  "host": null,
  "hostGroup": null,
  "id": "/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm",
  "identity": null,
  "instanceView": null,
  "licenseType": null,
  "location": "eastus",
  "managedBy": null,
  "name": "lab1-vm",
  "networkProfile": {
    "networkApiVersion": null,
    "networkInterfaceConfigurations": null,
    "networkInterfaces": [
      {
        "deleteOption": null,
        "id": "/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic",
        "primary": true,
        "resourceGroup": "lab1-resources"
      }
    ]
  },
  "osProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "lab1-vm",
    "customData": null,
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "enableVmAgentPlatformUpdates": false,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "automaticByPlatformSettings": null,
        "patchMode": "ImageDefault"
      },
      "provisionVmAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDONOtoMa5/y6apillwwATeBV2HivPitn1OkfZlJKHwD+R+jHToz+bfx5RnGspH/5VwdWfFJiOKPYUxhYY7pxDBLQ04dD6LbizqE1OtF1voX9uFUbTcPkrMRUr9lg7Qrl/UefWGFbaaTcaJ0eNRqKlZQJ7IToU16Bdxjfwv0eg41aAOUjICH+sMaBBIttWM27kwSdaiaT3/tWaC0FrNYNUAm08ibP7FtNJelYXe5Crt0ttXCN/rFZkqfb5NdPupyCMnPKKq0lar8zZ3RMKoNZFhCvQ2D4IJXPs7Px9PeCdWb3/3YKGjy7WaHXT+cR7jJL+S+JnkdwXJHAGJrDdpKN6uBUTA5jK/86FHlap26YJDqg7+QGmD62GhTVKVLLF1W4uYEycN4eSj/aZ21LZIcVmbHp8hnzMibKIfOnYf3HurXFK8TRPLM3nJtWpKRJ6nVj+92/BNp5G9Vwy97J/FvO5/DLj72haC/Jli6N8Sc5h83japn3A6Zu327HAdBqWZNwM= robert@saipal.eurecom.fr\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": [],
    "windowsConfiguration": null
  },
  "plan": null,
  "platformFaultDomain": null,
  "priority": "Regular",
  "provisioningState": "Succeeded",
  "proximityPlacementGroup": null,
  "resourceGroup": "lab1-resources",
  "resources": null,
  "scheduledEventsPolicy": null,
  "scheduledEventsProfile": null,
  "securityProfile": null,
  "storageProfile": {
    "dataDisks": [],
    "diskControllerType": null,
    "imageReference": {
      "communityGalleryImageId": null,
      "exactVersion": "18.04.202401161",
      "id": null,
      "offer": "UbuntuServer",
      "publisher": "Canonical",
      "sharedGalleryImageId": null,
      "sku": "18.04-LTS",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diffDiskSettings": null,
      "diskSizeGb": 30,
      "encryptionSettings": null,
      "image": null,
      "managedDisk": {
        "diskEncryptionSet": null,
        "id": "/subscriptions/effa7872-2FF0-4FF6-9e9d-3FFFFFFFFFb/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/lab1-vm_OsDisk_1_41a85ea6e7e3466bbfdeac4f7673aee8",
        "resourceGroup": "lab1-resources",
        "securityProfile": null,
        "storageAccountType": "Standard_LRS"
      },
      "name": "lab1-vm_OsDisk_1_41a85ea6e7e3466bbfdeac4f7673aee8",
      "osType": "Linux",
      "vhd": null,
      "writeAcceleratorEnabled": false
    }
  },
  "tags": {},
  "timeCreated": "2025-01-18T22:10:06.333527+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "userData": null,
  "virtualMachineScaleSet": null,
  "vmId": "5023f4e7-0aaf-421a-84ff-f6b3eb42a709",
  "zones": null
}
```

```
az vm start --name lab1-vm --resource-group lab1-resources
```
/Running...

```
az vm show --name lab1-vm --resource-group lab1-resources --query "hardwareProfile.vmSize"
```
> Standard_DS2_v2"

# References

## Cloud-Init

**Cloud-init** is a powerful tool used to initialize cloud instances during boot, such as configuring users, installing packages, and running scripts. Here's a comprehensive guide to help you understand and effectively use cloud-init.

---

### **Basic Structure of Cloud-Init**
Cloud-init configuration files typically use YAML syntax and consist of the following sections:

1. **`packages`**: List of packages to install.
2. **`runcmd`**: Commands to run at boot time.
3. **`write_files`**: Write files to the instance.
4. **`users`**: Configure users and SSH keys.
5. **`bootcmd`**: Commands that run very early in the boot process.

#### Example:
```yaml
#cloud-config
packages:
  - nginx

runcmd:
  - echo "Welcome to my server" > /var/www/html/index.html
  - systemctl restart nginx
```

### **Best Practices**
1. **Test Locally First**: Use a local VM to validate your cloud-init script.
2. **Keep Scripts Idempotent**: Cloud-init runs only on the first boot. Ensure scripts are safe to reapply if needed.
3. **Use `write_files` for Complex Configurations**: Store large configurations directly in files rather than inline commands.
4. **Enable Logging**: Monitor cloud-init logs during troubleshooting.

---

## Access the VM using `ssh`

- [ ] Add the `ssh` private key to the `ssh-agent` list

```
ssh-add ~/.ssh/robert@eurecom.fr
```

- [ ] Access the VM

* List the available VM 

```
az vm list-ip-addresses --resource-group lab1-resources --output table
```
> Returns
```powershell

VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
lab1-vm           172.191.25.162       10.0.1.4
```

* Use the public IP address

```
ssh azureuser@172.191.25.162
```

## Docker

Here’s a step-by-step guide to creating a Dockerized static site, running it in a VM, and verifying it with `curl`. The steps use the reference from AzureMOL Chapter 19.2 for a simple Nginx Docker container.

### Step 0: Copy the Static HTML File

```
cat docker-index.html| pbcopy
```

---

### Step 1: Create a Static HTML File
Inside your VM, create a directory for the project and add an HTML file:

```bash
mkdir docker-static-site
cd docker-static-site
vi index.html
<paste all the content copied above>
```

---

### Step 2: Create a Dockerfile
Create a `Dockerfile` in the same directory to set up an Nginx container:

```bash
cat <<EOF > Dockerfile
# Use the official Nginx image as the base
FROM nginx:latest

# Copy the static HTML file to the default Nginx directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80
EOF
```

---

### Step 3: Build the Docker Image
Build the Docker image locally:

```bash
docker build -t static-site .
```

---

### Step 4: Run the Docker Container
Run the container and map port 80 on the host to port 80 on the container:

```bash
docker run -d -p 8080:80 --name static-site-container static-site
```

---

### Step 5: Verify the Deployment with `curl`
Use `curl` to ensure the site is served correctly:

```bash
curl http://localhost:8080
```

You should see the HTML content:
```html
<!DOCTYPE html>
<html>
<head><title>Static Site</title></head>
<!DOCTYPE html>
<html lang="en">
<body>
  <header>
    <h1>Welcome to the Lab1 &#x1F324; Container Registry</h1>
  </header>
  <main>
    <p>The purpose of this <b>lab1</b> is to demonstrate how to use IaC (Infrastructure as Code)</p>
    <p>The entire IaC Code for this lab can be accessed here  &#x1F449;<a href="https://github.com/setrar/Clouds/tree/main/Labs/Azure/lab1/IaC" target="_blank">IaC Lab1</a> </p>
  </main>
  <footer>
    <p>&copy; 2025 Student: ......</p>
  </footer>
</body>
</html>
</html>
```

---

### Step 6: Get the ACR Login Server from Azure Shell
After the registry is created, you can retrieve the login server using Azure CLI:


```
az acr list --resource-group lab1-resources --query "[].{loginServer:loginServer}" -o table
```
> Returns
```powershell 
LoginServer
-----------------------------
acrclouds2025eurbr.azurecr.io
```

### Step 7: Docker Login to ACR from the VM

```
az acr credential show --name acrclouds2025eurbr
```
> Returns
```json
{
  "passwords": [
    {
      "name": "password",
      "value": "IAHZCrJhXjFGXwobviouskaXDCwulFuJ5T/YdIs5gZMICRCsA5SH"
    },
    {
      "name": "password2",
      "value": "91HXoXDCwulFuJ5T/YdIs5gZMI1dQvjbJobviousvXYTxQuIyt"
    }
  ],
  "username": "acrclouds2025eurbr"
}
```

### Step 8: Docker Login to ACR from the VM

1. **Login to ACR**  
   From the VM:
   ```bash
   docker login acrclouds2025eurbr.azurecr.io
   ```
   > Returns
   ```powershell
   WARNING! Your password will be stored unencrypted in /home/azureuser/.docker/config.json.
   Configure a credential helper to remove this warning. See
   https://docs.docker.com/engine/reference/commandline/login/#credentials-store
   
   Login Succeeded
   ```

   Enter the username and password retrieved earlier.

---

### Step 9: Push the Docker Image to ACR

1. **Tag Your Docker Image**  
   Tag the local image with the ACR login server:
   ```bash
   docker tag static-site acrclouds2025eurbr.azurecr.io/static-site:v1
   ```

2. **Push the Docker Image**  
   Push the image to the ACR:
   ```bash
   docker push acrclouds2025eurbr.azurecr.io/static-site:v1
   ```

3. **Verify the Image in ACR**  
   Check that the image is successfully pushed:
   ```bash
   az acr repository list --name acrclouds2025eurbr --output table
   ```

### Create ACR

```
az container create \
  --resource-group lab1-resources \
  --name static-site-container \
  --image acrclouds2025eurbr.azurecr.io/static-site:v1 \
  --cpu 1 \
  --memory 1 \
  --ports 80 \
  --dns-name-label acrclouds2025eurbr \
  --query ipAddress.fqdn \
  --os-type Linux \
  --registry-login-server acrclouds2025eurbr.azurecr.io \
  --registry-username acrclouds2025eurbr \
  --registry-password <acr-password>
```
> / Running ..

## Resize VM

```
# Stop the VM
az vm stop --resource-group lab1-resources --name lab1-vm

# Resize the VM
az vm resize --resource-group lab1-resources --name lab1-vm --size Standard_DS3_v2

# Start the VM
az vm start --resource-group lab1-resources --name lab1-vm
```

```
# Verify the new size
az vm show --resource-group lab1-resources --name lab1-vm --query "hardwareProfile.vmSize"
```
> "Standard_DS3_v2"

If only the OS disk is showing and the data disks (e.g., `standard-ssd-disk` and `premium-ssd-disk`) are not, it indicates that the data disks are either:

1. **Not properly attached to the VM**.
2. **Attached but not initialized or mounted inside the VM**.

Here’s how to investigate and resolve the issue:

---

### **1. Verify the VM Configuration**
Ensure that the `data_disk` blocks in the OpenTofu configuration correctly reference the managed disks and are applied successfully. Double-check the `lun` and `managed_disk_id` values.

#### Check VM's Disk Configuration:
```bash
az vm show --name lab1-vm --resource-group lab1-resources --query "storageProfile.dataDisks" -o table
```

#### Expected Output:
```powershell
[]
```

---

### **2. Attach the Disks Manually (If Missing)**
If the disks do not appear in the output, attach them manually to the VM:

#### Attach `standard-ssd-disk`:
```bash
az vm disk attach \
  --vm-name lab1-vm \
  --resource-group lab1-resources \
  --name standard-ssd-disk \
  --caching ReadOnly \
  --lun 0
```
>  / Running ..

#### Attach `premium-ssd-disk`:
```bash
az vm disk attach \
  --vm-name lab1-vm \
  --resource-group lab1-resources \
  --name premium-ssd-disk \
  --caching ReadOnly \
  --lun 1
```
>  / Running ..

---

### **3. Verify Attached Disks**
Check if the disks are now properly attached to the VM:
```bash
az vm show --name lab1-vm --resource-group lab1-resources --query "storageProfile.dataDisks" -o table
```
> Returns
```powershell
Lun    Name               Caching    CreateOption    DiskSizeGb    ToBeDetached    DeleteOption
-----  -----------------  ---------  --------------  ------------  --------------  --------------
0      standard-ssd-disk  ReadOnly   Attach          50            False           Detach
1      premium-ssd-disk   ReadOnly   Attach          50            False           Detach
```

---

### **4. Inside the VM: Check and Initialize the Disks**
SSH into the VM to ensure the attached disks are visible and initialize them.

#### Check Attached Disks:
```bash
lsblk
```

Expected output:
```plaintext
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda       8:0    0   30G  0 disk 
├─sda1    8:1    0 29.9G  0 part /
├─sda14   8:14   0    4M  0 part 
└─sda15   8:15   0  106M  0 part /boot/efi
sdb       8:16   0   28G  0 disk 
└─sdb1    8:17   0   28G  0 part /mnt
sdc       8:32   0   50G  0 disk 
sdd       8:48   0   50G  0 disk
```

#### Format and Mount Disks:
If the disks are visible as `/dev/sdb` and `/dev/sdc`:
1. Format the disks:
   ```bash
   sudo mkfs.ext4 /dev/sdb
   sudo mkfs.ext4 /dev/sdc
   ```
   > Returns
   ```powershell
   mke2fs 1.44.1 (24-Mar-2018)
   Found a dos partition table in /dev/sdb
   Proceed anyway? (y,N) y
   ```

2. Create mount points:
   ```bash
   sudo mkdir -p /mnt/standard_ssd
   sudo mkdir -p /mnt/premium_ssd
   ```

3. Mount the disks:
   ```bash
   sudo mount /dev/sdb /mnt/standard_ssd
   ```

   ##### Error when VM is not resized properly when the VM is too small

   ```
   sudo mount /dev/sdc /mnt/premium_ssd
   ```
   > mount: /mnt/premium_ssd: wrong fs type, bad option, bad superblock on /dev/sdc, missing codepage or helper program, or other error.


The error indicates that `/dev/sdc` (your premium SSD disk) is either unformatted or has an unsupported file system. To resolve this issue, you need to check the disk's state, format it with a supported file system, and then mount it.

---

##### **Steps to Fix the Issue**

###### **1. Verify Disk State**
Run the following command to check the state of the disk:
```bash
sudo lsblk
```

Look for `/dev/sdc` in the output. If the `TYPE` field is `disk` and there are no partitions under it, it means the disk is unformatted.

---

###### **2. Check for Existing File System**
Run the following command to check if a file system exists on the disk:
```bash
sudo file -s /dev/sdc
```

- **Output Example**:
  - `data`: Indicates the disk is unformatted.
  - `ext4 filesystem`: Indicates an existing file system (e.g., `ext4`).

---

###### **3. Format the Disk**
If the disk is unformatted or you want to reformat it, use the following command to format it with `ext4`:

```bash
sudo mkfs.ext4 /dev/sdc
```

- **Explanation**:
  - `mkfs.ext4`: Creates an `ext4` file system on the disk.
  - `/dev/sdc`: Specifies the target disk.

---

###### **4. Mount the Disk**
After formatting, mount the disk again:
```bash
sudo mkdir -p /mnt/premium_ssd
sudo mount /dev/sdc /mnt/premium_ssd
```

---

###### **5. Verify the Mount**
Check if the disk is mounted successfully:
```bash
df -h
```
> Returns
```
Filesystem      Size  Used Avail Use% Mounted on
udev            6.9G     0  6.9G   0% /dev
tmpfs           1.4G  736K  1.4G   1% /run
/dev/sda1        29G  2.2G   27G   8% /
tmpfs           6.9G     0  6.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           6.9G     0  6.9G   0% /sys/fs/cgroup
/dev/sda15      105M  5.3M  100M   5% /boot/efi
/dev/sdb1        28G   36K   26G   1% /mnt
tmpfs           1.4G     0  1.4G   0% /run/user/1000
/dev/sdc         49G   24K   47G   1% /mnt/premium_ssd
```

You should see `/mnt/premium_ssd` listed with the available disk space.


## **FIO** 

Here's a step-by-step guide to install **FIO** and measure the sequential throughput and random read IOPS on the two devices (`/dev/sdb` for `standard_ssd_disk` and `/dev/sdc` for `premium_ssd_disk`).

---

### **1. Install FIO**
Run the following commands to install **FIO** on Ubuntu 20.04:
```bash
sudo apt update
sudo apt install -y fio
```

---

### **2. Prepare the Devices**
Before running FIO, ensure the devices are unmounted and ready for testing. If you previously mounted the devices, unmount them:
```bash
sudo umount /dev/sdb
sudo umount /dev/sdc
```

---

### **3. Run FIO Tests**

#### **Sequential Throughput (64KB)**
Use FIO to test the sequential read/write throughput with 64KB block sizes. Replace `<device>` with `/dev/sdb` (Standard SSD) or `/dev/sdc` (Premium SSD).

```bash
sudo fio --name=seq_readwrite_test --rw=rw --bs=64k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=<device> --group_reporting
```

#### Example:
For `/dev/sdb`:
```bash
sudo fio --name=seq_readwrite_test --rw=rw --bs=64k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=/dev/sdb --group_reporting
```
> Returns
```powershell
seq_readwrite_test: (g=0): rw=rw, bs=(R) 64.0KiB-64.0KiB, (W) 64.0KiB-64.0KiB, (T) 64.0KiB-64.0KiB, ioengine=libaio, iodepth=32
fio-3.1
Starting 1 process
[I 2025-01-19 09:17:28.716 ServerApp] Adapting from protocol version 5.0 (kernel e65fb00f-ddfe-488d-b878-3d214e20505f) to 5.3 (client).
                    [I 2025-01-19 09:17:28.717 ServerApp] Connecting to kernel e65fb00f-ddfe-488d-b878-3d214e20505f.
Jobs: 1 (f=1): [M(1)][100.0%][r=191MiB/s,w=193MiB/s][r=3061,w=3081 IOPS][eta 00m:00s]
seq_readwrite_test: (groupid=0, jobs=1): err= 0: pid=3172: Sun Jan 19 08:17:35 2025
   read: IOPS=3128, BW=196MiB/s (205MB/s)(11.5GiB/60001msec)
    slat (usec): min=3, max=128, avg= 6.46, stdev= 2.33
    clat (usec): min=22, max=61608, avg=4887.76, stdev=13635.36
     lat (usec): min=28, max=61616, avg=4894.35, stdev=13635.32
    clat percentiles (usec):
     |  1.00th=[   62],  5.00th=[   95], 10.00th=[  130], 20.00th=[  194],
     | 30.00th=[  247], 40.00th=[  297], 50.00th=[  347], 60.00th=[  396],
     | 70.00th=[  445], 80.00th=[  519], 90.00th=[34866], 95.00th=[42730],
     | 99.00th=[57934], 99.50th=[58459], 99.90th=[58983], 99.95th=[58983],
     | 99.99th=[60556]
   bw (  KiB/s): min=147584, max=312192, per=100.00%, avg=200320.00, stdev=17627.25, samples=119
   iops        : min= 2306, max= 4878, avg=3129.99, stdev=275.41, samples=119
  write: IOPS=3124, BW=195MiB/s (205MB/s)(11.4GiB/60001msec)
    slat (usec): min=4, max=379, avg= 8.95, stdev= 3.23
    clat (usec): min=101, max=65998, avg=5329.75, stdev=13605.94
     lat (usec): min=109, max=66005, avg=5338.84, stdev=13605.72
    clat percentiles (usec):
     |  1.00th=[  167],  5.00th=[  251], 10.00th=[  351], 20.00th=[  502],
     | 30.00th=[  603], 40.00th=[  701], 50.00th=[  783], 60.00th=[  873],
     | 70.00th=[  971], 80.00th=[ 1172], 90.00th=[34866], 95.00th=[42730],
     | 99.00th=[57934], 99.50th=[58459], 99.90th=[59507], 99.95th=[60031],
     | 99.99th=[61604]
   bw (  KiB/s): min=142080, max=325376, per=100.00%, avg=200080.45, stdev=18854.69, samples=119
   iops        : min= 2220, max= 5084, avg=3126.22, stdev=294.60, samples=119
  lat (usec)   : 50=0.16%, 100=2.71%, 250=14.86%, 500=31.25%, 750=18.38%
  lat (usec)   : 1000=13.61%
  lat (msec)   : 2=7.94%, 4=0.82%, 10=0.04%, 50=8.36%, 100=1.88%
  cpu          : usr=2.33%, sys=5.73%, ctx=126550, majf=0, minf=13
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwt: total=187740,187487,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=196MiB/s (205MB/s), 196MiB/s-196MiB/s (205MB/s-205MB/s), io=11.5GiB (12.3GB), run=60001-60001msec
  WRITE: bw=195MiB/s (205MB/s), 195MiB/s-195MiB/s (205MB/s-205MB/s), io=11.4GiB (12.3GB), run=60001-60001msec

Disk stats (read/write):
  sdb: ios=187370/187115, merge=0/0, ticks=909920/994469, in_queue=1636252, util=99.85%
```

For `/dev/sdc`:
```bash
sudo fio --name=seq_readwrite_test --rw=rw --bs=64k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=/dev/sdc --group_reporting
```
> Returns
```powershell
seq_readwrite_test: (g=0): rw=rw, bs=(R) 64.0KiB-64.0KiB, (W) 64.0KiB-64.0KiB, (T) 64.0KiB-64.0KiB, ioengine=libaio, iodepth=32
fio-3.1
Starting 1 process
[I 2025-01-19 09:19:28.604 ServerApp] Saving file at /lab1/REPORT.ipynb[eta 00m:43s]
                                                                       Jobs: 1 (f=1): [M(1)][30.0%][r=19.2MiB/s,w=1Jobs: 1 (f=1): [M(1)][100.0%][r=19.7MiB/s,w=18.6MiB/s][r=315,w=297 IOPS][eta 00m:00s]
seq_readwrite_test: (groupid=0, jobs=1): err= 0: pid=3218: Sun Jan 19 08:20:11 2025
   read: IOPS=421, BW=26.3MiB/s (27.6MB/s)(1582MiB/60067msec)
    slat (nsec): min=3500, max=71400, avg=7957.65, stdev=4643.59
    clat (usec): min=34, max=145007, avg=32259.94, stdev=23712.53
     lat (usec): min=40, max=145013, avg=32268.05, stdev=23712.84
    clat percentiles (usec):
     |  1.00th=[    60],  5.00th=[    95], 10.00th=[   149], 20.00th=[   314],
     | 30.00th=[   553], 40.00th=[ 38536], 50.00th=[ 42730], 60.00th=[ 45351],
     | 70.00th=[ 46924], 80.00th=[ 47973], 90.00th=[ 55837], 95.00th=[ 62129],
     | 99.00th=[ 90702], 99.50th=[ 99091], 99.90th=[106431], 99.95th=[107480],
     | 99.99th=[109577]
   bw (  KiB/s): min=16512, max=41600, per=100.00%, avg=26970.92, stdev=8666.17, samples=120
   iops        : min=  258, max=  650, avg=421.39, stdev=135.39, samples=120
  write: IOPS=420, BW=26.3MiB/s (27.6MB/s)(1579MiB/60067msec)
    slat (nsec): min=4500, max=63200, avg=11880.46, stdev=5351.94
    clat (msec): min=3, max=123, avg=43.75, stdev=20.07
     lat (msec): min=3, max=123, avg=43.76, stdev=20.07
    clat percentiles (msec):
     |  1.00th=[    7],  5.00th=[    8], 10.00th=[   10], 20.00th=[   24],
     | 30.00th=[   45], 40.00th=[   47], 50.00th=[   48], 60.00th=[   50],
     | 70.00th=[   51], 80.00th=[   54], 90.00th=[   64], 95.00th=[   66],
     | 99.00th=[  102], 99.50th=[  108], 99.90th=[  111], 99.95th=[  113],
     | 99.99th=[  118]
   bw (  KiB/s): min=17500, max=41856, per=100.00%, avg=26930.43, stdev=8684.50, samples=120
   iops        : min=  273, max=  654, avg=420.76, stdev=135.68, samples=120
  lat (usec)   : 50=0.09%, 100=2.72%, 250=5.60%, 500=5.75%, 750=1.73%
  lat (usec)   : 1000=0.18%
  lat (msec)   : 2=0.02%, 4=0.22%, 10=7.28%, 20=2.67%, 50=50.66%
  lat (msec)   : 100=22.25%, 250=0.82%
  cpu          : usr=0.63%, sys=1.18%, ctx=26548, majf=0, minf=10
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.9%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwt: total=25308,25262,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=26.3MiB/s (27.6MB/s), 26.3MiB/s-26.3MiB/s (27.6MB/s-27.6MB/s), io=1582MiB (1659MB), run=60067-60067msec
  WRITE: bw=26.3MiB/s (27.6MB/s), 26.3MiB/s-26.3MiB/s (27.6MB/s-27.6MB/s), io=1579MiB (1656MB), run=60067-60067msec

Disk stats (read/write):
  sdc: ios=25297/25220, merge=0/0, ticks=811088/1101940, in_queue=1822952, util=99.90%
```

#### **Random Read IOPS (4KB)**
Use FIO to test random read IOPS with 4KB block sizes.

```bash
sudo fio --name=random_read_iops --rw=randread --bs=4k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=<device> --group_reporting
```

#### Example:
For `/dev/sdb`:
```bash
sudo fio --name=random_read_iops --rw=randread --bs=4k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=/dev/sdb --group_reporting
```
> Returns
```powershell
random_read_iops: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.1
Starting 1 process
Jobs: 1 (f=1): [r(1)][100.0%][r=63.8MiB/s,w=0KiB/s][r=16.3k,w=0 IOPS][eta 00m:00s]
random_read_iops: (groupid=0, jobs=1): err= 0: pid=3244: Sun Jan 19 08:26:12 2025
   read: IOPS=16.3k, BW=63.7MiB/s (66.8MB/s)(3825MiB/60036msec)
    slat (usec): min=2, max=120, avg= 3.57, stdev= 1.30
    clat (usec): min=94, max=59061, avg=1957.59, stdev=8311.93
     lat (usec): min=97, max=59065, avg=1961.28, stdev=8311.88
    clat percentiles (usec):
     |  1.00th=[  133],  5.00th=[  155], 10.00th=[  174], 20.00th=[  204],
     | 30.00th=[  235], 40.00th=[  265], 50.00th=[  289], 60.00th=[  318],
     | 70.00th=[  347], 80.00th=[  392], 90.00th=[  465], 95.00th=[  570],
     | 99.00th=[41681], 99.50th=[54264], 99.90th=[56886], 99.95th=[56886],
     | 99.99th=[57410]
   bw (  KiB/s): min=59008, max=71808, per=100.00%, avg=65274.49, stdev=853.09, samples=120
   iops        : min=14752, max=17952, avg=16318.61, stdev=213.26, samples=120
  lat (usec)   : 100=0.01%, 250=35.45%, 500=57.17%, 750=3.29%, 1000=0.12%
  lat (msec)   : 2=0.03%, 4=0.01%, 10=0.01%, 50=3.31%, 100=0.62%
  cpu          : usr=3.16%, sys=6.70%, ctx=82444, majf=0, minf=41
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwt: total=979264,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=63.7MiB/s (66.8MB/s), 63.7MiB/s-63.7MiB/s (66.8MB/s-66.8MB/s), io=3825MiB (4011MB), run=60036-60036msec

Disk stats (read/write):
  sdb: ios=977600/0, merge=0/0, ticks=1874212/0, in_queue=1549204, util=99.90%
```

For `/dev/sdc`:
```bash
sudo fio --name=random_read_iops --rw=randread --bs=4k --direct=1 \
         --ioengine=libaio --iodepth=32 --numjobs=1 --runtime=60 \
         --time_based --filename=/dev/sdc --group_reporting
```
> Returns
```powershell
random_read_iops: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.1
Starting 1 process
Jobs: 1 (f=1): [r(1)][100.0%][r=2574KiB/s,w=0KiB/s][r=643,w=0 IOPS][eta 00m:00s]
random_read_iops: (groupid=0, jobs=1): err= 0: pid=3252: Sun Jan 19 08:29:55 2025
   read: IOPS=645, BW=2583KiB/s (2645kB/s)(152MiB/60077msec)
    slat (nsec): min=2400, max=66400, avg=5021.12, stdev=4168.97
    clat (usec): min=32, max=157036, avg=49541.93, stdev=16634.05
     lat (usec): min=36, max=157041, avg=49547.10, stdev=16634.00
    clat percentiles (usec):
     |  1.00th=[   176],  5.00th=[   510], 10.00th=[ 44827], 20.00th=[ 46924],
     | 30.00th=[ 46924], 40.00th=[ 47449], 50.00th=[ 47449], 60.00th=[ 47973],
     | 70.00th=[ 48497], 80.00th=[ 56361], 90.00th=[ 63177], 95.00th=[ 64750],
     | 99.00th=[109577], 99.50th=[110625], 99.90th=[111674], 99.95th=[111674],
     | 99.99th=[119014]
   bw (  KiB/s): min= 2496, max= 3144, per=100.00%, avg=2583.95, stdev=61.48, samples=120
   iops        : min=  624, max=  786, avg=645.95, stdev=15.38, samples=120
  lat (usec)   : 50=0.02%, 100=0.19%, 250=2.81%, 500=1.97%, 750=0.10%
  lat (usec)   : 1000=0.02%
  lat (msec)   : 2=0.01%, 4=0.09%, 10=0.14%, 20=0.01%, 50=67.30%
  lat (msec)   : 100=25.63%, 250=1.72%
  cpu          : usr=0.22%, sys=0.64%, ctx=12716, majf=0, minf=42
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.9%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwt: total=38798,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=2583KiB/s (2645kB/s), 2583KiB/s-2583KiB/s (2645kB/s-2645kB/s), io=152MiB (159MB), run=60077-60077msec

Disk stats (read/write):
  sdc: ios=38703/0, merge=0/0, ticks=1914099/0, in_queue=1815520, util=99.89%
```


---

### **4. Output Interpretation**
FIO will output results like this:
```plaintext
seq_readwrite_test: (g=0): rw=rw, bs=64k-64k/64k-64k, ioengine=libaio, iodepth=32
...
write: IOPS=500, BW=31.2MiB/s (32.7MB/s), Latency (usec): min=10, max=1100, avg=50
```

- **IOPS**: Input/Output Operations Per Second.
- **BW**: Bandwidth in MB/s.
- **Latency**: Time taken for each I/O operation.

For random read IOPS, focus on the **IOPS** value. For sequential throughput, focus on the **BW** (Bandwidth) value.


