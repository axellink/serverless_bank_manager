import json
import boto3

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    try:
        # Let's try to get the user from its JWT
        user = client.get_user(AccessToken=event["headers"]["authorization"])
    except Exception as e:
        # If we can't get the user, return a 500 and log the actual error
        print(e)
        return {
            'statusCode': 500,
            'body' : {
                'Code': 1,
                'Message': 'Error occured with your access token'
            }
        }
    else:
        # Else look for his email
        for x in user.get("UserAttributes", []):
            if x.get("Name") == "email" :
                return {
                    'statusCode': 200,
                    'body': x.get("Value")
                }
        # If we haven't found any email, return an error
        return {
            'statusCode': 500,
            'body': {
                'Code': 2,
                'Message': 'No email found for your user'
            }
        }
