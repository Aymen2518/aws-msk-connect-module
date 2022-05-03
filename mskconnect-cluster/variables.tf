variable "aws_region" {
  description = "Name of the region to deploy to"
  type        = string
}

variable "env_name" {
  description = "Name of the environment"
  type        = string
}

variable "log_retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 7
}


variable "default_tags" {
  description = "The default tags to be used to tag resources"
  type        = map(string)
  default     = {}
}

variable "role_arn" {
  type        = string
  description = "The role ARN to assume for the Python script used to manage the configuration."
}

variable "account_id" {
  type        = string
  description = "The account id for the msk connect, this will be used to create iam policies for connector."
}

variable "mskconnect_cluster_name" {
  type        = string
  description = "The name of the msk connect cluster to be used"
}

variable "msk_cluster_name" {
  type        = string
  description = "The name of the msk cluster"
}

variable "vpc_name_prefix" {
  description = "Prefix of the MSK VPC name (without -env)"
  type        = string
  default     = "vpc"
}

variable "mskconnect_version" {
  description = "msk connect version"
  type        = string
  default     = "2.7.1"
}

variable "mskconnect_worker_autoscaling" {
  description = "The threshold for msk connect autoscaling"
  type        = map(string)
}
# Custom plugins configuration
variable "custom_plugin_arn" {
  type        = string
  description = "The arn of the custom plugin to be used by msk connect"
}

variable "custom_plugin_revision" {
  type        = string
  description = "The version of the custom plugin, for now we do not have delete API option fot this resource, so for now the revision it always refers to 1"
  default     = "1"
}

# Msk connect conf

variable "connector_conf" {
  type        = map(string)
  description = "All the configuration attributes to be used by the msk connector"
}

variable "secret_name" {
  type        = string
  description = "The aws secret manager name to be used to retrieve sensitive data nd put it in worker configuration"
}