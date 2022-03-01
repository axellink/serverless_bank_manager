from logging import exception
from subprocess import call
import boto3
import psycopg2
import os
import json


'''
I'm using decorators for sql queries, looked like a good idea at first to ensure db connection was up for the request to be made
Then came the question of how I can give sql query and parameters to the decorator while having a function to process database return
So I did decorators with paramaters, containing the query and parameters, while the decorated function act as a callback to for processing
But, since I don't want to close my connection each time in case we should do multiple queries, decorators only open it if not already using the DB singleton
So I now have to export a close function from the DB singleton, defeating the purpose of the decorator to hide it ...
To add to it, this might be overcomplicated for quite nothing but my amusement because of two things :
    - You have to keep in mind when creating your processing function that it has to expect one argument which is the cursor to iterate on
    - If you only want a query that returns nothing (like a table creation), you still have to create a function to decorate, that will do nothing

I'll let it as it, since it's exactly a project for learning and fun, but I would do it differently with these problems in mind
I would actually get those functions back into the singleton class so developpers know it exists and should be taken care of (open/close connection)
The function may have a "callback" argument that would be the processing function :
    - We can more easily express the fact that the callback has to expect the cursor argument
    - we can even provide no callback for write only query
    - And we can write the processing callback inline !

UPDATE : I may not be the first to come to that conclusion, but decorator are definitely what I want here !! Not as how I've implemented them though.
I will just have execute and execute_many back into the db_helper object, with possibility to pass a callback for returning calls.
'''


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

    def connect():
        if DbConn.conn is None :
            try:
                print("DB_HELPER : Trying to connect")
                db_info = get_secret()
                print("DB_HELPER : Got Secrets")
                DbConn.conn = psycopg2.connect(
                    host = db_info["hostname"],
                    database = db_info["dbname"],
                    user = db_info["username"],
                    password = db_info["password"],
                    port = db_info["port"]
                )
                print("DB_HELPER : Connected")
            except Exception as e:
                print("DB_HELPER : Connection failed : " + str(e))
    
    def close():
        if DbConn.conn is not None:
            print("DB_HELPER : Closing connection")
            try:
                DbConn.conn.close()
                print("DB_HELPER : Closed connection")
            except Exception as e:
                print("DB_HELPER : Error during close connection : " + str(e))
                raise e
            finally:
                DbConn.conn = None
    
    def commit():
        if DbConn.conn is not None:
            try:
                print("DB_HELPER : Commit")
                DbConn.conn.commit()
            except Exception as e:
                print("DB_HELPER : Error while commiting : " + str(e))

    def execute(query, param=(), callback=None):
        DbConn.connect()
        print("DB_HELPER : Execute query")
        with DbConn.conn.cursor() as curs:
            curs.execute(query, param)
            DbConn.commit()
            ret = None
            if callable(callback):
                ret = callback(curs)
        return ret

    def execute_many(query, param):
        DbConn.connect()
        print("DB_HELPER : Execute many query")
        with DbConn.conn.cursor() as curs:
            for i in param:
                curs.execute(query, i)
            DbConn.commit()