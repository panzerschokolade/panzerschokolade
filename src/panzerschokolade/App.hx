package panzerschokolade;

import haxe.Timer;
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.ImageElement;

using om.ArrayTools;
using om.Path;

class App {

	static function main() {
	
		window.onload = e -> {

			var quote = Panzerschokolade.QUOTES.random();
			console.log( '%c'+quote.toUpperCase(), 'color:#C40131;font-size:120px;' );
			document.title = quote.toUpperCase();
	
			var timer = new haxe.Timer( 3000 );
			timer.run = () -> {
				var quote = Panzerschokolade.QUOTES.random();
				var str = quote.toUpperCase();
				document.title = str;
			}
			
			/* var timer = new haxe.Timer( 7000 + Std.int(Math.random()*5000) );
			timer.run = () -> {
				var quote = Panzerschokolade.QUOTES.random();
				var str = quote.toUpperCase();
				document.title = str;1
			} */
			
			/* function changeSZ() {
				var sz : ImageElement = cast document.getElementById('sz');
				if( sz != null ) {
					sz.src = 'image/panzer-'+(1+Std.int(Math.random()*5))+'.png';
				}
				Timer.delay( changeSZ, 3000 + Std.int(Math.random()*3000) );
			}
			Timer.delay( changeSZ, 1000 + Std.int(Math.random()*2000) ); */
	
			window.addEventListener( 'contextmenu', e -> e.preventDefault() );
		}
	}
}
