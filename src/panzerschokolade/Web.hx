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
		var path = 'htm/$name.html';
		if( !FileSystem.exists( path ) ) path = 'htm/404.html';
		return new Template( File.getContent( path ) );
	}

	static function main() {
	
		var host = om.Web.getHostName();
		var uri = om.Web.getURI();
		var params = om.Web.getParams();

		var ROOT = switch host {
		case 'localhost': '/pro/disktree/panzerschokolade/bin/';
		default: '';
		}
		
		var path = uri.substr( ROOT.length ).removeTrailingSlashes();
		var isMobile = om.System.isMobile();

		Template.globals = {
			title: Panzerschokolade.TITLE+' – '+Panzerschokolade.QUOTES.random().toUpperCase(),
			page: path,
			theme_color: '#000',
		};

		var root = new panzerschokolade.Web();
		var router = new Dispatch( path, params );
		router.dispatch( root );
	}

}

#end
