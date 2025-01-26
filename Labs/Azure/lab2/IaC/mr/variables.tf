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
  description = "Name of the Azure Function App"
  default = "clouds25brlab2mrfnc"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository URL to deploy"
  type        = string
  default = "https://github.com/setrar"
}

variable "github_repo_name" {
  description = "GitHub repository URL to deploy"
  type        = string
  default = "CloudsMRFunction"
}


