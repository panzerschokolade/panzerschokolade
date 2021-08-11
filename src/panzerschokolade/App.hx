package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

using om.ArrayTools;
using om.Path;

class App {

	static function main() {
		
		var quote = Panzerschokolade.QUOTES.random();
		console.log( '%c'+quote.toUpperCase(), 'color:#C40131;font-size:120px;' );
		document.title = quote.toUpperCase();

		var timer = new haxe.Timer( 3000 );
		timer.run = () -> {
			var quote = Panzerschokolade.QUOTES.random();
			var str = quote.toUpperCase();
			document.title = str;
		}

		window.addEventListener( 'contextmenu', e -> e.preventDefault() );
	}
}
