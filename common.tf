module "ipam" {
  source = "git::https://github.com/Noya50/IPAM.git?ref=main"
}

locals {
  hub_rg_name                            = "noya-hub-rg-tf"
  work_rg_name                           = "noya-work-rg-tf"
  monitor_rg_name                        = "noya-monitor-rg-tf"
  location                               = "westeurope"
  log_analytics_workspace_id             = azurerm_log_analytics_workspace.this.id
  hub_ip_range                           = module.ipam.hub_vnet_addrs
  work_ip_range                          = module.ipam.work_vnet_addrs
  monitor_ip_range                       = module.ipam.monitor_vnet_addrs
  monitor_default_subnet_addrs           = module.ipam.monitor_default_subnet_addrs
  hub_default_subnet_addrs               = module.ipam.hub_default_subnet_addrs
  work_default_subnet_addrs              = module.ipam.work_default_subnet_addrs
  firewall_managment_subnet_addrs              = module.ipam.firewall_managment_subnet_addrs
  firewall_subnet_addrs                        = module.ipam.firewall_subnet_addrs
  gateway_subnet_addrs                         = module.ipam.gateway_subnet_addrs
  vpn_client_addrs = module.ipam.vpn_client_addrs
  vpn_client_subnet_addrs                      = module.ipam.vpn_client_subnet_addrs
  vpn_client_subnet2_addrs                     = module.ipam.vpn_client_subnet2_addrs
  firewall_private_ip                    = module.ipam.firewall_private_ip
  work_vm_private_ip                     = module.ipam.work_vm_private_ip
  storage_account_private_ip             = module.ipam.storage_account_private_ip
  internet = module.ipam.internet
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
