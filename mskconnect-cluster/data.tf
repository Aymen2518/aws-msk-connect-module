data "aws_msk_cluster" "msk" {
  cluster_name = var.msk_cluster_name
}

data "aws_vpc" "product_vpc" {
  tags = {
    Name = local.vpc_name
  }
}

data "aws_security_group" "msk_sg" {
  tags = {
    Name = local.sg_name
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.product_vpc.id
  tags = {
    tier = "private"
  }
}
