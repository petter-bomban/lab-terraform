terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=2.46.0"
        }
    }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
    name = "${var.prefix}-rg-terraform-001"
    location = var.location
    tags = { environment = "pblab-tf-001"}
}

resource "azurerm_virtual_network" "main" {
    name                = "${var.prefix}-vnet-terraform-001"
    address_space       = ["10.0.0.0/16"] #255.255.0.0
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    tags = { environment = "pblab-tf-001"}
}

resource "azurerm_subnet" "internal" {
    name                 = "internal"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.2.0/24"] #255.255.255.0
}

resource "azurerm_network_interface" "main" {
    name                = "${var.prefix}-nic-terraform-001"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location

    ip_configuration {
        name                            = "internal"
        subnet_id                       = azurerm_subnet.internal.id
        private_ip_address_allocation   = "Dynamic"
    }

    tags = { environment = "pblab-tf-001"}
}

#Public IP setup
resource "azurerm_public_ip" "main" {
    name                         = "${var.prefix}-pubip-terraform-001"
    location                     = azurerm_resource_group.main.location
    resource_group_name          = azurerm_resource_group.main.name
    allocation_method            = "Dynamic"
    tags                         = { environment = "pblab-tf-001"}
}

resource "azurerm_network_security_group" "main" {
    name                = "tf01_nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "RDP"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = { environment = "pblab-tf-001"}
}

resource "azurerm_network_interface" "public" {
    name                = "${var.prefix}-pubnic-terraform-001"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location

    ip_configuration {
        name                            = "public"
        subnet_id                       = azurerm_subnet.internal.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.main.id
    }

    tags = { environment = "pblab-tf-001"}
}

# connect security group
resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id                = azurerm_network_interface.public.id
    network_security_group_id           = azurerm_network_security_group.main.id
}

# End public ip setup


resource "azurerm_windows_virtual_machine" "main" {
    name                    = "${var.prefix}-wstf-001" ##22 char limit
    resource_group_name     = azurerm_resource_group.main.name
    location                = azurerm_resource_group.main.location
    size                    = "Standard_F2"
    admin_username          = var.admin_username
    admin_password          = var.admin_password
    network_interface_ids = [
        azurerm_network_interface.public.id,
    ]

    source_image_reference {
        publisher   = "MicrosoftWindowsServer"
        offer       = "WindowsServer"
        sku         = "2019-Datacenter"
        version     = "latest"
    }

    os_disk {
        storage_account_type    = "Standard_LRS"
        caching                 = "ReadWrite"
    }

    tags = { environment = "pblab-tf-001"}
}





