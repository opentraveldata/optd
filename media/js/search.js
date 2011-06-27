$( document ).ready( function() {

    // Listener for the submit click.
    $( '#searchSubmit' ).click(function() {
        doKeywordSearch();
    });
	 
	//Listener for the "enter" key submit. 
    $( '#query' ).keypress(function(event){
        if (event.keyCode == 13) {
            $( '#searchSubmit' ).click();
        }
    });

});

//The url for the django application
url = 'http://localhost:8000/engine/'

//Shows a spinner while it doesn't recieve the response from
//the controller.
$( document ).ajaxStart( function() {
	$( '#spinner' ).show();
}).ajaxStop( function() {
	$( '#spinner' ).hide();
});

function doKeywordSearch(){
    q = $( '#query' ).val();
    $('#results').empty()
	$.getJSON('/engine', {q : q}, function(data){
        if(data.length > 0){
            
            $.each(data,function(key, val){
                $('<a href="'+ url + 'node/' + val.id +'" class="myNewLink">'+ val.name + '</a><br>').appendTo('#results')
            });
            
         }
         //Clear everything and show an alert if no data is found.
         else{
            $('#results').html("no data");
         }});
}

//Ajax function that is called when the main search input is used.
function doSimpleSearch(){
    q = $( '#query' ).val();
		$.getJSON('/engine', {q : q}, function(data){
         if(data.length > 0){
            
			$('#map').empty();
			
			//Google Maps api objects inicialization.
			var options = {
                zoom: 3,
                center: new google.maps.LatLng(0, 0),
                mapTypeId: google.maps.MapTypeId.ROADMAP
            }
            var map = new google.maps.Map(document.getElementById("map"),options);
            
            addMarkers(data, map);
            points = getLatLngPoints(data);
            var rendererOptions = {
                map: map
            }
            directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
            directionsDisplay.setMap(map);
            
            //Shows the distance between the points in the map in a div above the map
            $('#someText').html("The total distance between the points: " + getDistance(map) + " km")
            
            //Shows airlines that acts in the found airport
            getAirlines(data[0].id)
            
         }
         //Clear everything and show an alert if no data is found.
         else{
            $('#map').html("no data");
            $("#someText").empty()
         }});

}

//Calculates the distance between all the points of a given map
//and shows the path.
function getDistance(map){
    
    var routePath = new google.maps.Polyline({
		path: points,
		strokeColor: '#ff0066', //pink
		strokeOpacity: 1.0,
		strokeWeight: 1,
		geodesic: true,
		map: map
	});
	
	
	distance = Math.round(google.maps.geometry.spherical.computeLength(points) / 10)/100
    
    return distance;
}

//Make a LatLng Google Maps object for each pair (longitude, latitude) given.
//It's going to be used for making the path and calculate the distance between
//them.
function getLatLngPoints(data){
    points = []
    $.each(data,function(key, val){
        points.push(new google.maps.LatLng(val.latitude,val.longitude))
    });
    return points;
}

//Function responsable for adding the markers points
//on the map for each pair (longitude, latitude) given.
function addMarkers(data, map){
    $.each(data,function(key, val){
        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(val.latitude,val.longitude), 
            map: map, 
            title: val.name
        });   
    });
}

