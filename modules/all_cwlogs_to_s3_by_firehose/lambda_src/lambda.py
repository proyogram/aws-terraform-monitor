import boto3
import time
import logging
import os

# input
DESTINATION_BUCKET_NAME =os.environ['DESTINATION_BUCKET_NAME']
ACCOUNT_ID = os.environ['ACCOUNT_ID']
ROLE_NAME_FOR_KDF = os.environ['ROLE_NAME_FOR_KDF']
ROLE_NAME_FOR_LOGS = os.environ['ROLE_NAME_FOR_LOGS']

# clienの定義
firehose = boto3.client('firehose')
logs = boto3.client('logs')
                    
def take_loggroup_list():
    # 初回のresponseを格納
    response = logs.describe_log_groups()
    # 初回のロググループをリストに格納
    loggroup_list = response['logGroups'] 

    # 全てのロググループを取得(nextTokenを用いた処理必須)
    while 'nextToken' in response:
        response = logs.describe_log_groups(nextToken=response['nextToken'])
        next_loggroup_list = response['logGroups']
        loggroup_list.extend(next_loggroup_list)
        
    return loggroup_list
  
def create_firehose(delivery_stream_name, loggroup_short_name):
    try:
        response = firehose.create_delivery_stream(
            DeliveryStreamName=delivery_stream_name,
            DeliveryStreamType='DirectPut',
            ExtendedS3DestinationConfiguration={
                'RoleARN': f'arn:aws:iam::{ACCOUNT_ID}:role/{ROLE_NAME_FOR_KDF}',
                'BucketARN': f'arn:aws:s3:::{ DESTINATION_BUCKET_NAME}',
                'Prefix': loggroup_short_name+'/',
                'CompressionFormat': 'GZIP'
            },
        )
        print(f"+ {delivery_stream_name} ")
    except Exception as e:
        if e.__class__.__name__ == 'ResourceInUseException':
            pass
        else:
            raise

# ロググループにサブスクリプションフィルターを設定する関数
def create_subfil(loggroup_name,delivery_stream_name):
    retry_number=5
    for retry in range(1, retry_number+1):
        try:
            response = logs.put_subscription_filter(
                logGroupName=loggroup_name,
                filterName='S3-backup',
                filterPattern='',
                destinationArn=f'arn:aws:firehose:ap-northeast-1:{ACCOUNT_ID}:deliverystream/{delivery_stream_name}',
                roleArn=f'arn:aws:iam::{ACCOUNT_ID}:role/{ROLE_NAME_FOR_LOGS}',
                distribution='ByLogStream'
            )
            break
        
        except Exception as e:
            if e.__class__.__name__ == 'InvalidParameterException':
                if retry == retry_number:
                    logging.warn(f'{retry_number} 回失敗しました。処理を終了します。')
                    print(e)
                else:
                    logging.warn(f'{retry} 回目, {retry * 2}秒待機します.')
                    time.sleep(retry * 2)
            
            else:
                raise

def lambda_handler(event, context):
    loggroup_list = take_loggroup_list()
    for loggroup in loggroup_list:
        loggroup_name = loggroup['logGroupName']
        loggroup_short_name = loggroup_name.split("/")[-1]
        delivery_stream_name = "kdf-"+loggroup_short_name
        # firehoseの作成
        create_firehose(delivery_stream_name, loggroup_short_name)
    
    # 30s待機
    time.sleep(30)
    
    for loggroup in loggroup_list:
        loggroup_name = loggroup['logGroupName']
        loggroup_short_name = loggroup_name.split("/")[-1]
        delivery_stream_name = "kdf-"+loggroup_short_name
        # サブスクリプションフィルタの定義
        create_subfil(loggroup_name, delivery_stream_name)
