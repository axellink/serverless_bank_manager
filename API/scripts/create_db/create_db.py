from db_helper.db import DbConn


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


tags = [("food",), ("home",), ("bill",), ("entertain",), ("other",), ("subscription",)]


def select_tags(curs):
    ret = []
    for i in curs:
        ret.append(i[0])
    print("CREATE_DB : tags added")
    return ret


def lambda_handler(event, context):
    try:
        DbConn.connect()
        DbConn.execute(creation_sql)
        DbConn.execute_many("INSERT INTO tags(name) VALUES (%s);", tags)
        ret = DbConn.execute("SELECT name FROM tags;", callback=select_tags)
        DbConn.close()
        return ret
    except Exception as e:
        return str(e)