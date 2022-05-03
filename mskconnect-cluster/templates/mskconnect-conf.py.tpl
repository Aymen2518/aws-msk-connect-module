
capacity={
            "autoScaling": {
            "maxWorkerCount": ${max_worker_count},
            "mcuCount": ${mcu_count},
            "minWorkerCount": ${min_worker_count},
            "scaleInPolicy": {
                "cpuUtilizationPercentage": ${scale_in_cpu}
            },
            "scaleOutPolicy": {
                "cpuUtilizationPercentage": ${scale_out_cpu}
            }
        }
    }
connectorConfiguration=${jsonencode({ for k, v in "${connector_conf}": k => v})}

kafkaCluster={
            "apacheKafkaCluster":      {
        "bootstrapServers": "${msk_bootstrap_servers}",
        "vpc": {
            "securityGroups": [${msk_security_groups}],
            "subnets": ${msk_subnets}
        }
    }
}

logDelivery={
            "workerLogDelivery": {
        "cloudWatchLogs": {
            "enabled": True,
            "logGroup": "${log_group}"
        }
    }
}

plugins=[
            {
            'customPlugin':  {
            "customPluginArn": "${custom_plugin_arn}",
            "revision": ${revision}
        }
            },
        ]
