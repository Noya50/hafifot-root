resource "azurerm_resource_group" "hub_rg" {
  name     = local.hub_rg_name
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  vnet_name      = "hub-Vnet-tf"
  vnet_addresses = ["${local.hub_ip_range}"]
}

module "hub_vnet" {
  source = "git::https://github.com/Noya50/hafifot-virtualNetwork.git?ref=main"

  name                       = local.vnet_name
  location                   = local.location
  resource_group_name        = local.hub_rg_name
  address_space              = local.vnet_addresses
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

locals {
  default_subnet_name      = "subnet-default-hub-tf"
  default_subnet_addresses = ["${local.hub_default_subnet_addresses}"]
  nsg_name                 = "network-security-group-hub-tf"
}

module "hub_default_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

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
  managment_subnet_address_prefixes = ["${local.firewall_managment_subnet}"]
  managment_no_nsg_enabled          = true
}

module "hub_firewall_management_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

  name                    = local.management_subnet_name
  location                = local.location
  resource_group_name     = local.hub_rg_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.managment_subnet_address_prefixes
  no_nsg_enabled          = local.managment_no_nsg_enabled
}

locals {
  firewall_subnet_name               = "AzureFirewallSubnet"
  management_subnet_address_prefixes = ["${local.firewall_subnet}"]
  firewall_no_nsg_enabled            = true
}

module "hub_firewall_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

  location                = local.location
  resource_group_name     = local.hub_rg_name
  name                    = local.firewall_subnet_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.management_subnet_address_prefixes
  no_nsg_enabled          = local.firewall_no_nsg_enabled
}

locals {
  gateway_subnet_address_prefixes = ["${local.gateway_subnet}"]
  gateway_no_nsg_enabled          = true
  gateway_subnet_name             = "GatewaySubnet"
}

module "hub_gateway_subnet" {
  source = "github.com/Noya50/hafifot-subnet.git?ref=main"

  location                = local.location
  resource_group_name     = local.hub_rg_name
  name                    = local.gateway_subnet_name
  vnet_name               = module.hub_vnet.name
  subnet_address_prefixes = local.gateway_subnet_address_prefixes
  no_nsg_enabled          = local.gateway_no_nsg_enabled
}

locals {
  hub_route_table_name = "noya-hub-route-table-tf"
  hub_routes_json_path = "C:/Users/sysadmin7/Desktop/hafifot-root/ruteTablesRules/hubRouteTable.json"
  hub_routes_json_inputs = templatefile("${local.hub_routes_json_path}", {
    work_ip_range        = local.work_ip_range
    monitor_ip_range = local.monitor_ip_range
    firewall_private_ip = local.firewall_private_ip
  })
  hub_routes_map       = tomap(jsondecode(local.hub_routes_json_inputs))
}

module "hub_route_table" {
  source = "github.com/Noya50/hafifot-routeTable.git?ref=main"

  name           = local.hub_route_table_name
  location       = local.location
  resource_group = local.hub_rg_name
  routes         = local.hub_routes_map
}

resource "azurerm_subnet_route_table_association" "default" {
  subnet_id      = module.hub_default_subnet.id
  route_table_id = module.hub_route_table.id
}

resource "azurerm_subnet_route_table_association" "vpn_subnet" {
  subnet_id      = module.hub_gateway_subnet.id
  route_table_id = module.hub_route_table.id
}

locals {
  vpnGateway_name                               = "vpn-gateway-hub-tf"
  vpnGateway_active_active                      = true
  client_configuration_address_space        = ["${local.vpn_client_configuration_address_space}"]
  vpn_client_configuration_vpn_auth_types       = ["AAD"]
  vpn_client_configuration_vpn_client_protocols = ["OpenVPN"]
  vpn_client_configuration_aad_tenant           = var.aad_tenant
  aad_audience                                  = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
  aad_issuer                                    = var.aad_issuer
  gateway_subnet_id                             = module.hub_gateway_subnet.id
}

module "hub_vpnGateway" {
  source = "github.com/Noya50/hafifot-vpnGateway.git?ref=main"

  location                                      = local.location
  resource_group                                = local.hub_rg_name
  subnet_id                                     = local.gateway_subnet_id
  vpnGateway_name                               = local.vpnGateway_name
  vpnGateway_active_active                      = local.vpnGateway_active_active
  vpn_client_configuration_address_space        = local.client_configuration_address_space
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
  allow_network_rules_json_path           = "C:/Users/sysadmin7/Desktop/hafifot-root/firewallPoliciesRules/policyNetRulesAllow.json"
  allow_network_rules_json_inputs = templatefile("${local.allow_network_rules_json_path}", {
    work_ip_range        = local.work_ip_range
    monitor_ip_range = local.monitor_ip_range
    hub_ip_range = local.hub_ip_range
    vpn_client_configuration_address_space = local.vpn_client_configuration_address_space
    vpn_client_subnet = local.vpn_client_subnet
    vpn_client_subnet2 = local.vpn_client_subnet2
    work_vm_private_ip = local.work_vm_private_ip
    firewall_private_ip = local.firewall_private_ip 
  })
  allow_network_rules_map                 = tomap(jsondecode(local.allow_network_rules_json_inputs))
  deny_network_rules_json_path            = "C:/Users/sysadmin7/Desktop/hafifot-root/firewallPoliciesRules/policyNetRulesDeny.json"
  deny_network_rules_json_inputs = templatefile("${local.deny_network_rules_json_path}", {
    work_vm_private_ip        = local.work_vm_private_ip
  })
  deny_network_rules_map                  = tomap(jsondecode(local.deny_network_rules_json_inputs))
  network_rule_collections = tolist(tolist([
    {
      name     = "allow"
      priority = 400
      action   = "Allow"
      rule     = local.allow_network_rules_map
    },
    {
      name     = "deny"
      priority = 380
      action   = "Deny"
      rule     = local.deny_network_rules_map
    }
  ]))
  application_rules_json_path = "C:/Users/sysadmin7/Desktop/hafifot-root/firewallPoliciesRules/policyAppRulesAllow.json"
  application_rules_json_inputs = templatefile("${local.application_rules_json_path}", {
    work_ip_range = local.work_ip_range
    monitor_ip_range = local.monitor_ip_range
  })
  application_rules_map       = tomap(jsondecode(local.application_rules_json_inputs))
  application_rule_collections = [
    {
      name     = "application-allow"
      priority = 420
      action   = "Allow"
      rule     = local.application_rules_map
    },
  ]
}

module "hub_firewall" {
  source = "github.com/Noya50/hafifot-firewall.git?ref=main"

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
  rule_collection_group_priority          = 100
  network_rule_collections                = local.network_rule_collections
  application_rule_collections            = local.application_rule_collections
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
  source = "github.com/Noya50/hafifot-diagnosticSetting.git?ref=main"

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
  source = "github.com/Noya50/hafifot-acr.git?ref=main"

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
  source = "github.com/Noya50/hafifot-privateDnsZone.git?ref=main"

  resource_group_name         = local.hub_rg_name
  private_dns_zone_name       = local.hub_acr_dns_zone_name
  dns_a_records_ips_and_names = local.acr_dns_a_records_ips_and_names
  dns_a_records_ttl           = local.acr_dns_a_records_ttl
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_zone_to_work_vnet" {
  name                  = "work-vnet"
  resource_group_name   = local.hub_rg_name
  private_dns_zone_name = module.hub_acr_private_dns_zone.name
  virtual_network_id    = module.work_vnet.id

  lifecycle {
    ignore_changes = [tags]
  }
}
