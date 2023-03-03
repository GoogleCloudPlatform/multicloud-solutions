# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "azurerm_subnet" "az_gcp_gateway_subnet" {
  # azure requires this to be named 'GatewaySubnet'
  name                 = "GatewaySubnet"
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = var.azure_network_name
  address_prefixes     = [var.azure_gateway_cidr]
}

resource "azurerm_public_ip" "az_gcp_vpn_gateway_ip_1" {
  name                = "az-gcp-vpn-gateway-ip-1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "az_gcp_vpn_gateway_ip_2" {
  name                = "az-gcp-vpn-gateway-ip-2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "az_gcp_vpn_gateway" {
  # depends_on = [
  #   azurerm_subnet.az_gcp_gateway_subnet
  # ]
  name                = "az-gcp-vpn-gateway"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  sku                 = var.azure_gateway_sku
  type                = "Vpn"
  vpn_type            = "RouteBased"
  generation          = "Generation2"
  active_active       = true
  enable_bgp          = true


  bgp_settings {
    asn = var.azure_bgp_asn
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig1"
      apipa_addresses       = [var.azure_bgp_apipa_ip_1]
    }
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig2"
      apipa_addresses       = [var.azure_bgp_apipa_ip_2]
    }
  }

  ip_configuration {
    name                 = "vnetGatewayConfig1"
    subnet_id            = azurerm_subnet.az_gcp_gateway_subnet.id
    public_ip_address_id = azurerm_public_ip.az_gcp_vpn_gateway_ip_1.id
  }

  ip_configuration {
    name                 = "vnetGatewayConfig2"
    subnet_id            = azurerm_subnet.az_gcp_gateway_subnet.id
    public_ip_address_id = azurerm_public_ip.az_gcp_vpn_gateway_ip_2.id
  }
}


resource "azurerm_local_network_gateway" "az_gcp_local_gateway_1" {
  depends_on = [
    azurerm_virtual_network_gateway.az_gcp_vpn_gateway
  ]
  name                = "az-gcp-local-gateway-1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  gateway_address     = google_compute_ha_vpn_gateway.gcp_az_vpn_gateway.vpn_interfaces[0].ip_address
  bgp_settings {
    asn                 = google_compute_router.gcp_az_vpn_router.bgp[0].asn
    bgp_peering_address = var.gcp_bgp_apipa_ip_1
  }
}

resource "azurerm_local_network_gateway" "az_gcp_local_gateway_2" {
  depends_on = [
    azurerm_virtual_network_gateway.az_gcp_vpn_gateway
  ]
  name                = "az-gcp-local-gateway-2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  gateway_address     = google_compute_ha_vpn_gateway.gcp_az_vpn_gateway.vpn_interfaces[1].ip_address
  bgp_settings {
    asn                 = google_compute_router.gcp_az_vpn_router.bgp[0].asn
    bgp_peering_address = var.gcp_bgp_apipa_ip_2
  }
}

resource "azurerm_virtual_network_gateway_connection" "az_gcp_conn_1" {
  name                = "az-gcp-connection-1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  type                       = "IPsec"
  enable_bgp                 = true
  connection_protocol        = "IKEv2"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_gcp_vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_gcp_local_gateway_1.id
  shared_key                 = google_compute_vpn_tunnel.gcp_az_vpn_tunnel_1.shared_secret
}

resource "azurerm_virtual_network_gateway_connection" "az_gcp_conn_2" {
  name                = "az-gcp-connection-2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  type                       = "IPsec"
  enable_bgp                 = true
  connection_protocol        = "IKEv2"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_gcp_vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_gcp_local_gateway_2.id
  shared_key                 = google_compute_vpn_tunnel.gcp_az_vpn_tunnel_2.shared_secret
}
