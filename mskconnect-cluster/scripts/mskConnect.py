import logging
import os
import sys
import time
from argparse import ArgumentParser

import boto3
from mskconnectConf import *


logging.basicConfig(format='%(levelname)s %(asctime)s %(filename)s:%(lineno)d: %(message)s')
logger = logging.getLogger(__name__)
logger.setLevel(os.getenv("LOG_LEVEL", logging.INFO))

def create_connector(mskconnectClient, connectorVersion: str, capacity: dict, connectorConfiguration: dict, kafkaCluster: dict, \
                    logDelivery: dict, plugins: dict ,connectorSvcRoleArn: str, connectorName: str):
    """
    Create the msk connector cluster
    :return:
    """
    cluster_name = f'kafka-connect-{int(time.time())}'
    logger.info(f"Creating msk connector {cluster_name}...")

    return  mskconnectClient.create_connector(
        capacity=capacity,
        connectorConfiguration=connectorConfiguration,
        connectorDescription="Connector for kafka",
        connectorName=connectorName,
        kafkaCluster=kafkaCluster,
        kafkaClusterClientAuthentication={
            'authenticationType': 'IAM'
        },
        kafkaClusterEncryptionInTransit={
            'encryptionType': 'TLS'
        },
        kafkaConnectVersion=connectorVersion,
        logDelivery=logDelivery,
        plugins=plugins,
        serviceExecutionRoleArn=connectorSvcRoleArn
    )

def wait_for_connector_to_create(mskconnectClient, connector_arn: str, target_state: str = 'RUNNING',
                               delay_seconds: int = 10, timeout_seconds: int = 15 * 60):
    """
    Wait for the cluster to finish the update create, boto does not have a wait optio
    by default

    This function was inspired by how Terraform does it.
    :param mskconnect_arn:
    :param mskconnectClient:
    :param target_state: the target state we want to have before the timeout
    :param delay_seconds: The delay in second between two calls to describe_connector
    :param timeout_seconds: The timeout (in seconds) after which we exit if the cluster doesn't have the target state
    :return:
    """
    info = mskconnectClient.describe_connector(connectorArn=connector_arn)
    current_state = info["connectorState"]
    start_time = time.time()

    while current_state != target_state and time.time() - start_time <= timeout_seconds:
        if current_state in ["CREATING", "UPDATING"]:
            logger.info(f"Waiting for the cluster creation to finish...")
            time.sleep(delay_seconds)

            info = mskconnectClient.describe_connector(connectorArn=connector_arn)
            current_state = info["connectorState"]
        elif current_state == "FAILED":
            logger.error(f"Error when creating the connector: {info}")
            sys.exit(1)

    if current_state != target_state:
        # we have a timeout here
        logger.error(f"Timeout when waiting for connector creation to finish: {info}")
        sys.exit(2)

def get_parser() -> ArgumentParser:
    """
    Get the arguments list
    """
    p = ArgumentParser(description="Create msk connector cluster")
    p.add_argument("regionName", help="AWS Region name", type=str)
    p.add_argument("roleArn", help="Role ARN to assume", type=str)
    p.add_argument("connectorVersion", help="msk connect version", type=str)   
    p.add_argument("connectorName", help="msk connect name", type=str) 
    p.add_argument("connectorSvcRoleArn", help="msk connect service execution role arn", type=str)  

    return p

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()

    sts = boto3.client("sts", region_name=args.regionName)
    role_credentials = sts.assume_role(RoleArn=args.roleArn,
                                       RoleSessionName="terraform-msk-connect")['Credentials']
    mskconnect = boto3.client("kafkaconnect", region_name=args.regionName, aws_access_key_id=role_credentials["AccessKeyId"],
                         aws_secret_access_key=role_credentials["SecretAccessKey"],
                         aws_session_token=role_credentials["SessionToken"])


    create_response = create_connector(mskconnect, args.connectorVersion , capacity, connectorConfiguration, kafkaCluster, logDelivery, \
                                       plugins, args.connectorSvcRoleArn, args.connectorName)

    logger.debug(f"Update response: {create_response}")

    wait_for_connector_to_create(mskconnect, connector_arn=create_response['connectorArn'])
   