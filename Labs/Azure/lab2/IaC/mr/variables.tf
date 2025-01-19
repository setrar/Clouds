# Define variables
variable "resource_group_name" {
  default = "lab2-mapreduce-rg"
}

variable "location" {
  default = "East US"
}

variable "storage_account_name" {
  default = "clouds25brlab2mrstrg"
}

variable "function_app_name" {
  default = "clouds25brlab2mrapp"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

