//menu.js

var isShowing = false; /* Flag to indicate if a drop-down menu is visible */
var menuItem = null;   /* Reference to a drop-down menu */
var menu_item = null;
var isMenu = false;

//Show the drop-down menu with the given id, if it exists, and set flag
function show(id, menu)
{
    hide(); /* First hide any previously showing drop-down menu */
    menu_item = document.getElementById(menu);
    menuItem = document.getElementById(id);
    if (menuItem != null)
    {
        menuItem.style.visibility = 'visible';
        menu_item.style.backgroundColor= '#222222';
        isMenu = true;
        isShowing = true;
    }
}

function show_div(id)
{
    menuItem = document.getElementById(id);
    if (menuItem != null)
    {
        menuItem.style.visibility = 'visible';
        isShowing = true;
    }
}

//Hide the currently visible drop-down menu and set flag
function hide()
{       
    if (isShowing) menuItem.style.visibility = 'hidden';
    if (isMenu) menu_item.style.backgroundColor= '#000000';
    isShowing = false;
    isMenu = false
}
