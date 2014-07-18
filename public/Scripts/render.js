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
    	var imageAlt = document.getElementById(id).alt;
    	document.getElementById('light').style.display='block';
    	document.getElementById('fade').style.display='block';
    	var setimage = document.getElementById('setImage');
		var setlink = document.getElementById('setLink');
    	
    	setimage.src = imageName;
    	string1 = "/delete-photo?id="
    	setlink.href = string1.concat(imageAlt);
 }

 function startPostBox()
 {
    	document.getElementById('light').style.display='block';
    	document.getElementById('fade').style.display='block';
 }
