package panzerschokolade;

import js.Browser.document;
import js.Browser.window;
import js.html.VideoElement;

using om.ArrayTools;

class TV {
	static inline var NUM_VIDEOS = 1026;

	static var playlist:Array<Int>;
	static var index = 0;
	static var video:VideoElement;

	static function loadNextVideo() {
		if (index++ >= NUM_VIDEOS) {
			index = 0;
		}
		video.src = 'tv/video/' + playlist[index] + '.mp4';
	}

	static function main() {
        
		window.onload = function() {

			video = cast document.body.querySelector('video');
			playlist = [for (i in 0...NUM_VIDEOS) i].shuffle();
			video.onpause = function(e) {
				loadNextVideo();
			}
			loadNextVideo();

			document.body.onclick = e -> {
                document.documentElement.requestFullscreen();
                if( document.fullscreenElement == null ) {
                    document.documentElement.requestFullscreen();
                } else {
                    document.exitFullscreen();
                }
			}
		}
	}
}
