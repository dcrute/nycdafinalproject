function setActive(){
var sPath=window.location.pathname;
var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
if(sPage == "home")
document.getElementById("home").className += "active";
else if(sPage == "sampleJavascript1")
document.getElementById("JavaScript1").className = "active";
else if(sPage == "sampleJavascript2")
document.getElementById("JavaScript2").className = "active";
}
