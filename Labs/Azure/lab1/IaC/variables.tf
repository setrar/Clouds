variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "vm_size" {
  default     = "Standard_B1ls"  # Free tier or low-cost instance
  description = "The size of the virtual machine."
}

