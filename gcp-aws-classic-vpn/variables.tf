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


variable "gcp_project_id" {
  description = "gcp project ID."
  type        = string
}

variable "gcp_region" {
  description = "gcp region."
  type        = string
}

# AWS Vars

variable "aws_vpc_id" {
  description = "aws VPC ID."
  type        = string
}

variable "aws_region" {
  description = "aws region."
  type        = string
}

variable "aws_route_table_id" {
  description = "aws route table ID."
  type        = string
  default     = ""
}

variable "aws_bgp_asn" {
  description = "aws bgp asn"
  type        = number
  default     = 65000
}

variable "aws_routes_in_gcp" {
  description = "aws static routes in GCP"
  type        = list(string)
  default     = []
}


variable "gcp_routes_in_aws" {
  description = "GCP static routes in aws"
  type        = list(string)
  default     = []
}
