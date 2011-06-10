$( document ).ready( function() {

    $( "#opener" )
        .button()
        .click(function() {
	        $( "#dialog" ).dialog( "open" );
		    return false;
	    });

	// a workaround for a flaw in the demo system (http://dev.jqueryui.com/ticket/4375), ignore!
    $( "#dialog:ui-dialog" ).dialog( "destroy" );
		
    var name = $( "#text" ),
	    allFields = $( [] ).add( name )

	$( "#dialog" ).dialog({
		autoOpen: false,
		height: 300,
		width: 350,
		show: "fade",
		hide: "fade",
		modal: true,
		buttons: {
			"Send error message": function() {
				console.log($( "#text" ).val());
				$( this ).dialog( "close" );
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
