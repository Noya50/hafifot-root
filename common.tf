locals {
  hub_rg_name                = "noya-hub-rg-tf"
  work_rg_name               = "noya-work-rg-tf"
  monitor_rg_name            = "noya-monitor-rg-tf"
  location                   = "westeurope"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
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
