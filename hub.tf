resource "azurerm_resource_group" "hub_rg" {
  name     = local.hub_rg_name
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  vnet_name      = "hub-Vnet-tf"
  vnet_addresses = ["10.0.0.0/16"]
}

module "hub_vnet" {
  source = "github.com/Noya50/hafifot-virtualNetwork.git"

  name                = local.vnet_name
  location            = local.location
  resource_group_name = local.hub_rg_name
  address_space       = local.vnet_addresses
}

locals {
  default_subnet_name      = "subnet-default-hub-tf"
  default_subnet_addresses = ["10.0.0.0/24"]
  nsg_name                 = "network-security-group-hub-tf"
}

module "hub_default_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git"

  location                    = local.location
  resource_group_name         = local.hub_rg_name
  name                        = local.default_subnet_name
  vnet_name                   = module.hub_vnet.name
  subnet_address_prefixes     = local.default_subnet_addresses
  network_security_group_name = local.nsg_name
  log_analytics_workspace_id  = local.log_analytics_workspace_id
}

locals {
  management_subnet_name            = "AzureFirewallManagementSubnet"
  managment_subnet_address_prefixes = ["10.0.3.0/24"]
  managment_no_nsg_enabled          = true
}

module "hub_firewall_management_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git"

  name                    = local.management_subnet_name
  location                = local.location
  resource_group_name     = local.hub_rg_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.managment_subnet_address_prefixes
  no_nsg_enabled          = local.managment_no_nsg_enabled
}

locals {
  firewall_subnet_name               = "AzureFirewallSubnet"
  management_subnet_address_prefixes = ["10.0.1.0/26"]
  firewall_no_nsg_enabled            = true
}

module "hub_firewall_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git"

  location                = local.location
  resource_group_name     = local.hub_rg_name
  name                    = local.firewall_subnet_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.management_subnet_address_prefixes
  no_nsg_enabled          = local.firewall_no_nsg_enabled
}

locals {
  gateway_subnet_address_prefixes = ["10.0.2.0/24"]
  gateway_no_nsg_enabled          = true
  gateway_subnet_name             = "GatewaySubnet"
}

module "hub_gateway_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git"

  location                = local.location
  resource_group_name     = local.hub_rg_name
  name                    = local.gateway_subnet_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.gateway_subnet_address_prefixes
  no_nsg_enabled          = local.gateway_no_nsg_enabled
}

