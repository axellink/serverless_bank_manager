This file will sum up AWS resources created along the developpment. They will be put into terraform in the end but for now, I'll just keep trock of them.

# Cognito

Create an User Pool with default settings.

The pool ID goes to `front_app/JS/config.js` in `config.CognitoPoolId`

Then add an App Client, ensure you unchecked `Generate client secret`. The app client ID goes to `front_app/JS/config.js` in `config.CognitoClientId`

Configure the app client in app client settings, check `Cognito User Pool`, configure the callback URL and sign out URL (first is the URL you go back to once connected via the hosted UI, the second is the url you go back to when signin out via the hosted UI). In OAuth 2.0 section, check `Implicit grant`, then `email` and `openid`.

Configure a domain name for debugging purpose, to have the host UI. You can use it to create your users while it's not implemented via the API (which should arrive).

# API Gateway and Lambda

I will treat them at the same time since they are corelated.

## API Gateway
Create a new API, its URL will go into `front_app/JS/config.js` in `config.APIUrl`.

Configure CORS tu allow everything from everywhere for now, we should restrict it to our application hostname later, but for now put a `*` in `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods` and `Access-Control-Allow-Headers`

## /hello
Create a lambda :
- Python File : `API/hello.py`

Create a new API route `/hello` with method `GET`.

Configure authorization by creating a new authorizer. Its type is JWT, name it what you want, let the identity source as is, issuer is `https://cognito-idp.COGNITO_REGION.amazonaws.com/COGNITO_POOL_ID` and audience is your Cognito App Client ID.

Create a new integrations with the type lambda function and select your created lambda.

# What's next ?

Implement user creation, lost password, user deletion password changing