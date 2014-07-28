function setActive(){
var sPath=window.location.pathname;
var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
if(sPage == "home")
document.getElementById("home").className += "active";
else if(sPage == "gallery")
document.getElementById("home").className = "active";
else if(sPage == "edit_account")
document.getElementById("edit_account").className = "active";
else if(sPage == "profiles")
document.getElementById("profiles").className = "active";
else if(sPage == "profile")
document.getElementById("profiles").className = "active";
else if(sPage == "profile-gallery")
document.getElementById("profiles").className = "active";
else if(sPage == "events")
document.getElementById("events").className = "active";
else if(sPage == "event")
document.getElementById("events").className = "active";
else if(sPage == "admin_screen")
document.getElementById("admin_screen").className = "active";
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

 function startPostBox(id)
 {
    	document.getElementById(id).style.display='block';
    	document.getElementById('fade').style.display='block';
 }

 function startCommentBox(id)
 {
        document.getElementById(id).style.display='block';
        document.getElementById('fade').style.display='block';
 }
