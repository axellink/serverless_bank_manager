import json
import boto3

def lambda_handler(event, context):
    return {
        'statusCode' : 200,
        'body' : event["requestContext"]["authorizer"]["claims"]["username"]
    }