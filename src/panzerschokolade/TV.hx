package panzerschokolade;

#if macro

import sys.FileSystem;

class TV {

	static function build() {
		var src = "web/tv/video_src";
		if( !FileSystem.exists(src) ) {
			Sys.println( 'source directory no found ($src)' );
			Sys.exit(1);
		}
		var dst = "web/tv/video";
		var videos = FileSystem.readDirectory( src );
		for( i in 0...videos.length ) {
			FileSystem.rename( '$src/'+videos[i], '$dst/'+(i+1)+'.mp4' );
		}
	}
}

#else

import js.Browser.document;
import js.Browser.window;
import js.html.VideoElement;

using om.ArrayTools;

class TV {

	static inline var BASE_URL = 'https://panzerschokolade.disktree.net';
	static inline var NUM_VIDEOS = 1577;

	static var playlist:Array<Int>;
	static var index = 0;
	static var video:VideoElement;

	static function loadNextVideo() {
		if (index++ >= NUM_VIDEOS) {
			index = 0;
			playlist = [for (i in 0...NUM_VIDEOS) i].shuffle();
		}
		video.src = '$BASE_URL/tv/video/' + playlist[index] + '.mp4';
	}

	static function main() {
        
		window.addEventListener( 'load', function() {

			video = cast document.body.querySelector('video.tv');
			
			playlist = [for (i in 0...NUM_VIDEOS) i].shuffle();
			video.onpause = function(e) {
				loadNextVideo();
			}
			loadNextVideo();

			document.body.ondblclick = e -> {
                document.documentElement.requestFullscreen();
                if( document.fullscreenElement == null ) {
                    document.documentElement.requestFullscreen();
                } else {
                    document.exitFullscreen();
                }
			}
		});
	}

}

#end
