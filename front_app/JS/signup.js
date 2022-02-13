// This being global and loaded at the beginning of page might not be optimal
var userPool = new AmazonCognitoIdentity.CognitoUserPool({
    UserPoolId: config.CognitoPoolId,
    ClientId: config.CognitoClientId
});

var err=null;

// I should write some validation but hey, I just want it to work
function signup(){
    let email = document.getElementById("email-text").value;
    let username = document.getElementById("username-text").value;
    let passwd = document.getElementById("pass-text").value;

    let dataEmail = {
        Name: 'email',
        Value: email
    };

    let dataNickname = {
        Name: "nickname",
        Value: username
    };

    let attributeList = [];
    attributeList.push(new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail));
    attributeList.push(new AmazonCognitoIdentity.CognitoUserAttribute(dataNickname));

    userPool.signUp(email, passwd, attributeList, null, function(e, result) {
        if (e){
            alert(e.message || JSON.stringify(e));
            return;
        }else{
            window.location.href = "//" + config.AppHostname + "/confirmation.html?email=" + result.user.getUsername();
        }
    });
};

// Now we have to validate our newly created user with the code he received
function validate_code(){
    const urlParams = new URLSearchParams(window.location.search);
    let email = urlParams.get("email");

    let user = new AmazonCognitoIdentity.CognitoUser({
        Username: email,
        Pool: userPool,
    });

    let code = document.getElementById("code-text").value;

    user.confirmRegistration(code, true, function(err, result){
        if (err){
            alert(err.message || JSON.stringify(err));
            return;
        }
        document.getElementById("confirm-verify").innerHTML = "Confirmation complete, you can now <a href='login.html>login</a>"
    })

}