terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.88.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = "1c136c9f-71a7-4e24-b57e-47c93b6f5c43"
  client_secret   = "e3Z8Q~wn2rYYJZdNM-i~ntOrEyMHj8zpHvKB5a~-"
  tenant_id       = "7349d3b2-951f-41be-877e-d8ccd9f3e73c"
  subscription_id = "393e3de3-0900-4b72-8f1b-fb3b1d6b97f1"

}




resource "azurerm_resource_group" "webserver" {
   name = "terraform_jenkins_lylla"
   location = var.location
}

resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports"
   resource_group_name = azurerm_resource_group.webserver.name
   location = azurerm_resource_group.webserver.location
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "81"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
}

resource "azurerm_public_ip" "webserver_public_ip" {
   name = "webserver_public_ip"
   location = var.location
   resource_group_name = azurerm_resource_group.webserver.name
   allocation_method = "Dynamic"

   tags = {
       environment = var.environment
       costcenter = "it"
   }

   depends_on = [azurerm_resource_group.webserver]
}

resource "azurerm_network_interface" "webserver" {
   name = "nginx-interface"
   location = azurerm_resource_group.webserver.location
   resource_group_name = azurerm_resource_group.webserver.name

   ip_configuration {
       name = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id = azurerm_subnet.webserver-subnet.id
       public_ip_address_id = azurerm_public_ip.webserver_public_ip.id
   }

   depends_on = [azurerm_resource_group.webserver]
}

resource "azurerm_linux_virtual_machine" "nginx" {
   size = var.instance_size
   name = "nginx-webserver"
   resource_group_name = azurerm_resource_group.webserver.name
   location = azurerm_resource_group.webserver.location
   custom_data = base64encode(file("init-script.sh"))
   network_interface_ids = [
       azurerm_network_interface.webserver.id,
   ]

   source_image_reference {
       publisher = "Canonical"
       offer = "UbuntuServer"
       sku = "18.04-LTS"
       version = "latest"
   }

   computer_name = "nginx"
   admin_username = "lylla"
   admin_password = "Jevis@ambronay"
   disable_password_authentication = false

   os_disk {
       name = "nginxdisk01"
       caching = "ReadWrite"
       #create_option = "FromImage"
       storage_account_type = "Standard_LRS"
   }

variable "subscription_id" {
   description = "Azure subscription"
   default = "393e3de3-0900-4b72-8f1b-fb3b1d6b97f1"
}

#variable "client_id" {
#   description = "Azure Client ID"
#   default = "384ba4e4-fc1a-47f4-bf42-acec6fad1e82"
#}

#variable "client_secret" {
#   description = "Azure Client Secret"
#   default = "lxk8Q~LfBuObGY4frVfc6B_e4Nqf6UMahS-BdaD-"
#}

variable "tenant_id" {
   description = "Azure Tenant ID"
   default = "7349d3b2-951f-41be-877e-d8ccd9f3e73c"
}

variable "instance_size" {
   type = string
   description = "Azure instance size"
   default = "Standard_F2"
}

variable "location" {
   type = string
   description = "Region"
   default = "West Europe"
}

variable "environment" {
   type = string
   description = "Environment"
   default = "dev"
}
   
   depends_on = [azurerm_resource_group.webserver]
}