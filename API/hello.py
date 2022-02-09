import json

def lambda_handler(event, context):
    print(json.dumps(event))
    return {
        'statusCode': 200,
        'body': "%s" % (event["requestContext"]["authorizer"]["jwt"]["claims"]["username"])
    }
