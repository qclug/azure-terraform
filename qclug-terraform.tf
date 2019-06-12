# Configure the Microsoft Azure Provider
provider "azurerm" {
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "qcluggroup" {
        name = "QCLUG-Terraform"
        location = "northcentralus"
}


# Create virtual network
resource "azurerm_virtual_network" "qclugnetwork" {
    name                = "QCLUG-vnet"
    address_space       = ["10.0.0.0/24"]
    location            = "northcentralus"
    resource_group_name = "${azurerm_resource_group.qcluggroup.name}"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "qclugsubnet" {
    name                 = "default"
    resource_group_name  = "${azurerm_resource_group.qcluggroup.name}"
    virtual_network_name = "${azurerm_virtual_network.qclugnetwork.name}"
    address_prefix       = "10.0.0.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "qclugpublicip" {
    name                         = "myPublicIP"
    location                     = "northcentralus"
    resource_group_name          = "${azurerm_resource_group.qcluggroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "qclugnsg" {
    name                = "qclug-vm-1-nsg"
    location            = "northcentralus"
    resource_group_name = "${azurerm_resource_group.qcluggroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 340
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 320
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "QCLUG"
    }
}

# Create network interface
resource "azurerm_network_interface" "qclugnic" {
    name                      = "qclug-vm-192"
    location                  = "northcentralus"
    resource_group_name       = "${azurerm_resource_group.qcluggroup.name}"
    network_security_group_id = "${azurerm_network_security_group.qclugnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.qclugsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.qclugpublicip.id}"
    }

    tags = {
        environment = "QCLUG"
    }
}


# Create virtual machine
resource "azurerm_virtual_machine" "qclug-vm-terraform-1" {
    name                  = "qclug-vm-terraform-1"
    location              = "northcentralus"
    resource_group_name   = "${azurerm_resource_group.qcluggroup.name}"
    network_interface_ids = ["${azurerm_network_interface.qclugnic.id}"]
    vm_size               = "Standard_B1ls"

    storage_os_disk {
        name              = "OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    os_profile {
        computer_name  = "qclug-vm-terraform-1"
        admin_username = "cschroeder"
        admin_password = ""
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "Terraform Demo"
    }
}
