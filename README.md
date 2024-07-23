# hafifot-root
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.113.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub_acr"></a> [hub\_acr](#module\_hub\_acr) | github.com/Noya50/hafifot-acr.git | main |
| <a name="module_hub_acr_private_dns_zone"></a> [hub\_acr\_private\_dns\_zone](#module\_hub\_acr\_private\_dns\_zone) | github.com/Noya50/hafifot-privateDnsZone.git | main |
| <a name="module_hub_default_subnet"></a> [hub\_default\_subnet](#module\_hub\_default\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_hub_firewall"></a> [hub\_firewall](#module\_hub\_firewall) | github.com/Noya50/hafifot-firewall.git | main |
| <a name="module_hub_firewall_management_subnet"></a> [hub\_firewall\_management\_subnet](#module\_hub\_firewall\_management\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_hub_firewall_subnet"></a> [hub\_firewall\_subnet](#module\_hub\_firewall\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_hub_gateway_subnet"></a> [hub\_gateway\_subnet](#module\_hub\_gateway\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_hub_monitor_peering"></a> [hub\_monitor\_peering](#module\_hub\_monitor\_peering) | github.com/Noya50/hafifot-networkPeering.git | n/a |
| <a name="module_hub_route_table"></a> [hub\_route\_table](#module\_hub\_route\_table) | github.com/Noya50/hafifot-routeTable.git | main |
| <a name="module_hub_vnet"></a> [hub\_vnet](#module\_hub\_vnet) | github.com/Noya50/hafifot-virtualNetwork.git | main |
| <a name="module_hub_vpnGateway"></a> [hub\_vpnGateway](#module\_hub\_vpnGateway) | github.com/Noya50/hafifot-vpnGateway.git | main |
| <a name="module_hub_work_peering"></a> [hub\_work\_peering](#module\_hub\_work\_peering) | github.com/Noya50/hafifot-networkPeering.git | n/a |
| <a name="module_log_analytics_workspace_diagnostic_setting"></a> [log\_analytics\_workspace\_diagnostic\_setting](#module\_log\_analytics\_workspace\_diagnostic\_setting) | github.com/Noya50/hafifot-diagnosticSetting.git | main |
| <a name="module_monitor_default_subnet"></a> [monitor\_default\_subnet](#module\_monitor\_default\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_monitor_linux_vm"></a> [monitor\_linux\_vm](#module\_monitor\_linux\_vm) | github.com/Noya50/hafifot-vm.git | main |
| <a name="module_monitor_route_table"></a> [monitor\_route\_table](#module\_monitor\_route\_table) | github.com/Noya50/hafifot-routeTable.git | main |
| <a name="module_monitor_vm_private_dns_zone"></a> [monitor\_vm\_private\_dns\_zone](#module\_monitor\_vm\_private\_dns\_zone) | github.com/Noya50/hafifot-privateDnsZone.git | main |
| <a name="module_monitor_vnet"></a> [monitor\_vnet](#module\_monitor\_vnet) | github.com/Noya50/hafifot-virtualNetwork.git | main |
| <a name="module_work_aks"></a> [work\_aks](#module\_work\_aks) | github.com/Noya50/hafifot-aks.git | main |
| <a name="module_work_default_subnet"></a> [work\_default\_subnet](#module\_work\_default\_subnet) | github.com/Noya50/hafifot-subnet.git | main |
| <a name="module_work_linux_vm"></a> [work\_linux\_vm](#module\_work\_linux\_vm) | git::https://github.com/Noya50/hafifot-vm.git | main |
| <a name="module_work_route_table"></a> [work\_route\_table](#module\_work\_route\_table) | github.com/Noya50/hafifot-routeTable.git | main |
| <a name="module_work_storageAccount"></a> [work\_storageAccount](#module\_work\_storageAccount) | git::https://github.com/Noya50/hafifot-storageAccount.git | main |
| <a name="module_work_vnet"></a> [work\_vnet](#module\_work\_vnet) | github.com/Noya50/hafifot-virtualNetwork.git | main |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.hub_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.monitor_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.work_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_issuer"></a> [aad\_issuer](#input\_aad\_issuer) | (Optional) The STS url for your tenant | `string` | n/a | yes |
| <a name="input_aad_tenant"></a> [aad\_tenant](#input\_aad\_tenant) | (Optional) AzureAD Tenant URL | `string` | n/a | yes |
| <a name="input_monitor_vm_password"></a> [monitor\_vm\_password](#input\_monitor\_vm\_password) | (Optional) Password for the monitor vm | `string` | n/a | yes |
| <a name="input_work_vm_password"></a> [work\_vm\_password](#input\_work\_vm\_password) | (Optional) Password for the work vm | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->