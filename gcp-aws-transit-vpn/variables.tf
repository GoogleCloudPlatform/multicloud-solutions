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

# GCP Vars

variable "gcp_network" {
  description = "gcp VPC network name."
  type        = string
}

variable "gcp_bgp" {
  description = "gcp router bgp ASN"
  default     = "65273"
}

variable "gcp_project_id" {
  description = "gcp project ID."
  type        = string
}

variable "gcp_region" {
  description = "gcp region."
  type        = string
}

# AWS Vars

variable "aws_region" {
  description = "aws region."
  type        = string
}

variable "aws_transit_vpc_sub_ids" {
  description = "aws VPC ID as key and value as list of subnets that will be attached to transit gateway"
  type        = map(list(string))
  default     = {}
}
# Empty List means all subnets of VPC will be attached
# aws_transit_vpc_sub_ids = {
#   "vpc-0b6a65e12dfb822a9" : [],
#   "vpc-0b22876061d7b8feb" : ["subnet-0900912f20eb98154"]
# }

variable "aws_route_vpc_transit" {
  description = "aws VPC route table ID as key and value as list of gcp cidr ranges that will be forwarded to transit gateway"
  type        = map(list(string))
  default     = {}
}

# aws_route_vpc_transit = {
#   "rtb-040f52217e2ea1803" : ["10.3.0.0/24"],
#   "rtb-02d65dbbef209edb8" : ["10.3.0.0/24"]
# }

variable "gcp_custom_advertised_ip_ranges" {
  description = "GCP custom ip ranges that will be advertised at aws side, use for peered network, dns forwarding, PGA"
  type        = list(string)
  default     = []
}
