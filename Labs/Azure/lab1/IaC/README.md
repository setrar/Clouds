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
   tofu plan
   
   OpenTofu used the selected providers to generate the following execution plan. Resource actions are
   indicated with the following symbols:
     + create
   
   OpenTofu will perform the following actions:
   
     # azurerm_network_interface.lab1 will be created
     + resource "azurerm_network_interface" "lab1" {
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
             + subnet_id                                          = (known after apply)
           }
       }
   
     # azurerm_resource_group.lab1 will be created
     + resource "azurerm_resource_group" "lab1" {
         + id       = (known after apply)
         + location = "eastus"
         + name     = "lab1-resources"
       }
   
     # azurerm_subnet.lab1 will be created
     + resource "azurerm_subnet" "lab1" {
         + address_prefixes                              = [
             + "10.0.2.0/24",
           ]
         + default_outbound_access_enabled               = true
         + id                                            = (known after apply)
         + name                                          = "lab1-subnet"
         + private_endpoint_network_policies             = "Disabled"
         + private_link_service_network_policies_enabled = true
         + resource_group_name                           = "lab1-resources"
         + virtual_network_name                          = "lab1-vnet"
       }
   
     # azurerm_virtual_machine.lab1 will be created
     + resource "azurerm_virtual_machine" "lab1" {
         + availability_set_id              = (known after apply)
         + delete_data_disks_on_termination = false
         + delete_os_disk_on_termination    = false
         + id                               = (known after apply)
         + license_type                     = (known after apply)
         + location                         = "eastus"
         + name                             = "lab1-vm"
         + network_interface_ids            = (known after apply)
         + resource_group_name              = "lab1-resources"
         + vm_size                          = "Standard_B2s"
   
         + os_profile {
             # At least one attribute in this block is (or was) sensitive,
             # so its contents will not be displayed.
           }
   
         + os_profile_linux_config {
             + disable_password_authentication = false
           }
   
         + storage_data_disk (known after apply)
   
         + storage_image_reference {
             + offer     = "UbuntuServer"
             + publisher = "Canonical"
             + sku       = "18.04-LTS"
             + version   = "latest"
           }
   
         + storage_os_disk {
             + caching                   = "ReadWrite"
             + create_option             = "FromImage"
             + disk_size_gb              = (known after apply)
             + managed_disk_id           = (known after apply)
             + managed_disk_type         = "Standard_LRS"
             + name                      = "lab1-os-disk"
             + os_type                   = (known after apply)
             + write_accelerator_enabled = false
           }
       }
   
     # azurerm_virtual_network.lab1 will be created
     + resource "azurerm_virtual_network" "lab1" {
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
   
   Plan: 5 to add, 0 to change, 0 to destroy.
   
   ──────────────────────────────────────────────────────────────────────────────────────────────────────
   
   Note: You didn't use the -out option to save this plan, so OpenTofu can't guarantee to take exactly
   these actions if you run "tofu apply" now.
   ```
3. Apply:
   ```bash
   tofu apply
   ```
   > Returns
   ```powershell
   
   OpenTofu used the selected providers to generate the following execution plan. Resource actions are
   indicated with the following symbols:
     + create
   
   OpenTofu will perform the following actions:
   
     # azurerm_network_interface.lab1 will be created
     + resource "azurerm_network_interface" "lab1" {
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
             + subnet_id                                          = (known after apply)
           }
       }
   
     # azurerm_resource_group.lab1 will be created
     + resource "azurerm_resource_group" "lab1" {
         + id       = (known after apply)
         + location = "eastus"
         + name     = "lab1-resources"
       }
   
     # azurerm_subnet.lab1 will be created
     + resource "azurerm_subnet" "lab1" {
         + address_prefixes                              = [
             + "10.0.2.0/24",
           ]
         + default_outbound_access_enabled               = true
         + id                                            = (known after apply)
         + name                                          = "lab1-subnet"
         + private_endpoint_network_policies             = "Disabled"
         + private_link_service_network_policies_enabled = true
         + resource_group_name                           = "lab1-resources"
         + virtual_network_name                          = "lab1-vnet"
       }
   
     # azurerm_virtual_machine.lab1 will be created
     + resource "azurerm_virtual_machine" "lab1" {
         + availability_set_id              = (known after apply)
         + delete_data_disks_on_termination = false
         + delete_os_disk_on_termination    = false
         + id                               = (known after apply)
         + license_type                     = (known after apply)
         + location                         = "eastus"
         + name                             = "lab1-vm"
         + network_interface_ids            = (known after apply)
         + resource_group_name              = "lab1-resources"
         + vm_size                          = "Standard_B2s"
   
         + os_profile {
             # At least one attribute in this block is (or was) sensitive,
             # so its contents will not be displayed.
           }
   
         + os_profile_linux_config {
             + disable_password_authentication = false
           }
   
         + storage_data_disk (known after apply)
   
         + storage_image_reference {
             + offer     = "UbuntuServer"
             + publisher = "Canonical"
             + sku       = "18.04-LTS"
             + version   = "latest"
           }
   
         + storage_os_disk {
             + caching                   = "ReadWrite"
             + create_option             = "FromImage"
             + disk_size_gb              = (known after apply)
             + managed_disk_id           = (known after apply)
             + managed_disk_type         = "Standard_LRS"
             + name                      = "lab1-os-disk"
             + os_type                   = (known after apply)
             + write_accelerator_enabled = false
           }
       }
   
     # azurerm_virtual_network.lab1 will be created
     + resource "azurerm_virtual_network" "lab1" {
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
   
   Plan: 5 to add, 0 to change, 0 to destroy.
   
   Do you want to perform these actions?
     OpenTofu will perform the actions described above.
     Only 'yes' will be accepted to approve.
   
     Enter a value: yes
   
   azurerm_resource_group.lab1: Creating...
   azurerm_resource_group.lab1: Still creating... [10s elapsed]
   azurerm_resource_group.lab1: Creation complete after 15s [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFF/resourceGroups/lab1-resources]
   azurerm_virtual_network.lab1: Creating...
   azurerm_virtual_network.lab1: Creation complete after 9s [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
   azurerm_subnet.lab1: Creating...
   azurerm_subnet.lab1: Creation complete after 9s [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
   azurerm_network_interface.lab1: Creating...
   azurerm_network_interface.lab1: Still creating... [10s elapsed]
   azurerm_network_interface.lab1: Creation complete after 16s [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
   azurerm_virtual_machine.lab1: Creating...
   azurerm_virtual_machine.lab1: Still creating... [10s elapsed]
   azurerm_virtual_machine.lab1: Still creating... [20s elapsed]
   azurerm_virtual_machine.lab1: Creation complete after 23s [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
   
   Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
   ```

This setup is modular and easy to manage, especially in larger projects.

```
az vm list --output table
```
> Returns
```powershell
Name     ResourceGroup    Location    Zones
-------  ---------------  ----------  -------
lab1-vm  LAB1-RESOURCES   eastus
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

