
variable "project_name" {
  type    = string
  default = "mskconnect"
}

variable "prefix" {
  type    = string
  default = "mskconnect"
}

variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "log_retention_in_days" {
  description = "Log retention for log groups"
  type        = number
  default     = 7
}

variable "kafka_cluster_name" {
  description = "the name of kafka cluster"
  type        = string
  default     = "kafka"

}

variable "mskconnect_version" {
  description = "mskconnect version"
  type        = string
  default     = "2.7.1"
}

variable "mskconnect_worker_autoscaling" {
  description = "The threshold for msk connect autoscaling"
  type        = map(string)
  default = {

    min_worker_count = 1
    max_worker_count = 2
    mcu_count        = 1
    scale_in_cpu     = 20
    scale_out_cpu    = 80
  }
}

variable "tasks_max" {
  description = "The number of tasks per worker"
  type        = string
  default     = 1
}

# connection parameters
variable "connection_url" {
  description = "The connection url for  oracle bdd"
  type        = string
}


variable "connection_user" {
  description = "The connection user for  oracle bdd"
  type        = string
}

variable "connection_password" {
  description = "The connection user for  oracle bdd"
  type        = string
}

variable "custom_plugin_arn" {
  type = string
}

