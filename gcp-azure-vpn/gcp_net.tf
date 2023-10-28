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

# Routing specs

resource "google_compute_router" "gcp_az_vpn_router" {
  name    = "gcp-az-vpn-router"
  network = var.gcp_network

  bgp {
    asn               = var.gcp_bgp_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    dynamic "advertised_ip_ranges" {
      for_each = toset(var.gcp_custom_advertised_ip_ranges)
      content {
        range = advertised_ip_ranges.key
      }
    }
  }
}

# VPN specs

resource "google_compute_ha_vpn_gateway" "gcp_az_vpn_gateway" {
  depends_on = [
    azurerm_virtual_network_gateway.az_gcp_vpn_gateway
  ]
  name    = "gcp-az-vpn-gateway"
  network = var.gcp_network
}

resource "google_compute_external_vpn_gateway" "gcp_az_ex_gateway" {
  depends_on = [
    azurerm_virtual_network_gateway.az_gcp_vpn_gateway
  ]
  name            = "gcp-az-vpn-ex-gateway"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  description     = "VPN gateway for AZ side"

  interface {
    id         = 0
    ip_address = azurerm_public_ip.az_gcp_vpn_gateway_ip_1.ip_address
  }

  interface {
    id         = 1
    ip_address = azurerm_public_ip.az_gcp_vpn_gateway_ip_2.ip_address
  }
}

resource "google_compute_vpn_tunnel" "gcp_az_vpn_tunnel_1" {
  name                            = "gcp-az-vpn-tunnel-1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp_az_vpn_gateway.self_link
  shared_secret                   = var.gcp_vpn_shared_secret
  peer_external_gateway           = google_compute_external_vpn_gateway.gcp_az_ex_gateway.self_link
  peer_external_gateway_interface = 0
  router                          = google_compute_router.gcp_az_vpn_router.name
  ike_version                     = 2
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "gcp_az_vpn_tunnel_2" {
  name                            = "gcp-az-vpn-tunnel-2"
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp_az_vpn_gateway.self_link
  shared_secret                   = var.gcp_vpn_shared_secret
  peer_external_gateway           = google_compute_external_vpn_gateway.gcp_az_ex_gateway.self_link
  peer_external_gateway_interface = 1
  router                          = google_compute_router.gcp_az_vpn_router.name
  ike_version                     = 2
  vpn_gateway_interface           = 1
}



resource "google_compute_router_interface" "gcp_az_int_1" {
  name       = "gcp-az-int-1"
  router     = google_compute_router.gcp_az_vpn_router.name
  ip_range   = "${var.gcp_bgp_apipa_ip_1}/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_az_vpn_tunnel_1.name
}

resource "google_compute_router_interface" "gcp_az_int_2" {
  name       = "gcp-az-int-2"
  router     = google_compute_router.gcp_az_vpn_router.name
  ip_range   = "${var.gcp_bgp_apipa_ip_2}/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_az_vpn_tunnel_2.name
}


resource "google_compute_router_peer" "gcp_az_peer_1" {
  name                      = "gcp-az-peer-1"
  router                    = google_compute_router.gcp_az_vpn_router.name
  peer_ip_address           = var.azure_bgp_apipa_ip_1
  peer_asn                  = var.azure_bgp_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.gcp_az_int_1.name
}

resource "google_compute_router_peer" "gcp_az_peer_2" {
  name                      = "gcp-az-peer-2"
  router                    = google_compute_router.gcp_az_vpn_router.name
  peer_ip_address           = var.azure_bgp_apipa_ip_2
  peer_asn                  = var.azure_bgp_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.gcp_az_int_2.name
}
