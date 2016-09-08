package panzerschokolade;

import php.Web;
import sys.io.File;
import haxe.Template;
import haxe.web.Dispatch;

class Index {

	//static inline var ROOT = '/web/drylungs.at/web/';
	static inline var ROOT = '';

	//static var iWsAdmin = false;

	static function main() {

		var path = Web.getURI().substr( ROOT.length );
		var params = Web.getParams();

		var isMobile = om.Web.isMobile();

		Template.globals = {
			//title: '',
			//description: '',
			//copyright: '',
			mobile: isMobile,
			desktop: !isMobile,
			platform: isMobile?'mobile':'desktop',
		};

		var dispatcher = new Dispatch( path, params );
		dispatcher.onMeta = function(meta,value) {
			/*
			//trace(m,v);
			switch meta {
			case 'admin':
				if( !isAdmin ) {
					Sys.println( 'ADMIN ONLY' );
				}
			default:
			}
			*/
		}

		var root = new panzerschokolade.Router();
		try dispatcher.dispatch( root ) catch( e : DispatchError ) {
			Sys.print(e);
		}

		Web.flush();
	}
}
