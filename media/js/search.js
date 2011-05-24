$( document ).ready( function() {

    // Clear the divs before doing a new ajax call for the search.
    $( '#searchSubmit' ).click(function() {
        $("#findRule").hide();
        $("#findRuleResult").empty()
        $('#findRule :input').not(':button, :submit').val("");
//	    doSimpleSearch();
	    doKeywordSearch();
	 });
	 
	 //do the ajax search for a rule
	 $( '#ruleSubmit' ).click(function() {
	    doRuleSearch();
	 });
	 
	 //for ease the date input in the rule search form
//	 $( "#datepicker" ).datepicker();

});

//Shows a spinner while it doesn't recieve the response from
//the controller.
$( document ).ajaxStart( function() {
	$( '#spinner' ).show();
}).ajaxStop( function() {
	$( '#spinner' ).hide();
});

function doKeywordSearch(){
    q = $( '#query' ).val();
//    console.info(navigator.language)
    $('#someText').empty()
    $('#map').remove()
	$.getJSON('/engine/search', {q : q}, function(data){
        if(data.length > 0){
            
            $.each(data,function(key, val){
                $('#someText').append(val.name + "<br>")
            });
            
         }
         //Clear everything and show an alert if no data is found.
         else{
            $('#someText').html("no data");
         }});
}

//Ajax function that is called when the main search input is used.
function doSimpleSearch(){
    q = $( '#query' ).val();
		$.getJSON('/engine/search', {q : q}, function(data){
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
            
            //Only shown when there's only two points in the map. The form to search for a Rule.
//            if(data.length == 2){ 
//                $("#origin").val(data[0].fields.IATA);
//                $("#destination").val(data[1].fields.IATA)
//                $("#findRule").show()
//            }
            
         }
         //Clear everything and show an alert if no data is found.
         else{
            $('#map').html("no data");
            $("#someText").empty()
         }});

}

//When there is 2 points of interest on the map, a form is shown
//and the user is able to make a seach within the Rules.
//This method does an ajax call to find a Rule with the given
//parameters.
function doRuleSearch(){
	$.getJSON('/engine/rsearch', {a : $( '#airline' ).val(), 
	                              o : $(" #origin").val(), 
	                              d : $(" #destination").val(), 
	                              c : $( '#classOfService' ).val(), 
	                              t : $( '#datepicker' ).val(), 
	                              f : $( '#flightNumber' ).val()}, 
    function(data){
        if(data.length > 0){
			$('#findRuleResult').html("Cabin: " + data[0].fields.cabin.fields.fullName);
        }
         else{
            $('#findRuleResult').html("no data");
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

function getAirlines(id){
    $.getJSON('/engine/get_airlines', {id : id}, function(data){
        $('#airlineResult').empty()
        $.each(data,function(key, val){
            $('#airlineResult').append(val.name + "<br>")
        });
    
    });

}



