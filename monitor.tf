resource "azurerm_resource_group" "monitor_rg" {
  name     = local.monitor_rg_name
  location = local.location

  lifecycle {
    ignore_changes = [tags, ]
  }
}

locals {
  monitor_vnet_name      = "monitor-vnet-tf"
  monitor_vnet_addresses = ["10.7.0.0/16"]
}

module "monitor_vnet" {
  source = "git::https://github.com/Noya50/hafifot-virtualNetwork.git?ref=main"

  name                       = local.monitor_vnet_name
  location                   = local.location
  resource_group_name        = local.monitor_rg_name
  address_space              = local.monitor_vnet_addresses
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

locals {
  monitor_nsg_name                 = "network-security-group-monitor-tf"
  monitor_default_subnet_name      = "subnet-default-monitor-tf"
  monitor_default_subnet_addresses = ["10.7.0.0/24"]
}

module "monitor_default_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

  location                    = local.location
  resource_group_name         = local.monitor_rg_name
  name                        = local.monitor_default_subnet_name
  vnet_name                   = module.monitor_vnet.name
  subnet_address_prefixes     = local.monitor_default_subnet_addresses
  network_security_group_name = local.monitor_nsg_name
  log_analytics_workspace_id  = local.log_analytics_workspace_id
}

locals {
  monitor_route_table_name = "noya-monitor-route-table-tf"
  monitor_routes = [
    {
      name                   = "hub_to_firewall"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "monitor_to_firewall"
      address_prefix         = "10.7.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "vpn_to_firewall"
      address_prefix         = "10.5.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "vpn_subnet_to_firewall"
      address_prefix         = "10.5.0.0/17"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "vpn_subnet2_to_firewall"
      address_prefix         = "10.5.128.0/17"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
  ]
}

module "monitor_route_table" {
  source = "github.com/Noya50/hafifot-routeTable.git?ref=main"

  name           = local.monitor_route_table_name
  location       = local.location
  resource_group = local.monitor_rg_name
  routes         = local.monitor_routes
}

resource "azurerm_subnet_route_table_association" "monitor_default" {
  subnet_id      = module.monitor_default_subnet.id
  route_table_id = module.monitor_route_table.id
}

locals {
  monitor_vm_name           = "noya-monitor-vm-tf"
  monitor_vm_admin_username = "azureuser"
  monitor_vm_admin_password = var.monitor_vm_password
  monitor_os                = "linux"
}

module "monitor_linux_vm" {
  source = "github.com/Noya50/hafifot-vm.git?ref=main"

  subnet_id                  = module.monitor_default_subnet.id
  vm_name                    = local.monitor_vm_name
  resource_group_name        = local.monitor_rg_name
  location                   = local.location
  admin_username             = local.monitor_vm_admin_username
  admin_password             = local.monitor_vm_admin_password
  os                         = local.monitor_os
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

locals {
  monitor_private_dns_zone_name       = "noya.tf.monitor"
  monitor_dns_a_records_ips_and_names = { "grafana-vm" = ["${module.monitor_linux_vm.vm_private_ip}"] }
  monitor_dns_a_records_ttl           = [300, ]
}

module "monitor_vm_private_dns_zone" {
  source = "github.com/Noya50/hafifot-privateDnsZone.git?ref=main"

  resource_group_name         = local.monitor_rg_name
  private_dns_zone_name       = local.monitor_private_dns_zone_name
  dns_a_records_ips_and_names = local.monitor_dns_a_records_ips_and_names
  dns_a_records_ttl           = local.monitor_dns_a_records_ttl
}
