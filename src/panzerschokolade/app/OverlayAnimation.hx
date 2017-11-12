package panzerschokolade.app;

import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import three.animation.AnimationMixer;
import three.animation.AnimationClip;
import three.cameras.PerspectiveCamera;
import three.extras.SceneUtils;
import three.geometries.BoxGeometry;
import three.helpers.PointLightHelper;
import three.lights.AmbientLight;
import three.lights.PointLight;
import three.math.Color;
import three.materials.MeshBasicMaterial;
import three.materials.MeshPhongMaterial;
import three.materials.MeshLambertMaterial;
import three.loaders.JSONLoader;
import three.objects.Mesh;
import three.renderers.Renderer;
import three.renderers.WebGLRenderer;
import three.scenes.Scene;
//import panzerschokolade.three.Tesseract;

class OverlayAnimation {

	public var canvas(default,null) : CanvasElement;

	var renderer : Renderer;
	var timeLastFrame : Float;

	var scene : Scene;
	var camera : PerspectiveCamera;
	var mesh : Mesh;
	var pointLight1 : PointLight;
	var pointLight2 : PointLight;
	var pointLight3 : PointLight;
//	var tesseract : Tesseract;
	var dolphin : Mesh;

	var targetRotationX = 0.0;
	var targetRotationOnMouseDownX = 0.0;

	var targetRotationY = 0.0;
	var targetRotationOnMouseDownY = 0.0;

	var mouseX = 0;
	var mouseXOnMouseDown = 0.0;

	var mouseY = 0;
	var mouseYOnMouseDown = 0.0;

	var windowHalfX = window.innerWidth / 2;
	var windowHalfY = window.innerHeight / 2;

	var finalRotationY : Float;

	var mixer : AnimationMixer;

	public function new() {

		canvas = document.createCanvasElement();
		canvas.classList.add( 'overlay' );
		canvas.width = window.innerWidth;
		canvas.height = window.innerHeight;

		renderer = new WebGLRenderer( { canvas: canvas, antialias : false, alpha: true } );
		//renderer.setClearColor( new Color(0x000000) );
		//renderer = new CanvasRenderer( { antialias : true } );
		renderer.setSize( window.innerWidth, window.innerHeight );

		scene = new Scene();

		camera = new PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 0.001, 10000 );
		camera.position.set( 0, 0, 5 );
		camera.lookAt( scene.position );
		scene.add( camera );

		var ambientLight = new AmbientLight( 0x000000, 0.9 );
		scene.add(ambientLight);

		pointLight1 = new PointLight( 0xFB0F94 );
		pointLight1.position.set(5,5,0);
		scene.add( pointLight1 );

		pointLight2 = new PointLight( 0x0A9FDF );
		pointLight2.position.set(-3,-5,3);
		scene.add( pointLight2 );

		pointLight3 = new PointLight( 0xF6E10C );
		pointLight3.position.set(0,5,2);
		scene.add( pointLight3 );

		/*
		var spotLight = new SpotLight( 0x000000 );
		spotLight.position.set(0,0,10);
		spotLight.lookAt(scene.position);
		scene.add( spotLight );
		*/

		var material = new MeshPhongMaterial( {
			color: new Color(0xffffff), side: FrontSide, shininess: 0, opacity: 1
		} );
		//material.transparent = true;

		//tesseract = new Tesseract( 1.5, 0.2, 0.05, 0.01, material );
		//tesseract.rotation.z = -Math.PI/2;
		//scene.add( tesseract );

		new JSONLoader().load( 'mesh/horse.json',
			function(g,m) {
				dolphin = new Mesh( g, new MeshLambertMaterial( {
					//vertexColors: Colors.FaceColors,
					morphTargets: true
				} ) );
				var scaleFactor = 0.02;
				dolphin.scale.set( scaleFactor, scaleFactor, scaleFactor );
				dolphin.position.y = -1.8;
				scene.add( dolphin );

				mixer = new AnimationMixer( dolphin );

				var clip = AnimationClip.CreateFromMorphTargetSequence( 'gallop', g.morphTargets, 30 );
				mixer.clipAction( clip ).setDuration( 1 ).play();
			}
		);

