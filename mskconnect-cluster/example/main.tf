module "mskconnect" {
  source                        = "../.."
  env_name                      = terraform.workspace
  log_retention_in_days         = var.log_retention_in_days
  aws_region                    = var.region
  role_arn                      = local.iam_app_role_arn
  account_id                    = var.iam_app_account_ids
  msk_cluster_name              = var.kafka_cluster_name
  mskconnect_cluster_name       = local.msk_name
  mskconnect_worker_autoscaling = var.mskconnect_worker_autoscaling
  secret_name                   = local.secret_name

  custom_plugin_arn = var.custom_plugin_arn

  connector_conf = {
    "name" : local.msk_connector_name,
    "table.name.format" : "TABLE",
    "connector.class" : "io.confluent.connect.jdbc.JdbcSinkConnector",


    "connection.user" : "${var.connection_user}",
    "connection.password" : "${var.connection_password}",
    "connection.url" : "${var.connection_url}",
    "topics" : "topic",
    "key.converter" : "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schema.registry.url" : "${data.aws_ssm_parameter.schema_registry_url.value}",
    "value.converter" : "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url" : "${data.aws_ssm_parameter.schema_registry_url.value}",
    "sasl.client.callback.handler.class" : "software.amazon.msk.auth.iam.IAMClientCallbackHandler",
    .
    .
    .


  }

}
