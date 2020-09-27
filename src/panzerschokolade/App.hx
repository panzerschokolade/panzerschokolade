package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

using om.ArrayTools;
using om.Path;

class App {

	static function main() {

			/*
		var page = document.body.getAttribute('data-page');
		switch page {
		case '':
		case 'truth':

			var files = om.macro.FileSystem.readDirectory('/home/tong/dev/pro/disktree/panzerschokolade/bin/truth-media');

			var container = document.getElementById('thetruth');

			function showRandom() {

				var media = files.random();
				var ext = media.extension();

				var e : js.html.Element = switch ext {
				case 'jpg','png','gif': document.createImageElement();
				case 'mp4': document.createVideoElement();
				default: null;
				}
				e.setAttribute( 'src', 'truth-media/$media' );
				e.classList.add( 'media' );

				container.innerHTML = '';
				container.appendChild( e );
			}

			showRandom();

			container.onclick = function() {
				showRandom();
			}


		default:
		}
		*/
		
		
		var quote = Panzerschokolade.QUOTES.random();
		console.log( '%c'+quote.toUpperCase(), 'color:#C40131;font-size:120px;' );
		document.title = quote.toUpperCase();
		//document.title = new om.text.Creepy().encode( quote );

		/* var encoders : Array<om.text.Encoder> = [
			new om.text.Creepy(),
			new om.text.FlipRotate(),
			new om.text.Mirror(),
			new om.text.TheTrap(),
			//new om.text.NoneEncoder(),
			new om.text.CustomEncoder( s -> return s.toUpperCase() ),
		]; */

		var timer = new haxe.Timer( 3000 );
		timer.run = () -> {
			//var enc = encoders[Std.int(Math.random()*encoders.length)];
			var quote = Panzerschokolade.QUOTES.random();
			//var str = enc.encode( quote );
			var str = quote.toUpperCase();
			document.title = str;
		}

		//document.querySelector( 'header h2' ).textContent = quote;
		
		window.addEventListener( 'contextmenu', function(e) { e.preventDefault(); });

	}
}
