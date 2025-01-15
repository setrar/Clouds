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
resource "azurerm_resource_group" "lab1" {
  name     = "lab1-resources"
  location = "East US"
}

resource "azurerm_virtual_machine" "lab1" {
  name                  = "lab1-vm"
  location              = azurerm_resource_group.lab1.location
  resource_group_name   = azurerm_resource_group.lab1.name
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "lab1-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "lab1-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids = [
    azurerm_network_interface.lab1.id,
  ]
}

resource "azurerm_network_interface" "lab1" {
  name                = "lab1-nic"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "lab1" {
  name                = "lab1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
}

resource "azurerm_subnet" "lab1" {
  name                 = "lab1-subnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.lab1.name
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
azurerm_resource_group.lab1: Refreshing state... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources]
azurerm_virtual_network.lab1: Refreshing state... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_subnet.lab1: Refreshing state... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_network_interface.lab1: Refreshing state... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_virtual_machine.lab1: Refreshing state... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]

OpenTofu used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  - destroy

OpenTofu will perform the following actions:

  # azurerm_network_interface.lab1 will be destroyed
  - resource "azurerm_network_interface" "lab1" {
      - accelerated_networking_enabled = false -> null
      - applied_dns_servers            = [] -> null
      - dns_servers                    = [] -> null
      - id                             = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic" -> null
      - internal_domain_name_suffix    = "1nwnomxop54urnr0pso2tnjiob.bx.internal.cloudapp.net" -> null
      - ip_forwarding_enabled          = false -> null
      - location                       = "eastus" -> null
      - mac_address                    = "00-0D-3A-9A-1F-FA" -> null
      - name                           = "lab1-nic" -> null
      - private_ip_address             = "10.0.2.4" -> null
      - private_ip_addresses           = [
          - "10.0.2.4",
        ] -> null
      - resource_group_name            = "lab1-resources" -> null
      - tags                           = {} -> null
      - virtual_machine_id             = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm" -> null

      - ip_configuration {
          - name                          = "internal" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.2.4" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - subnet_id                     = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
        }
    }

  # azurerm_resource_group.lab1 will be destroyed
  - resource "azurerm_resource_group" "lab1" {
      - id       = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources" -> null
      - location = "eastus" -> null
      - name     = "lab1-resources" -> null
      - tags     = {} -> null
    }

  # azurerm_subnet.lab1 will be destroyed
  - resource "azurerm_subnet" "lab1" {
      - address_prefixes                              = [
          - "10.0.2.0/24",
        ] -> null
      - default_outbound_access_enabled               = true -> null
      - id                                            = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet" -> null
      - name                                          = "lab1-subnet" -> null
      - private_endpoint_network_policies             = "Disabled" -> null
      - private_link_service_network_policies_enabled = true -> null
      - resource_group_name                           = "lab1-resources" -> null
      - service_endpoint_policy_ids                   = [] -> null
      - service_endpoints                             = [] -> null
      - virtual_network_name                          = "lab1-vnet" -> null
    }

  # azurerm_virtual_machine.lab1 will be destroyed
  - resource "azurerm_virtual_machine" "lab1" {
      - delete_data_disks_on_termination = false -> null
      - delete_os_disk_on_termination    = false -> null
      - id                               = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm" -> null
      - location                         = "eastus" -> null
      - name                             = "lab1-vm" -> null
      - network_interface_ids            = [
          - "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic",
        ] -> null
      - resource_group_name              = "lab1-resources" -> null
      - tags                             = {} -> null
      - vm_size                          = "Standard_B2s" -> null
      - zones                            = [] -> null

      - os_profile {
          # At least one attribute in this block is (or was) sensitive,
          # so its contents will not be displayed.
        }

      - os_profile_linux_config {
          - disable_password_authentication = false -> null
        }

      - storage_image_reference {
          - offer     = "UbuntuServer" -> null
          - publisher = "Canonical" -> null
          - sku       = "18.04-LTS" -> null
          - version   = "latest" -> null
        }

      - storage_os_disk {
          - caching                   = "ReadWrite" -> null
          - create_option             = "FromImage" -> null
          - disk_size_gb              = 30 -> null
          - managed_disk_id           = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/disks/lab1-os-disk" -> null
          - managed_disk_type         = "Standard_LRS" -> null
          - name                      = "lab1-os-disk" -> null
          - os_type                   = "Linux" -> null
          - write_accelerator_enabled = false -> null
        }
    }

  # azurerm_virtual_network.lab1 will be destroyed
  - resource "azurerm_virtual_network" "lab1" {
      - address_space                  = [
          - "10.0.0.0/16",
        ] -> null
      - dns_servers                    = [] -> null
      - flow_timeout_in_minutes        = 0 -> null
      - guid                           = "32d76cdb-7fee-48fd-b63a-7c9dc9b52871" -> null
      - id                             = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet" -> null
      - location                       = "eastus" -> null
      - name                           = "lab1-vnet" -> null
      - private_endpoint_vnet_policies = "Disabled" -> null
      - resource_group_name            = "lab1-resources" -> null
      - subnet                         = [
          - {
              - address_prefixes                              = [
                  - "10.0.2.0/24",
                ]
              - default_outbound_access_enabled               = true
              - delegation                                    = []
              - id                                            = "/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet"
              - name                                          = "lab1-subnet"
              - private_endpoint_network_policies             = "Disabled"
              - private_link_service_network_policies_enabled = true
              - route_table_id                                = ""
              - security_group                                = ""
              - service_endpoint_policy_ids                   = []
              - service_endpoints                             = []
            },
        ] -> null
      - tags                           = {} -> null
    }

