import json
import base64
import boto3

"""
OK SO, to make it clear, this piece of code will be of NO USE but I'll keep it to remind myself some things :

So I began to write this because I looked for a way to 'create an user' and the only function I saw with a suitable name was 'admin_create_user'
It requires some rights to be executed, so I put it in lambda, create the policy that accepts cognito-idp:AdminCreateUser on my user pool, and attach this policy to the lambda role
But one thing tickled me, there is no way to create an user without setting a temporary password with this function, that's not what I want, I want an user set with its password, and only needing email confirmation

So I get back to the functions available in the AWS SDK, and I see that little sign_up function ...
And you know what ? You don't even need specific right, just to know the user pool ID, so it can (and should be) written on client side !!!
Here is why this code will never be used, and now I'm on my way to write this shit up in JS (yay)
I will now know that every action I'm needing for my users could be done via client app accessing directly Cognito

Bonus:
Actually, 'admin_create_user', as its name suggests, serves the following use case :
You are an admin of your app, you add an user, he is invited into the app via an email with a temporary password
Then he should connect to the app using this temporary password and immediatly changing it
Keep in mind, the use case is : invitation by an admin !
However, if it's your usecase, this code works \o/
"""

client = boto3.client('cognito-idp')
user_pool_id = "CONFIGME"


def validate_json(user):
    if user.get("nickname", "") == "":
        return False
    if user.get("email", "") == "":
        return False
    if user.get("password", "") == "":
        return False
    return True


def lambda_handler(event, context):
    print(json.dumps(event))
    try:
        body = json.loads(base64.b64decode(event.get("body","e30=")))
        if not validate_json(body):
            return {
            'statusCode': 400,
            'body': json.dumps({
                'Code': 2,
                'Message': 'Malformed JSON'
            })
        }
        response = client.admin_create_user(
            UserPoolId = user_pool_id,
            Username = body["email"],
            UserAttributes=[
                {'Name': 'nickname', 'Value': body["nickname"]}
            ],
            TemporaryPassword = body["password"]
        )
    except json.JSONDecodeError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'Code': 1,
                'Message': 'Data is not a JSON'
            })
        }
    except client.exceptions.InvalidPasswordException as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'Code': 3,
                'Message': 'Password does not conform to policy'
            })
        }
    except client.exceptions.UsernameExistsException as e:
        return {
            'statusCode': 409,
            'body': json.dumps({
                'Code': 4,
                'Message': 'This email already exists'
            })
        }
    except Exception as e:
        if "Username should be an email" in str(e):
            return {
            'statusCode': 400,
            'body': json.dumps({
                'Code': 5,
                'Message': 'Email malformed'
            })
        }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps({
                    'Code': 1000,
                    'Message': 'Something went wrong (yeah deal with it)'
                })
            }
    else:
        return {
            'statusCode': 201
        }