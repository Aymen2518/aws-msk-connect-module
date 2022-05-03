terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  is_default_env = var.env_name == "default"
  vpc_name       = "${var.vpc_name_prefix}-${var.env_name}"
  sg_name        = "sg-kafka-${var.env_name}-brokers"

  mskconnect_conf = templatefile("${path.module}/templates/mskconnect-conf.py.tpl", {
    # Capacity planning
    max_worker_count = var.mskconnect_worker_autoscaling["max_worker_count"]
    min_worker_count = var.mskconnect_worker_autoscaling["min_worker_count"]
    mcu_count        = var.mskconnect_worker_autoscaling["mcu_count"]
    scale_in_cpu     = var.mskconnect_worker_autoscaling["scale_in_cpu"]
    scale_out_cpu    = var.mskconnect_worker_autoscaling["scale_out_cpu"]

    # Connector configurations

    connector_conf = var.connector_conf

    # MSK cluster attributes
    msk_bootstrap_servers = data.aws_msk_cluster.msk.bootstrap_brokers_sasl_iam
    msk_security_groups   = jsonencode(data.aws_security_group.msk_sg.id)
    msk_subnets           = jsonencode(data.aws_subnet_ids.private.ids)

    # Cloudwatch log group configuration
    log_group = "mskconnect-${var.env_name}-logs"

    # Custom plugins ARN
    custom_plugin_arn = var.custom_plugin_arn
    revision          = var.custom_plugin_revision

  })
}

resource "aws_cloudwatch_log_group" "mskconect_logs" {
  name              = "mskconnect-${var.env_name}-logs"
  retention_in_days = var.log_retention_in_days
  tags              = var.default_tags
}


resource "local_file" "conf" {
  content  = local.mskconnect_conf
  filename = "${path.module}/scripts/mskconnectConf.py"
}

resource "null_resource" "create_mskconnect_cluster" {
  triggers = {
    mskconnect_config  = local.mskconnect_conf
    mskconnect_name    = var.mskconnect_cluster_name
    mskconnect_version = var.mskconnect_version
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/mskConnect.py ${var.aws_region} ${var.role_arn} ${var.mskconnect_version} ${var.mskconnect_cluster_name} ${aws_iam_role.role.arn}"

    environment = {
      # Environment variables

    }
  }
  depends_on = [local_file.conf]
}

