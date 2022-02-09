function login(){
    console.log("entering login")
    var userPool = new AmazonCognitoIdentity.CognitoUserPool({
        UserPoolId: config.CognitoPoolId,
        ClientId: config.CognitoClientId
    });

    var authData = {
        Username: document.getElementById("username-text").value,
        Password: document.getElementById("pass-text").value
    };
    var authDetails = new AmazonCognitoIdentity.AuthenticationDetails(authData);
    var cognitoUser = new AmazonCognitoIdentity.CognitoUser({
        Username: authData.Username,
        Pool: userPool
    });

    cognitoUser.authenticateUser(authDetails,{
        onSuccess: function(result) {
            var accessToken = result.getAccessToken().getJwtToken();
            console.log("Got JWT : " + accessToken);
            document.cookie = "JWT=" + accessToken + ";SameSite=strict";
            window.location.href = "//" + config.AppHostname + "/index.html"
        },
        onFailure: function(err){
            alert(err.message || JSON.stringify(err));
        }
    })
};