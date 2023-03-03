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

# data "aws_vpc" "aws_vpn_network" {
#   id = var.aws_vpc_id
# }

locals {
  route_vpc_transit = flatten([
    for route_id, cidr_blocks in var.aws_route_vpc_transit : [
      for cidr_block in cidr_blocks : {
        route_id   = route_id
        cidr_block = cidr_block
      }
    ]
  ])
}

data "aws_subnets" "aws_sub" {
  for_each = toset([for vpc, sub in var.aws_vpc_sub_ids : vpc if length(sub) == 0])
  filter {
    name   = "vpc-id"
    values = [each.key]
  }
}

resource "aws_ec2_transit_gateway" "vpn_transit_gateway" {
  description                     = "EC2 Transit Gateway"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  vpn_ecmp_support                = "enable"
  dns_support                     = "enable"
}

resource "aws_customer_gateway" "customer_gateway_1" {
  bgp_asn    = google_compute_router.vpn_router.bgp[0].asn
  ip_address = google_compute_ha_vpn_gateway.target_gateway.vpn_interfaces[0].ip_address
  type       = "ipsec.1"
}

resource "aws_customer_gateway" "customer_gateway_2" {
  bgp_asn    = google_compute_router.vpn_router.bgp[0].asn
  ip_address = google_compute_ha_vpn_gateway.target_gateway.vpn_interfaces[1].ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "cx_1" {
  transit_gateway_id  = aws_ec2_transit_gateway.vpn_transit_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_1.id
  type                = "ipsec.1"
}

resource "aws_vpn_connection" "cx_2" {
  transit_gateway_id  = aws_ec2_transit_gateway.vpn_transit_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_2.id
  type                = "ipsec.1"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_vpc_attach" {
  for_each           = var.aws_vpc_sub_ids
  subnet_ids         = length(each.value) == 0 ? data.aws_subnets.aws_sub[each.key].ids : each.value
  transit_gateway_id = aws_ec2_transit_gateway.vpn_transit_gateway.id
  vpc_id             = each.key
}


resource "aws_route" "gcp_route_entry" {
  for_each               = { for entry in local.route_vpc_transit : "${entry.route_id}.${entry.cidr_block}" => entry }
  route_table_id         = each.value.route_id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpn_transit_gateway.id
}
