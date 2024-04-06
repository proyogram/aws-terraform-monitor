import json
import os
import boto3

retention_days=int(os.environ['RETENTION_DAYS'])
logs = boto3.client('logs')

def set_logs_retention(log_group_name):
    response = logs.put_retention_policy(
        logGroupName=log_group_name,
        retentionInDays=retention_days
    )

def lambda_handler(event, context):
    response = logs.describe_log_groups()
    log_group_list = response['logGroups']  

    # By using nextToken, you can describe all log groups in your account.
    # Without nextToken, up to 50 log groups.
    while 'nextToken' in response:
        response = logs.describe_log_groups(nextToken=response['nextToken'])
        next_log_group_list = response['logGroups']
        log_group_list.extend(next_log_group_list)

    for log_group in log_group_list:
        try:
            log_group_name = log_group['logGroupName']
            current_retention_days=log_group['retentionInDays']
        
        # The log group with no retentionInDays outputs KeyError.
        # Set retention on it. 
        except KeyError:
            log_group_name = log_group['logGroupName']
            set_logs_retention(log_group_name)
