import secrets
import boto3
import base64
import psycopg2
import os
from botocore.exceptions import ClientError

def get_secret():

    secret_name = os.environ["SECRETS_ARN"]
    region_name = os.environ["SECRETS_REGION"]

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
            raise e
    else:
        return json.loads(get_secret_value_response['SecretString'])
            

class DbConn(object):
    def __init__():
        secrets = get_secret()
        self._conn = psycopg2.connect(
            host = 
        )