resource "azurerm_resource_group" "p2-rg" {
  name     = "project2-resource-group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "p2-vnet" {
  name                = "project2-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.p2-rg.location
  resource_group_name = azurerm_resource_group.p2-rg.name
}

resource "azurerm_subnet" "sub-net" {
  name                 = "project2-subnet"
  resource_group_name  = azurerm_resource_group.p2-rg.name
  virtual_network_name = azurerm_virtual_network.p2-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#---------------------
# Public IP
#---------------------
resource "azurerm_public_ip" "pip" {
  name = "p2-pip"
  location = azurerm_resource_group.p2-rg.location
  resource_group_name = azurerm_resource_group.p2-rg.name
  allocation_method = "Static"
  # Stock Keeping Unit(sku):-> It’s basically the pricing tier or performance level of a resource.
  sku = "Standard"
  domain_name_label = "p2-devops-iac-terraform-packer" # must be globally unique

}

resource "azurerm_network_interface" "net-inter" {
  name                = "project2-network-interface"
  location            = azurerm_resource_group.p2-rg.location
  resource_group_name = azurerm_resource_group.p2-rg.name

  ip_configuration {
    name                          = "p2-ipconfig"
    subnet_id                     = azurerm_subnet.sub-net.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
# ---------------------------------------
## GET THE CUSTOM IMAGE CREATED BY PACKER
# ---------------------------------------
data "azurerm_image" "customngnix" {
  name                = "linuxWebServer-0.0.1"
  resource_group_name = "rg_images"
}



resource "azurerm_linux_virtual_machine" "vm" {
  name                = "mk2"
  resource_group_name = azurerm_resource_group.p2-rg.name
  location            = azurerm_resource_group.p2-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.net-inter.id,
  ]
   # Disable password Auth
  disable_password_authentication = true

   # SSH Key Authentication
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/Downloads/testMk1_key.pem") # path to your public key
  }
  
  ## USE THE CUSTOM IMAGE
  source_image_id = data.azurerm_image.customngnix

  os_disk {
    name = "mk2-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24.04-LTS"
    version   = "latest"
  }
}

#---------------------------------------------------------
#|  After terraform apply, run:                          |
#|  ---->ssh admin@$(terraform output -raw vm_public_ip) |
#---------------------------------------------------------
