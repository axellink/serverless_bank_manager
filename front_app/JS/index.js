window.addEventListener("load", function(){
    var cookies = document.cookie.split('; ');
    var jwt="";
    cookies.forEach(val => {
        if (val.indexOf("JWT=") === 0) jwt = val.substring(4);
    })
    let xhr = new XMLHttpRequest();
    xhr.open("GET",config.APIUrl + "/hello")
    xhr.setRequestHeader("Authorization",jwt)
    xhr.send();
    xhr.onload = function(){
        if(xhr.status != 200) {
            window.location.href = "//" + config.AppHostname + "/login.html"
        } else {
            document.getElementById("token-text").innerHTML = xhr.responseText
        }
    }
})