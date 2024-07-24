resource "azurerm_resource_group" "work_rg" {
  name     = local.work_rg_name
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  work_vnet_name      = "work-Vnet-tf"
  work_vnet_addresses = ["10.3.0.0/16"]
}

module "work_vnet" {
  source = "git::https://github.com/Noya50/hafifot-virtualNetwork.git?ref=main"

  name                       = local.work_vnet_name
  location                   = local.location
  resource_group_name        = local.work_rg_name
  address_space              = local.work_vnet_addresses
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

locals {
  work_nsg_name                 = "network-security-group-work-tf"
  work_default_subnet_name      = "subnet-default-work-tf"
  work_default_subnet_addresses = ["10.3.0.0/24"]
}

module "work_default_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

  location                    = local.location
  resource_group_name         = local.work_rg_name
  name                        = local.work_default_subnet_name
  vnet_name                   = module.work_vnet.name
  subnet_address_prefixes     = local.work_default_subnet_addresses
  network_security_group_name = local.work_nsg_name
  log_analytics_workspace_id  = local.log_analytics_workspace_id
}

locals {
  work_route_table_name = "noya-work-route-table-tf"
  work_routes = [
    {
      name                   = "hub_to_firewall"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "work_to_firewall"
      address_prefix         = "10.3.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "VPN_to_firewall"
      address_prefix         = "10.5.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "vpn_subnet_to_firewall"
      address_prefix         = "10.5.128.0/17"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "vpn_subnet2_to_firewall"
      address_prefix         = "10.5.0.0/17"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
  ]
}

module "work_route_table" {
  source = "github.com/Noya50/hafifot-routeTable.git?ref=main"

  name           = local.work_route_table_name
  location       = local.location
  resource_group = local.work_rg_name
  routes         = local.work_routes
}

resource "azurerm_subnet_route_table_association" "work_default" {
  subnet_id      = module.work_default_subnet.id
  route_table_id = module.work_route_table.id
}

locals {
  cluster_name   = "noya-work-aks"
  aks_dns_prefix = "noyawork-aks"
}

module "work_aks" {
  source = "github.com/Noya50/hafifot-aks.git?ref=main"

  cluster_name               = local.cluster_name
  location                   = local.location
  resource_group_name        = local.work_rg_name
  dns_prefix                 = local.aks_dns_prefix
  acr_id                     = module.hub_acr.id
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

locals {
  sa_name        = "noyastorageaccounttf"
  sa_tier        = "Standard"
  work_subnet_id = module.work_default_subnet.id
}

module "work_storageAccount" {
  source = "git::https://github.com/Noya50/hafifot-storageAccount.git?ref=main"

  storageAccount_name        = local.sa_name
  resource_group             = local.work_rg_name
  location                   = local.location
  log_analytics_workspace_id = local.log_analytics_workspace_id
  subnet_id                  = local.work_subnet_id
}

locals {
  vm_name    = "noya-work-vm-tf"
  username   = "azureuser"
  password   = var.work_vm_password
  work_vm_os = "linux"
}

module "work_linux_vm" {
  source = "git::https://github.com/Noya50/hafifot-vm.git?ref=main"

  subnet_id                  = module.work_default_subnet.id
  vm_name                    = local.vm_name
  resource_group_name        = local.work_rg_name
  location                   = local.location
  admin_username             = local.username
  admin_password             = local.password
  os                         = local.work_vm_os
  log_analytics_workspace_id = local.log_analytics_workspace_id
}
