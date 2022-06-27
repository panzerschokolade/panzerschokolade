package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

using om.ArrayTools;
//using om.Path;

class App {
    
    static function setRandomQuoteTitle() {
		document.title = Panzerschokolade.QUOTES.random().toUpperCase();
        var quoteElement = document.getElementById('roland-panzer-says');
        if(quoteElement != null) {
            quoteElement.textContent = document.title;
        } 
    }

    static function main() {
		window.onload = e -> {
            
            setRandomQuoteTitle();

			var timer = new haxe.Timer(2000);
			timer.run = setRandomQuoteTitle;

			//window.addEventListener('contextmenu', e -> e.preventDefault());
		}
	}
}
