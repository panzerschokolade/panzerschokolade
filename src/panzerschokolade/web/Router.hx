package panzerschokolade.web;

import sys.io.File;
import php.Web;
import haxe.Json;
import haxe.Resource;
import haxe.Template;
import om.web.Dispatch;

class Router {

	public function new() {}

	public function doDefault( ?path : String ) {
		//trace(path);
		/*
		var r = ~/[0-9][0-9]/;
		if( r.match( path ) ) {
			trace("SOMEPART&Y NR");
		} else {
			printSite( Resource.getString( 'start' ) );
		}
		*/

		var res = Resource.getString( 'start' );
		printSite( res );
	}

	public function doAbout() {
		printSite( Resource.getString( 'about' ) );
	}

	//inline function doStart() doDefault();
	//inline function doEvent() doDefault();
	//inline function doEvents() doDefault();
	//inline function do666() printSite( Resource.getString( '666' ) );
	//inline function doSpirits() printSite( Resource.getString( 'spirits' ) );

	/*
	//public function doLogin( ?username : String ) {
	public function doLogin( d : Dispatch ) {

		//trace( d );
		//trace( username );
		d.dispatch( new UserControl() );
		//var p = d.getParams();
		//Sys.print(p);
		//var postData = Web.getPostData();

		//Sys.print( Web.getPostData() );
		//Sys.print( Web.getPostData() );

		/*
		if( username == null ) {
			Sys.print( Resource.getString( 'login' ) );
		} else {
			Sys.print("LLOOGGIINN "+username);
		}
		* /
	}

	public function doSignin( d : Dispatch, args : { username : Null<String>, password : Null<String> } ) {
		trace(args);
		//d.dispatch( new UserControl().doSignIn() );
	}
	*/

	/*
	public function doDefault( site : String ) {
		if( site == '' ) site = 'event';
		var res = Resource.getString( site );
		if( res == null ) {
			Sys.print( '404' );
		} else {
			printSite( new Template( res ).execute({}) );
		}
	}
	*/

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
