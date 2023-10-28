gcp_project_id = "gcp-project-id"
gcp_network    = "gcp-vpc"
gcp_region     = "us-west1"
aws_region     = "us-west-2"
aws_transit_vpc_sub_ids = {
  "vpc-3s3w" : [],
  "vpc-3sd3" : ["subnet-2s2"]
}
aws_route_vpc_transit = {
  "rtb-040f52217e2ea1803" : ["10.0.0.0/24"],
  "rtb-02d65dbbef209edb8" : ["10.0.0.0/24","10.1.0.0/24"]
}
