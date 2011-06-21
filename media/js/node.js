$( document ).ready( function() {

    //Catchs the click event on the button to show de modal form.
    $( "#opener" )
        .button()
        .click(function() {
	        $( "#dialog" ).dialog( "open" );
		    return false;
	    });
	    
	 //Catchs the click event on the button to show the map.   
	 $( "#showMap" )
        .button()
        .click(function() {
            if ( !($("#map").length) ) {
                $('<div id="map"></div>').appendTo('#node');
                showMap();
            }
	    });   

    var name = $( "#text" ),
	    allFields = $( [] ).add( name )

    //Creates a modal dialog for an e-mail form.
	$( "#dialog" ).dialog({
		autoOpen: false,
		height: 300,
		width: 350,
		show: "fade",
		hide: "fade",
		modal: true,
		buttons: {
			"Send error message": function() {
				sendEmail($( "#text" ).val());
				closeDialog(this, 1000);
			},
			Cancel: function() {
				$( this ).dialog( "close" );
			}
		},
		close: function() {
			allFields.val( "" ).removeClass( "ui-state-error" );
		}
	});
	
});

//url for the app
url = 'http://localhost:8000/engine/'

//Shows a map and add a mark point on it based on the 
//information of this POI displayed on the screen.
function showMap(){
    //Google Maps api objects inicialization.
    
    var point = new google.maps.LatLng($("#latitude").text(),$("#longitude").text())
    
    var options = {
        zoom: 6,
        center: point,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    var map = new google.maps.Map(document.getElementById("map"),options);
            
    addMarker(point, $("#name").text(), map);
}


//Function responsable for adding a marker point
//on the map for the given (longitude, latitude) pair.
function addMarker(point, name, map){
    var marker = new google.maps.Marker({
        position: point, 
        map: map, 
        title: name
    });
}


//Send the information entered by the user, via e-mail, to the admins.
function sendEmail(text){
    $.get(url + "send_email", { text: $( "#text" ).val() }, function(data) {
        changeMessage($( ".tips" ),"Message sent !");
    });
}

//Responsable to change the tooltip message for the modal form.
function changeMessage(tips, text){
    tips.text(text).addClass( "ui-state-highlight" );
	setTimeout(function() {
	    tips.removeClass( "ui-state-highlight");
		tips.empty();
	}, 1000 );
}

//Closes the modal form.		
function closeDialog(obj, time){
    setTimeout(function() { $( obj ).dialog( "close" );}, time );
}		
