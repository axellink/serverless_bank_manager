import json
import boto3
import os
from db_helper.db import sql_execute, sql_execute_many

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

tags = [("food"), ("home"), ("bill"), ("entertain"), ("other"), ("subscription")]


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


@sql_execute(query = creation_sql, param="")
def create_tables(curs):
    pass


@sql_execute_many(query = "INSERT INTO tags(name) VALUES ('%s');", params = tags)
def populate_tags(curs):
    pass


@sql_execute(query = "SELECT name FROM tags;")
def select_tags(curs):
    ret = []
    for i in curs:
        print(i)
        ret.append(i)
    return ret


def lambda_handler(event, context):
    try:
        create_tables()
        populate_tags()
        return select_tags()
    except Exception as e:
        return str(e)