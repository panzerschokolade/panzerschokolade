package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

class App {

    /*
    //static var COLORS = ['#388250','#362214','#C8452E','#B0072A','#C40131','#CFB009','#D7C902','#FB0F94','#0A9FDF','#89B194'];
    static var CURSORS = ['n-resize','e-resize','s-resize','w-resize'];

    static var cursorIndex = 0;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );


        //var color = COLORS[index];
        //document.body.style.backgroundColor = color;

        document.body.style.cursor = CURSORS[cursorIndex];
        if( ++cursorIndex == CURSORS.length ) cursorIndex = 0;
    }
    */

    static function main() {

        window.onload = function() {

            console.log( '|>4|\\|7_3|25(|-|0|(014|)3' );

            //window.requestAnimationFrame( update );

            /*
            var timer = new haxe.Timer(200);
            timer.run = function() {
                document.body.style.cursor = CURSORS[cursorIndex];
                if( ++cursorIndex == CURSORS.length ) cursorIndex = 0;
            }
            */
        }
    }
}
