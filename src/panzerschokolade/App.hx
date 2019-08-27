package panzerschokolade;

#if js

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

using om.ArrayTools;

class App {

	static function main() {

		var page = document.body.getAttribute('data-page');
		switch page {
		case '':
		case 'truth':
			trace("THE TRUTH");
		default:
		}
		
		window.addEventListener( 'contextmenu', function(e) { e.preventDefault(); });
		
		console.log( '%c'+Panzerschokolade.QUOTES.random().toUpperCase(), 'color:#C40131;font-size:120px;' );
	}
}

#end
