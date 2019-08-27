package panzerschokolade;

#if sys

import om.Template;
import om.web.Dispatch;
import sys.FileSystem;
import sys.io.File;

using om.ArrayTools;
using om.Path;

class Web {

	function new() {}

	function doDefault( ?id : String ) {
		switch id {
		case null,'index':
			id = 'start';
		default:
		}
		printSite( id );
	}

	static function printSite( name : String, ?ctx : Dynamic ) {
		var content = getTemplate( name ).execute( ctx );
		Sys.print( getTemplate( 'index' ).execute( {
			content: content
		} ) );
	}

	static function getTemplate( name : String ) {
		return new Template( File.getContent( 'htm/$name.html' ) );
	}

	static function main() {
		
		/*
		var ROOT =
			#if debug
			'/pro/disktree/panzerschokolade/bin/';
			#else
			'';
			#end
			*/

		var host = om.Web.getHostName();
		//trace(host);
		//if( host == 'localhost' )

		var ROOT = switch host {
		case 'localhost': '/pro/disktree/panzerschokolade/bin/';
		default: '';
		}
		
		var uri = om.Web.getURI();
		//trace(uri);
		//return;

		var path = om.Web.getURI().substr( ROOT.length ).removeTrailingSlashes();
		var params = om.Web.getParams();
		var isMobile = om.System.isMobile();

		Template.globals = {
			title: Panzerschokolade.TITLE+' – '+Panzerschokolade.QUOTES.random().toUpperCase(),
			theme_color: '#000',
		};

		var root = new panzerschokolade.Web();
		var router = new Dispatch( path, params );
		router.dispatch( root );
	}

}

#end
