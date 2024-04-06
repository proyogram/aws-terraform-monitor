import boto3
import jmespath
import logging

logs_client = boto3.client('logs')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #CloudWatch Logsロググループ名取得（ロググループ名をリストに格納）
    response = logs_client.describe_log_groups()
    log_groups = jmespath.search('logGroups[].logGroupName',response)

    logger.info('Log list : '.join(log_groups))

    return {
        'element_num':len(log_groups),
        'log_groups':log_groups
    }