		timeLastFrame = om.Time.now();

		document.body.addEventListener( 'mousedown', handleMouseDown, false );
        document.body.addEventListener( 'touchstart', handleTouchStart, false );
        document.body.addEventListener( 'touchmove', handleTouchMove, false );

		window.addEventListener( 'resize', handleWindowResize, false );
	}

	public function setSize( width : Int, height : Int ) {
		canvas.width = width;
		canvas.height = height;
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
		renderer.setSize( width, height );
	}

	public function update( time : Float ) {

		var now = om.Time.now();
		var delta = now - timeLastFrame;

		/*
		tesseract.rotation.x += delta/10000;
		tesseract.rotation.y += delta/5000;
		tesseract.rotation.z += delta/2500;
		tesseract.update( time );
		*/

		if( dolphin != null ) {

			mixer.update( delta * 0.001 );

			dolphin.rotation.y += ( targetRotationX - dolphin.rotation.y ) * 0.1;
			finalRotationY = (targetRotationY - dolphin.rotation.x);
			dolphin.rotation.x += finalRotationY * 0.05;
			//finalRotationY = (targetRotationY - dolphin.rotation.x);

			if (dolphin.rotation.x  <= 1 && dolphin.rotation.x >= -1 ) {
	   			dolphin.rotation.x += finalRotationY * 0.1;
			}
			if( dolphin.rotation.x  > 1 ) {
	  			dolphin.rotation.x = 1;
			}
			if( dolphin.rotation.x  < -1 ) {
				dolphin.rotation.x = -1;
			}
		}

		renderer.render( scene, camera );

		timeLastFrame = now;
	}

	function handleMouseDown(e) {

		//e.preventDefault();

		document.body.addEventListener( 'mousemove', handleMouseMove, false );
        document.body.addEventListener( 'mouseup', handleMouseUp, false );
        document.body.addEventListener( 'mouseout', handleMouseOut, false );

		mouseXOnMouseDown = e.clientX - windowHalfX;
        targetRotationOnMouseDownX = targetRotationX;

        mouseYOnMouseDown = e.clientY - windowHalfY;
        targetRotationOnMouseDownY = targetRotationY;
    }

	function handleMouseMove(e) {

		mouseX = Std.int( e.clientX - windowHalfX );
		mouseY = Std.int( e.clientY - windowHalfY );

		targetRotationY = targetRotationOnMouseDownY + (mouseY - mouseYOnMouseDown) * 0.02;
		targetRotationX = targetRotationOnMouseDownX + (mouseX - mouseXOnMouseDown) * 0.02;
    }

	function handleMouseUp(e) {
		document.body.removeEventListener( 'mousemove', handleMouseMove, false );
		document.body.removeEventListener( 'mouseup', handleMouseUp, false );
		document.body.removeEventListener( 'mouseout', handleMouseOut, false );
    }

	function handleMouseOut(e) {
		document.body.removeEventListener( 'mousemove', handleMouseMove, false );
        document.body.removeEventListener( 'mouseup', handleMouseUp, false );
        document.body.removeEventListener( 'mouseout', handleMouseOut, false );
    }

	function handleTouchStart(e) {

		if( e.touches.length == 1 ) {

            //e.preventDefault();

            mouseXOnMouseDown = untyped e.touches[0].pageX - windowHalfX;
            targetRotationOnMouseDownX = targetRotationX;

            mouseYOnMouseDown = untyped e.touches[0].pageY - windowHalfY;
            targetRotationOnMouseDownY = targetRotationY;
        }
    }

	function handleTouchMove(e) {

		if( e.touches.length == 1 ) {

            //e.preventDefault();

            mouseX = untyped e.touches[ 0 ].pageX - windowHalfX;
            targetRotationX = targetRotationOnMouseDownX + ( mouseX - mouseXOnMouseDown ) * 0.05;

            mouseY = untyped e.touches[ 0 ].pageY - windowHalfY;
            targetRotationY = targetRotationOnMouseDownY + (mouseY - mouseYOnMouseDown) * 0.05;
		}
    }

	function handleWindowResize(e) {
		setSize( window.innerWidth, window.innerHeight );
    }

}
