package panzerschokolade;

import sys.io.File;
import haxe.Json;
import haxe.Resource;
import haxe.Template;

class Router {

	public function new() {}

	public function doDefault( site : String ) {
		if( site == '' ) site = 'event';
		var res = Resource.getString( site );
		if( res == null ) {
			Sys.print( '404' );
		} else {
			printSite( new Template( res ).execute({}) );
		}
	}

	/*
	public function doAbout() {
		Sys.print( "FEED HERE" );
	}

	public function doFeed() {
		Sys.print("FEED HERE");
	}
	*/

	function printSite( content : String ) {
		var html = new Template( Resource.getString( 'index' ) ).execute({
			content : content
		});
		Sys.print( html );
	}
}
