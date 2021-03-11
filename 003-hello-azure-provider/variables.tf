variable "prefix" {
    default = "pblab"
    description = "The prefix which should be used for all resources in this example"
}

variable "location" {
    default = "westeurope"
    description = "The Azure Region in which all resources in this example should be created."
}

variable "admin_username" {
    default = "petter"
}

variable "admin_password" {
    default = "Aa123456789"
}
