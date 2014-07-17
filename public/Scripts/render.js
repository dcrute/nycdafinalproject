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

function startLightbox(id)
 {
    	var imageName = document.getElementById(id).src;
    	document.getElementById('light').style.display='block';
    	document.getElementById('fade').style.display='block';
    	var setimage = document.getElementById('setImage');
    	setimage.src = imageName;
 }

 function startPostBox()
 {
    	document.getElementById('light').style.display='block';
    	document.getElementById('fade').style.display='block';
 }
