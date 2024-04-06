import boto3
import logging

logs_client = boto3.client('logs')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    task_id = event['iterator']['task_id']

    #エクスポートタスク ステータス取得
    response = logs_client.describe_export_tasks(
        taskId=task_id,
    )
    status_code = response['exportTasks'][0]['status']['code']

    logger.info('Task ID : ' + task_id)
    logger.info('Status code : ' + status_code)

    return {
        'status_code': status_code
    }