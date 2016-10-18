package panzerschokolade.app;

import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.DivElement;
import om.api.youtube.YouTubePlayer;

class VideoPlayer {

	public dynamic function onEvent( e : String ) {}

	public var element(default,null) : Element;
	public var isPlaying(default,null) = false;

	var player : YouTubePlayer;

	public function new( element : Element ) {
		this.element = element;
	}

	public function init( callback : Void->Void ) {
		player = new YouTubePlayer( element.id, {
			width: '300',
			height: '200',
			playerVars: {
				controls: no,
				color: white,
				autoplay: 0,
				disablekb:0,
				fs: 0,
				iv_load_policy: 3,
				//enablejsapi: 1,
				modestbranding: 1,
				showinfo: 0
			},
			events: {
				'onReady': function(e){
					player.setPlaybackQuality( small );
					callback();
				},
				'onStateChange': handlePlayerStateChange,
				'onPlaybackQualityChange': handlePlaybackQualityChange,
				'onPlaybackRateChange': handlePlaybackRateChange,
				'onError': handlePlayerError,
				//'onApiChange': handlePlayerAPIChange
			}
		});
	}

	public function play( videoId : String ) {
		player.loadVideoById( videoId );
	}

	public inline function stop() {
		player.stopVideo();
	}

	public inline function setPlaybackQuality( quality : PlaybackQuality ) {
		player.setPlaybackQuality( quality );
	}

	function handlePlayerStateChange(e) {
		//trace(e);
		//onEvent( e.data );
		/*
		switch e {
		case video_cued:
			//var pl = player.getPlaylist();
			//trace( pl );
			//var i = player.getPlaylistIndex();
			//trace( i );
			//video.play();
		default:
		}
		*/
	}

	function handlePlaybackQualityChange(e) {
		//trace(e);
	}

	function handlePlaybackRateChange(e) {
		//trace(e);
	}

	function handlePlayerError(e) {
		//trace(e);
		//onEvent( error( e.data ) );
	}
}
