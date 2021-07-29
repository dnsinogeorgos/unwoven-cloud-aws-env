aws_region = "eu-central-1"

environment    = "example"
vpc_cidr_block = "10.0.0.0/16"

single_nat_gateway     = true
one_nat_gateway_per_az = false
amazon_side_asn        = "64512"
customer_gateways      = {}
customer_gateway_tags  = {}

cluster_enabled_log_types = []
node_groups = {
  small = {
    min_capacity     = 1
    desired_capacity = 3 # changes to this are ignored in the module
    max_capacity     = 3

    instance_types = ["t3.small"]
    k8s_labels = {
      Environment = "example"
      NodeClass   = "small"
    }
    additional_tags = {
      ExtraTag = "small"
    }
  },
}
