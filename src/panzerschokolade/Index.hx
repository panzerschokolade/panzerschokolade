package panzerschokolade;

import haxe.Template;
import haxe.web.Dispatch;
import php.Web;
import sys.io.File;

class Index {

	//static var isAdmin = false;

	static function main() {

		var path = Web.getURI().substr( Panzerschokolade.ROOT.length );
		var params = Web.getParams();
		var isMobile = om.Runtime.isMobile();
		var description = Panzerschokolade.QUOTES[Std.int(Math.random()*Panzerschokolade.QUOTES.length)].toUpperCase();

		Template.globals = {
			mobile: isMobile,
			desktop: !isMobile,
			deviceType: isMobile ? 'mobile' : 'desktop',
			title: 'ʍ¥§ŁɘȐӋ ๏Ӻ ʍДÑԞіŋÐ • '+description,
			description: 'Mystery Of Mankind',
			themeColor: '#000',
		};

		var router = new haxe.web.Dispatch( path, params );
		router.onMeta = function(meta,value) {
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
		try router.dispatch( root ) catch( e : DispatchError ) {
			Sys.print(e);
		}

		Web.flush();
	}
}
