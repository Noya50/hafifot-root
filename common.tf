module "common_ip_addresses" {
  source = "git::https://github.com/Noya50/IPAM.git?ref=main"
}

locals {
  hub_rg_name                = "noya-hub-rg-tf"
  work_rg_name               = "noya-work-rg-tf"
  monitor_rg_name            = "noya-monitor-rg-tf"
  location                   = "westeurope"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  hub_ip_range               = module.common_ip_addresses.hub_vnet_ip_range
  work_ip_range              = module.common_ip_addresses.work_vnet_ip_range
  monitor_ip_range           = module.common_ip_addresses.monitor_vnet_ip_range
  monitor_default_subnet_addresses = module.common_ip_addresses.monitor_default_subnet_addresses
  hub_default_subnet_addresses = module.common_ip_addresses.hub_default_subnet_addresses
  work_default_subnet_addresses = module.common_ip_addresses.work_default_subnet_addresses 
  firewall_managment_subnet = module.common_ip_addresses.firewall_managment_subnet
  firewall_subnet = module.common_ip_addresses.firewall_subnet
  gateway_subnet = module.common_ip_addresses.gateway_subnet
  vpn_client_configuration_address_space = module.common_ip_addresses.vpn_client_configuration_address_space
  vpn_client_subnet =  module.common_ip_addresses.vpn_client_subnet
  vpn_client_subnet2 = module.common_ip_addresses.vpn_client_subnet2
  firewall_private_ip = module.common_ip_addresses.firewall_private_ip
  work_vm_private_ip =  module.common_ip_addresses.work_vm_private_ip
}

module "hub_work_peering" {
  source = "github.com/Noya50/hafifot-networkPeering.git"

  resource_group_vnet       = "noya-hub-rg-tf"
  resource_group_remotevnet = "noya-work-rg-tf"
  peering_name_local        = "noya-hub-work-peering-tf"
  peering_name_remote       = "noya-work-hub-peering-tf"
  vnet_name                 = module.hub_vnet.name
  vnet_id                   = module.hub_vnet.id
  remote_vnet_name          = module.work_vnet.name
  remote_vnet_id            = module.work_vnet.id
}

module "hub_monitor_peering" {
  source = "github.com/Noya50/hafifot-networkPeering.git"

  resource_group_vnet       = "noya-hub-rg-tf"
  resource_group_remotevnet = "noya-monitor-rg-tf"
  peering_name_local        = "noya-ub-monitor-peering-tf"
  peering_name_remote       = "noya-monitor-hub-peering-tf"
  vnet_name                 = module.hub_vnet.name
  vnet_id                   = module.hub_vnet.id
  remote_vnet_name          = module.monitor_vnet.name
  remote_vnet_id            = module.monitor_vnet.id
}
