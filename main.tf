provider "azurerm" {
features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "poc" {
  name     = "POC_RG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "poc" {
  name                = "POC_VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.poc.location
  resource_group_name = azurerm_resource_group.poc.name
}

resource "azurerm_subnet" "poc" {
  name                 = "POC_subnet"
  resource_group_name  = azurerm_resource_group.poc.name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "poc" {
  name                      = "poc-nic"
  location                  = azurerm_resource_group.poc.location
  resource_group_name       = azurerm_resource_group.poc.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.poc.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "poc" {
  name                  = "POC_VM"
  location              = azurerm_resource_group.poc.location
  resource_group_name   = azurerm_resource_group.poc.name
  network_interface_ids = [azurerm_network_interface.poc.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "poc-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "boluwatife"
    admin_username = "boluwatife"
    admin_password = "dammy@12345" // Use a more secure method like Azure Key Vault in production
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
