import os
import boto3
import datetime
import logging

logs_client = boto3.client('logs')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    export_bucket = os.environ['EXPORT_BUCKET']
    index = event['iterator']['index']
    day = event['iterator']['day']
    count = event['describe_log_groups']['element_num']
    target_log_group = event['describe_log_groups']['log_groups']
    
    #実行日取得（例：2019-09-12）
    today = datetime.date.today()     
    
    
    lastmonth = today - datetime.timedelta(days=20) 
    # retention内で設定しないとエラーとなる。
    startday = lastmonth
    delta_day = 1
    
    from_day = startday + datetime.timedelta(days=delta_day*day)
    # yesterday = today - datetime.timedelta(days=1)   #前日取得（例：2019-09-11）
    #出力日時（from）取得（例：2019-09-11 00:00:00）
    from_time = datetime.datetime(year=from_day.year, month=from_day.month, day=from_day.day, hour=0, minute=0,second=0)
    #出力日時（to）取得（例：2019-09-11 23:59:59.999999）
    to_time = datetime.datetime(year=from_day.year, month=from_day.month, day=from_day.day, hour=24*delta_day-1, minute=59,second=59,microsecond=999999)
    print("from_time",from_time,"to_time",to_time, target_log_group[index])

    #エポック時刻取得(float型)
    epoc_from_time = from_time.timestamp()
    epoc_to_time = to_time.timestamp()
    #エポック時刻をミリ秒にしint型にキャスト（create_export_taskメソッドにintで渡すため）
    m_epoc_from_time = int(epoc_from_time * 1000)
    m_epoc_epoc_to_time = int(epoc_to_time * 1000)

    #CloudWatch Logsエクスポート
    response = logs_client.create_export_task(
        logGroupName = target_log_group[index],
        fromTime = m_epoc_from_time,
        to = m_epoc_epoc_to_time,
        destination = export_bucket,
        destinationPrefix = f"{from_day.strftime('%Y%m%d')}"
    )

    logger.info('Target log group : ' + target_log_group[index])
    logger.info('Task ID : ' + response['taskId'])

    day += 1
    if day == 2:
        index += 1
        day = 0

    return {
        'index':index,
        'day':day,
        'end_flg':count == index,
        'task_id':response['taskId']
    }