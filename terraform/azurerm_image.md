````markdown
# Using Platform and Custom Images in Azure with Terraform

## 1. Using a Platform Image
For platform images, you specify the image by its **publisher**, **offer**, **sku**, and **version**.  
The version can often be set to `"latest"` to automatically use the most recent version available.

```hcl
resource "azurerm_linux_virtual_machine" "example" {
  // ... other configurations ...

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  // ... other configurations ...
}
````

---

## 2. Using a Custom Image

If you are using a custom image, you would reference its ID using `source_image_id`.
This ID could refer to:

* a **Managed Image**
* a **Shared Image Gallery Image**
* a **Shared Image Gallery Image Version**

```hcl
resource "azurerm_windows_virtual_machine" "example" {
  // ... other configurations ...

  source_image_id = azurerm_shared_image_version.my_image_version.id 
  # Or: azurerm_image.my_custom_image.id

  // ... other configurations ...
}
```

---

## 🔑 Key Considerations

* **Platform Images**: Provide a quick way to deploy standard operating systems.
* **Custom Images**: Offer more control and allow you to deploy VMs with pre-configured software or specific settings.
  They are often used in conjunction with **Azure Compute Gallery** (formerly Shared Image Gallery) for centralized image management and distribution.
* **`source_image_id` vs. `source_image_reference`**: You must choose **one or the other** within the virtual machine resource.
  You cannot use both simultaneously.
