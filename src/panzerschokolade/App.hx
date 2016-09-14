package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import om.api.youtube.YouTube;

class App {

    /*
    //static var COLORS = ['#388250','#362214','#C8452E','#B0072A','#C40131','#CFB009','#D7C902','#FB0F94','#0A9FDF','#89B194'];
    static var CURSORS = ['n-resize','e-resize','s-resize','w-resize'];

    static var cursorIndex = 0;
    */

    static var video : VideoPlayer;

    static var canvas : CanvasElement;
    static var dolphin : Dolphin;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

        //var color = COLORS[index];
        //document.body.style.backgroundColor = color;

        //document.body.style.cursor = CURSORS[cursorIndex];
        //if( ++cursorIndex == CURSORS.length ) cursorIndex = 0;

        dolphin.update( time );
    }

    static function handleWindowResize(e){
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        dolphin.renderer.setSize( window.innerWidth, window.innerHeight);
    }

    static function main() {

        window.onload = function() {

            console.log( Panzerschokolade.TITLE );

            document.title = Panzerschokolade.TITLE +' - '+ Panzerschokolade.QUOTES[Std.int(Math.random()*Panzerschokolade.QUOTES.length-1)].toUpperCase();

            window.addEventListener( 'contextmenu', function(e) {
                e.preventDefault();
            });


            YouTube.init( function(){

                trace( 'Youtube ready' );

                video = new VideoPlayer( document.getElementById( 'youtube-player' ) );
				video.onEvent = function(e){

                }

                video.init( function(){
                    trace( 'Videoplayer ready' );
                    var videoIds = ['GI6dOS5ncFc','6z2Ru_gjv90','rLpYnYJ1QVk'];
                    var videoId = videoIds[Std.int( Math.random() * (videoIds.length) )];
                    video.play( videoId );
                });
            });

            canvas = document.createCanvasElement();
            canvas.id = 'horse';
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            document.body.appendChild( canvas );

            dolphin = new panzerschokolade.Dolphin( canvas );

            window.requestAnimationFrame( update );

            window.addEventListener( 'resize', handleWindowResize, false );
        }
    }
}
