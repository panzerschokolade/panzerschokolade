package panzerschokolade;

import php.Web;
import sys.io.File;
import haxe.Template;
import haxe.web.Dispatch;

class Index {

	//static var iWsAdmin = false;

	static function main() {


		var path = Web.getURI().substr( Panzerschokolade.ROOT.length );
		var params = Web.getParams();

		var isMobile = om.Web.isMobile();
		var description = Panzerschokolade.QUOTES[Std.int(Math.random()*Panzerschokolade.QUOTES.length)].toUpperCase();

		Template.globals = {

			mobile: isMobile,
			desktop: !isMobile,
			deviceType: isMobile ? 'mobile' : 'desktop',

			title: '|>4|\\|7_3|25(|-|0|(014|)3 - '+description,
			description: 'Mystery Of Mankind',
			themeColor: '#000',
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

		var root = new panzerschokolade.control.Router();
		try dispatcher.dispatch( root ) catch( e : DispatchError ) {
			Sys.print(e);
		}

		Web.flush();
	}
}
