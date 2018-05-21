package panzerschokolade;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import haxe.Timer.delay;
import om.api.youtube.YouTube;
import panzerschokolade.app.VideoPlayer;
import panzerschokolade.app.OverlayAnimation;

using StringTools;

class App {

    static var VIDEOS = [
        'tzDubhD3f2A', // Jurassic Park Theme
        'GbUeK1PP7-s', // Home Alone Theme
        //'r4JmeXXRmZg', // GUY MADDIN - The Heart of the World
        //'138ajKRMzIY', // Ceephax Acid Crew
        'GI6dOS5ncFc', // 1 Hour of Ancient Egyptian Music
        //'6z2Ru_gjv90', // Menschen & Mächte
        //'pcakZb_P_nU' // Wully Bully - Chinese Syle
        //'0dEkm0Mczzw', // Persia & Armenia Music
        //'tFTo7wEEajM', // Surachai
        'fKBuKcDPjzM', // Psychic TV - The Orchids
        //'o81A31hlgEA', // Megaloschemos II (Bulgarian Orthodox Hymn)
        '_nwo4DSCFBc', // Beliefs Unlimited of John C. Lilly
        //'7p5T156l4tg', // Qiyan Music of Al-Andalus
        //'QzT46g-my0U' // Songs of Templars
    ];

    /*
    static var CURSORS = ['n-resize','e-resize','s-resize','w-resize'];
    static var cursorIndex = 0;
    */

    static var path : String;
    static var video : VideoPlayer;
//    static var overlay : OverlayAnimation;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

        //untyped document.getElementById('flyer').style.webkitFilter = 'hue-rotate('+hue+'deg)';
        //if( ++hue >= 360 ) hue = 0;

        //document.body.style.cursor = CURSORS[cursorIndex];
        //if( ++cursorIndex == CURSORS.length ) cursorIndex = 0;

    //    overlay.update( time );

        switch path {
        case 'about':
            //document.body.classList.toggle( 'invert' );
        }
    }

    static function handleWindowResize(e) {
        //overlay.setSize( window.innerWidth, window.innerHeight );
    }

    static function main() {

        window.onload = function() {

            path = window.location.pathname.substring( Panzerschokolade.ROOT.length );
            if( path.startsWith( '/' ) ) path = path.substr(1);

            console.log( '%c'+Panzerschokolade.TITLE, 'color:#C40131;font-size:60px;' );
            //console.debug( 'PATH:'+path+'|' );

            //document.title = Panzerschokolade.TITLE +' - '+ Panzerschokolade.QUOTES[Std.int(Math.random()*Panzerschokolade.QUOTES.length-1)].toUpperCase();

            //overlay = new OverlayAnimation();
            //document.body.appendChild( overlay.canvas );

            //var videoId : String = null;

            switch path {

            case '','start':
                //videoId = 'GI6dOS5ncFc';
                //videoId = 'GbUeK1PP7-s';

            case 'about':
                //videoId = 'r4JmeXXRmZg';
            //    overlay.canvas.style.opacity = '0.7';

            /*
            case '666':

                var canvas = document.createCanvasElement();
        		canvas.classList.add( 'pentagram' );
        		canvas.width = window.innerWidth;
        		canvas.height = window.innerHeight;
                document.body.appendChild( canvas );

        		var x = Std.int( window.innerWidth / 2 );
        		var y = Std.int( window.innerHeight / 2 );
        		var rotate = Math.PI/2;
        		var radiusW = window.innerWidth / 3.3;
        		var radiusH = window.innerHeight / 3.3;
        		var radius = (radiusW < radiusH) ? radiusW : radiusH;

        		var i = 0;
        		var j = 4 * Math.PI;
        		var k = 0.0;

                var ctx = canvas.getContext2d();
        		ctx.clearRect( 0, 0, canvas.width, canvas.height );

        		ctx.strokeStyle = '#00ff00';
        		ctx.lineWidth = 4;
        		ctx.beginPath();
        		while( k <= 4 * Math.PI ) {
        			var dx = x + radius * Math.cos( k + rotate );
        			var dy = y + radius * Math.sin( k + rotate );
        			ctx.lineTo( dx, dy );
        			k += (4 * Math.PI) / 5;
                    /*
        			if( i < 5 ) {
        				var cover = covers.children[i];
        				if( cover != null ) {
        					var coverRadius = cover.offsetWidth/2;
        					cover.style.left = Std.int( dx - coverRadius )+'px';
        					cover.style.top = Std.int( dy - coverRadius )+'px';
        				}
        			}
                    * /
        			i++;
        		}
        		ctx.moveTo( x + radius, y );
                ctx.arc( x, y, radius, 0, Math.PI * 2, false );
                ctx.closePath();
        		//ctx.stroke();
        		//ctx.lineWidth = 1;
                //ctx.arc( x, y, radius+10, 0, Math.PI * 2, false );

        		ctx.stroke();
                */

            default:
                //videoId = VIDEOS[Std.int( Math.random() * (VIDEOS.length) )];

            }

            //if( videoId == null ) videoId = VIDEOS[Std.int( Math.random() * (VIDEOS.length) )];
            //videoId = VIDEOS[Std.int( Math.random() * (VIDEOS.length-1) )];

            /*
            delay( function(){

                YouTube.init( function(){
                    trace( 'Youtube ready' );
                    video = new VideoPlayer( document.getElementById( 'youtube-player' ) );
                    //video.onEvent = function(e){}
                    video.init( function(){
                        trace( 'Videoplayer ready' );
                        video.play( videoId );
                    });
                });

            }, 500 );
            */

            window.requestAnimationFrame( update );

            window.addEventListener( 'contextmenu', function(e) {
                e.preventDefault();
                //window.location.href = 'about';
            });

            //document.body.addEventListener( 'mousemove', handleMouseMove, false );
            //window.addEventListener( 'resize', handleWindowResize, false );
        }
    }

}
