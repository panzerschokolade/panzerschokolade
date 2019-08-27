package panzerschokolade;

#if js

import js.Browser.console;
import js.Browser.window;

using om.ArrayTools;

class App {

	static function main() {

		var msg = Panzerschokolade.QUOTES.random().toUpperCase();
		console.log( '%c'+msg, 'color:#C40131;font-size:120px;' );

		window.addEventListener( 'contextmenu', function(e) { e.preventDefault(); });
	}
}

#end
