# provider
aws_region = "eu-central-1"

# remote state
aws-org_bucket = "unwoven-state"
aws-org_key    = "aws-org"
aws-org_region = "eu-central-1"

# env
environment    = "dev"
vpc_cidr_block = "172.20.0.0/16"

single_nat_gateway     = true
one_nat_gateway_per_az = false

cluster_enabled_log_types = []
node_groups = {
  small = {
    min_capacity     = 1
    desired_capacity = 3 # changes to this are ignored in the module
    max_capacity     = 3

    instance_types = ["t3.small"]
    k8s_labels = {
      Environment = "dev"
      NodeClass   = "small"
    }
    additional_tags = {
      ExtraTag = "small"
    }
  },
}
