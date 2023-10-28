/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.aws_vpc_id
}

resource "aws_customer_gateway" "customer_gateway_1" {
  bgp_asn    = var.aws_bgp_asn
  ip_address = google_compute_address.vpn_static_ip.address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "cx_1" {
  vpn_gateway_id       = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id  = aws_customer_gateway.customer_gateway_1.id
  type                 = "ipsec.1"
  static_routes_only   = true
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]
}

resource "aws_vpn_connection_route" "gcp_route" {
  for_each               = toset(var.gcp_routes_in_aws)
  destination_cidr_block = each.key
  vpn_connection_id      = aws_vpn_connection.cx_1.id
}

resource "aws_vpn_gateway_route_propagation" "vpn_propagation" {
  count          = var.aws_route_table_id != "" ? 1 : 0
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
  route_table_id = var.aws_route_table_id
}