locals {
  hub_route_table_name = "noya-hub-route-table-tf"
  hub_routes = [
    {
      name                   = "work_to_firewall"
      address_prefix         = "10.3.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "monitor_to_firewall"
      address_prefix         = "10.7.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
  ]
}

module "hub_route_table" {
  source = "github.com/Noya50/hafifot-routeTable.git"

  name           = local.hub_route_table_name
  location       = local.location
  resource_group = local.hub_rg_name
  routes         = local.hub_routes
}

locals {
  vpnGateway_name                               = "vpn-gateway-hub-tf"
  vpnGateway_active_active                      = true
  vpn_client_configuration_address_space        = ["10.5.0.0/16"]
  vpn_client_configuration_vpn_auth_types       = ["AAD"]
  vpn_client_configuration_vpn_client_protocols = ["OpenVPN"]
  vpn_client_configuration_aad_tenant           = "https://login.microsoftonline.com/c9ad96a7-2bac-49a7-abf6-8e932f60bf2b/"
  aad_audience                                  = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
  aad_issuer                                    = "https://sts.windows.net/c9ad96a7-2bac-49a7-abf6-8e932f60bf2b/"
  gateway_subnet_id                             = module.hub_gateway_subnet.id
}

module "hub_vpnGateway" {
  source = "github.com/Noya50/hafifot-vpnGateway.git"

  location                                      = local.location
  resource_group                                = local.hub_rg_name
  subnet_id                                     = local.gateway_subnet_id
  vpnGateway_name                               = local.vpnGateway_name
  vpnGateway_active_active                      = local.vpnGateway_active_active
  vpn_client_configuration_address_space        = local.vpn_client_configuration_address_space
  vpn_client_configuration_vpn_auth_types       = local.vpn_client_configuration_vpn_auth_types
  vpn_client_configuration_vpn_client_protocols = local.vpn_client_configuration_vpn_client_protocols
  aad_tenant                                    = local.vpn_client_configuration_aad_tenant
  aad_audience                                  = local.aad_audience
  aad_issuer                                    = local.aad_issuer
  log_analytics_workspace_id                    = local.log_analytics_workspace_id
}

locals {
  policy_name                             = "noya-hub-firewall-policy-tf"
  management_subnet_id                    = module.hub_firewall_management_subnet.id
  firewall_subnet_id                      = module.hub_firewall_subnet.id
  firewall_name                           = "noya-hub-firewall-tf"
  firewall_pip_name                       = "noya-hub-firewall-pip-tf"
  firewall_pip_log_analytics_workspace_id = local.log_analytics_workspace_id
  json_path                               = ""
  # application_rules_map = jsondecode(file(local.json_path))["application_rules"]
  # application_rule_collections = [
  #   {
  #     name      = ""
  #     priority  = 0
  #     action    = ""
  #     rule = local.application_rules_map
  #   },
  # ]
}

module "hub_firewall" {
  source = "github.com/Noya50/hafifot-firewall.git"

  location                                = local.location
  resource_group                          = local.hub_rg_name
  vnet_name                               = module.hub_vnet.name
  policy_name                             = local.policy_name
  management_subnet_id                    = local.management_subnet_id
  firewall_subnet_id                      = local.firewall_subnet_id
  firewall_pip_name                       = local.firewall_pip_name
  firewall_name                           = local.firewall_name
  log_analytics_workspace_id              = local.log_analytics_workspace_id
  firewall_pip_log_analytics_workspace_id = local.firewall_pip_log_analytics_workspace_id
  is_force_tunneling_enabled              = true
}

locals {
  log_analytics_name = "noya-hub-logAnalyticsWorkspace-tf"
  log_analytics_sku  = "PerGB2018"
  retention_in_days  = 30
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_name
  location            = local.location
  resource_group_name = local.hub_rg_name
  sku                 = local.log_analytics_sku
  retention_in_days   = local.retention_in_days

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  log_analytics_workspace_diagnostic_setting_categories = ["Audit", "SummaryLogs"]
}

module "log_analytics_workspace_diagnostic_setting" {
  source = "github.com/Noya50/hafifot-diagnosticSetting.git"

  name                          = "${azurerm_log_analytics_workspace.this.name}-diagnostic-setting"
  target_resource_id            = azurerm_log_analytics_workspace.this.id
  log_analytics_workspace_id    = local.log_analytics_workspace_id
  diagnostic_setting_categories = local.log_analytics_workspace_diagnostic_setting_categories
}

locals {
  acr_name      = "noyaHubAcrTF"
  acr_sku       = "Premium"
  hub_subnet_id = module.hub_default_subnet
}

module "hub_acr" {
  source = "github.com/Noya50/hafifot-acr.git"

  location                   = local.location
  resource_group             = local.hub_rg_name
  name                       = local.acr_name
  sku                        = local.acr_sku
  log_analytics_workspace_id = local.log_analytics_workspace_id
  subnet_id                  = local.work_subnet_id
}

locals {
  hub_acr_dns_zone_name           = "noya.tf.hub"
  acr_dns_a_records_ips_and_names = { "acr" = ["${module.hub_acr.private_endpoint_private_ip}"], }
  acr_dns_a_records_ttl           = [300, ]
}

module "hub_acr_private_dns_zone" {
  source = "github.com/Noya50/hafifot-privateDnsZone.git"

  resource_group_name         = local.hub_rg_name
  private_dns_zone_name       = local.hub_acr_dns_zone_name
  dns_a_records_ips_and_names = local.acr_dns_a_records_ips_and_names
  dns_a_records_ttl           = local.acr_dns_a_records_ttl
}