Plan: 0 to add, 0 to change, 5 to destroy.

Do you really want to destroy all resources?
  OpenTofu will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes 

azurerm_virtual_machine.lab1: Destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Compute/virtualMachines/lab1-vm]
azurerm_virtual_machine.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 10s elapsed]
azurerm_virtual_machine.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 20s elapsed]
azurerm_virtual_machine.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...rosoft.Compute/virtualMachines/lab1-vm, 30s elapsed]
azurerm_virtual_machine.lab1: Destruction complete after 35s
azurerm_network_interface.lab1: Destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/networkInterfaces/lab1-nic]
azurerm_network_interface.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...oft.Network/networkInterfaces/lab1-nic, 10s elapsed]
azurerm_network_interface.lab1: Destruction complete after 13s
azurerm_subnet.lab1: Destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet/subnets/lab1-subnet]
azurerm_subnet.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...Networks/lab1-vnet/subnets/lab1-subnet, 10s elapsed]
azurerm_subnet.lab1: Destruction complete after 11s
azurerm_virtual_network.lab1: Destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources/providers/Microsoft.Network/virtualNetworks/lab1-vnet]
azurerm_virtual_network.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...soft.Network/virtualNetworks/lab1-vnet, 10s elapsed]
azurerm_virtual_network.lab1: Destruction complete after 13s
azurerm_resource_group.lab1: Destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-3235dFFFFFF/resourceGroups/lab1-resources]
azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...dFFFFFFF/resourceGroups/lab1-resources, 10s elapsed]   ```
...
azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/effa7872-28e0-FFFF-9e9d-...dFFFFFFF/resourceGroups/lab1-resources, 6m50s elapsed]
...
azurerm_resource_group.lab1: Still destroying... [id=/subscriptions/effa7872-FFFF-4ec6-9e9d-...d3FFFFFF/resourceGroups/lab1-resources, 10m0s elapsed]
╷
│ Error: deleting Resource Group "lab1-resources": the Resource Group still contains Resources.
│ 
│ Terraform is configured to check for Resources within the Resource Group when deleting the Resource Group - and
│ raise an error if nested Resources still exist to avoid unintentionally deleting these Resources.
│ 
│ Terraform has detected that the following Resources still exist within the Resource Group:
│ 
│ * `/subscriptions/effa7872-FFFF-4ec6-9e9d-3235d3FFFFFF/resourceGroups/LAB1-RESOURCES/providers/Microsoft.Compute/disks/lab1-os-disk`
│ 
│ This feature is intended to avoid the unintentional destruction of nested Resources provisioned through some
│ other means (for example, an ARM Template Deployment) - as such you must either remove these Resources, or
│ disable this behaviour using the feature flag `prevent_deletion_if_contains_resources` within the `features`
│ block when configuring the Provider, for example:
│ 
│ provider "azurerm" {
│   features {
│     resource_group {
│       prevent_deletion_if_contains_resources = false
│     }
│   }
│ }
│ 
│ When that feature flag is set, Terraform will skip checking for any Resources within the Resource Group and
│ delete this using the Azure API directly (which will clear up any nested resources).
│ 
│ More information on the `features` block can be found in the documentation:
│ https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
│ 
│ 
│ 
╵
```

- [ ] Had to manually delete the `Resource Group`

```
tofu destroy
```
> Returns
```powershell
azurerm_resource_group.example: Refreshing state... [id=/subscriptions/effa7872-FFFF-4ec6-9e9d-323FFFFF/resourceGroups/example-resources]

No changes. No objects need to be destroyed.

Either you have not created any objects yet or the existing objects were already deleted outside of OpenTofu.

Destroy complete! Resources: 0 destroyed.
```
