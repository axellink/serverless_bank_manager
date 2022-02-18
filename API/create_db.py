import json
import psycopg2
import boto3

# This will only work in python3.8, psycopg2 for aws (aws-psycopg2) is not compatible yet with python3.9
# Remember to create the Lambda layer as well or import won't work

creation_sql="""
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE account (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    owner_uuid UUID NOT NULL,
    last_balance NUMERIC(14, 2) NOT NULL
);

CREATE TABLE transaction (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_uuid UUID NOT NULL,
    date DATE NOT NULL,
    comment TEXT,
    amount NUMERIC(14, 2) NOT NULL,
    new_balance NUMERIC(14, 2),
    CONSTRAINT fk_account FOREIGN KEY(account_uuid) REFERENCES account(uuid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tags (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20)
);

CREATE TABLE transaction_tags (
    transaction_uuid UUID,
    tag_uuid UUID,
    PRIMARY KEY(transaction_uuid, tag_uuid),
    CONSTRAINT fk_transaction FOREIGN KEY(transaction_uuid) REFERENCES transaction(uuid) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tag FOREIGN KEY(tag_uuid) REFERENCES tags(uuid) ON DELETE CASCADE ON UPDATE CASCADE
);
"""

tags = ["food", "home", "bill", "entertain", "other", "subscription"]

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

def lambda_handler(event, context):
    try :
        db_info = get_secret()
        conn = psycopg2.connect(
            host = db_info["hostname"],
            database = db_info["dbname"],
            user = db_info["username"],
            password = db_info["password"],
            port = db_info["port"]
        )

        cur = conn.cursor()
        cur.execute(creation_sql)
        conn.commit()

        for i in tags:
            cur.execute("INSERT INTO tags(name) VALUES ('" + i + "');")
        conn.commit()

        cur.close()
        conn.close()
        return "OK"
    except Exception as e:
        return str(e)