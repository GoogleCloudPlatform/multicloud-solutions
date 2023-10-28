# Terraform to build Classic VPN connections between Google Cloud and AWS

**Disclaimer**: This interoperability terraform setup is intended to be minimal in
nature with less user input and auto public ip and shared key creation. Users should verify and modify configuration accordingly.

## Before you begin
1.  Go through steps to create [GCP classic VPN setup](https://cloud.google.com/network-connectivity/docs/vpn/tutorials/configure-vpn-between-onprem-cloud)
2.  Review information about how
    [static routing](https://cloud.google.com/network-connectivity/docs/vpn/concepts/choosing-networks-routing#static-routing)
    works in Google Cloud.

## Assumption

1.  Required Administrative role is assigned to respective user (which will be used to run terraform) on [GCP](https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns#expandable-1) and AWS
1.  VPC and subnets is already created at GCP and AWS
1.  GCP firewall rule must be added for traffic flow (ingress and egress) between aws and gcp
1.  AWS security group and route table modification for traffic flow and subnet propagation

## Terraform variables and values

Modify below variables in terraform.tfvars according to your setup

| variable           | Description                                                                                                                             | Required | Default |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| gcp_project_id     | gcp project ID.                                                                                                                         | yes      |         |
| gcp_region         | gcp region of cloud router and vpn setup                                                                                                | yes      |         |
| gcp_network        | gcp VPC network name                                                                                                                    | yes      |         |
| aws_bgp_asn        | aws router bgp ASN                                                                                                                      | yes      | "65000" |
| aws_vpc_id         | aws vpc ID                                                                                                                              | yes      |         |
| aws_region         | aws region                                                                                                                              | yes      |         |
| aws_route_table_id | aws route table ID which will be used to propagate vpn gateway to subnets, if left empty propagation will not be enabled on any subnets | no       | ""      |
| aws_routes_in_gcp  | aws static routes in gcp                                                                                                                | no       | []      |
| gcp_routes_in_aws  | gcp static routes in aws                                                                                                                | no       | []      |

## High-level configuration steps

you must configure Cloud VPN and AWS components in the following sequence:

1.  Create the Classic VPN gateway.
2.  Create AWS virtual private gateways.
3.  Create one AWS site-to-site VPN connections and customer gateways.
4.  Create one VPN tunnels on the Classic VPN gateway.
5.  Configure routes on both GCP and AWS to propogate each others vpc/subnet ranges.

AWS terminology and the AWS logo are trademarks of Amazon Web Services or its affiliates in the United States and/or other countries.

## Terminology
Learn how to build site-to-site IPSec VPNs between [Classic VPN](https://cloud.google.com/network-connectivity/docs/vpn/) on Google Cloud and AWS.

## Topology

![Topology diagram](https://cloud.google.com/static/network-connectivity/docs/vpn/images/cloud-vpn-overview-01.svg)


