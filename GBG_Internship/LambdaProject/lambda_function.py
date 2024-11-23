import json
import boto3

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # Retrieve information about the S3 event
    records = event.get('Records', [])

    for record in records:
        if record['eventName'] == 'ObjectCreated:Put':
            # Extract the bucket and object key from the S3 event
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            
            # Get the file size
            response = s3.head_object(Bucket=bucket_name, Key=object_key)
            file_size_bytes = response['ContentLength']
            file_size_kb = file_size_bytes / 1024 
            
# Check if file size exceeds 80 KB
            if file_size_kb > 80:
                message = f"File '{object_key}' ({file_size_kb:.2f} KB) exceeded 80 KB and will be deleted from the S3 bucket '{bucket_name}'."
                s3.delete_object(Bucket=bucket_name, Key=object_key)
            else:
                message = f"File '{object_key}' ({file_size_kb:.2f} KB) has been uploaded to the S3 bucket '{bucket_name}'."

            subject = "S3 File Upload Notification"
            sns.publish(TopicArn='arn:aws:sns:us-east-1:845537495355:myfirsttopic14021997bebo', Subject=subject, Message=message)


    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent successfully!')
    }
