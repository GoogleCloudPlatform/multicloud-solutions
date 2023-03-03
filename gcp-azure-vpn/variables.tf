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

# AWS Vars

variable "azure_resource_group_name" {
  description = "azure resource group name"
}

variable "azure_location" {
  description = "azure location"
}

variable "azure_network_name" {
  description = "azure virtual network name"
}

variable "azure_gateway_cidr" {
  description = "Azure VPN gateway CIDR"
}

variable "azure_gateway_sku" {
  description = "azure vpn gateway"
  default     = "VpnGw2"
}

variable "azure_bgp_asn" {
  description = "azure BGP ASN"
  default     = "65515"
}

# GCP Vars

variable "gcp_project_id" {
  description = "gcp Project ID."
  type        = string
}

variable "gcp_region" {
  description = "gcp region."
  type        = string
}

variable "gcp_network" {
  description = "Network name of VPC"
}

variable "gcp_bgp_asn" {
  description = "gcp router bgp ASN"
  default     = "64512"
}

variable "gcp_vpn_shared_secret" {
  description = "gcp region."
  default     = "gcpazshared123"
}

# BGP APIPA IP

variable "gcp_bgp_apipa_ip_1" {
  default = "169.254.21.2"
}

variable "gcp_bgp_apipa_ip_2" {
  default = "169.254.22.2"
}

variable "azure_bgp_apipa_ip_1" {
  default = "169.254.21.1"
}

variable "azure_bgp_apipa_ip_2" {
  default = "169.254.22.1"
}
