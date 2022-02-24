import boto3
import psycopg2
import os

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
    except Exception as e:
            raise e
    else:
        return json.loads(get_secret_value_response['SecretString'])
            

class DbConn(object):
    conn = None

    def __init__():
        if DbConn.conn is None :
            db_info = get_secret()
            DbConn.conn = psycopg2.connect(
                host = db_info["hostname"],
                database = db_info["dbname"],
                user = db_info["username"],
                password = db_info["password"],
                port = db_info["port"]
            )

def sql_execute(*args, **kwargs):
    def innner(func):
        DbConn()
        with DbConn.conn.cursor() as curs:
            curs.prepare(kwargs["query"])
            curs.execute(kwargs["param"])
            ret = func(curs)
        return ret
    return innner

def sql_execute_many(*args, **kwargs):
    def inner(func):
        DbConn()
        with DbConn.conn.cursor() as curs:
            curs.prepare(kwargs["query"])
            curs.executemany(kwargs["params"])
            func(curs)
    return inner