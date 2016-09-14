package panzerschokolade;

import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import Three;
import three.*;

class Dolphin {

	public var renderer(default,null) : Renderer;

	var scene : Scene;
	var camera : Camera;
	var mesh : Mesh;
	//var mixer : Dynamic;
	//var prevTime = Date.now().getTime();

	public function new( canvas : CanvasElement ) {

			scene = new Scene();

			camera = new PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 0.1, 20000 );
			camera.position.set( 0, 100, 300 );
			camera.lookAt( scene.position );
			scene.add( camera );

			renderer = new WebGLRenderer( { canvas: canvas, antialias : false, alpha: true } );
			//renderer = new CanvasRenderer( { antialias : true } );
			renderer.setSize( window.innerWidth, window.innerHeight );

			var light = new PointLight( 0xBB23A9, 2 );
			light.position.set( 100, 30, 100 );
			scene.add( light );
			//scene.add( new PointLightHelper( light, 10 ) );

			var light = new PointLight( 0x016EC0, 2 );
			light.position.set( -100, 30, 100 );
			scene.add( light );
			//scene.add( new PointLightHelper( light, 10 ) );

			var darkMaterial = new MeshPhongMaterial( { color:0xffffff, side:FrontSide, shininess:100, opacity: 0.5 } );
			darkMaterial.transparent = true;

			//var wireframeMaterial = new MeshBasicMaterial( { color: 0xffffff, wireframe: true, transparent: true } );
			//var material = [darkMaterial,wireframeMaterial];

			//mesh = cast SceneUtils.createMultiMaterialObject( new BoxGeometry( 50, 50, 50, 1, 1, 1 ), cast material );
			//mesh = cast SceneUtils.createMultiMaterialObject( new TetrahedronGeometry( 100, 0 ), cast material );
			//scene.add( mesh );

			var meshFiles = ['dolphin.json'];
			var meshFile = meshFiles[Std.int( Math.random() * meshFiles.length )];
			trace(meshFile);
			var loader = new JSONLoader();
			loader.load( 'mesh/$meshFile', function(g,m) {
			//loader.load( "mesh/dolphin.json", function(g,m) {

				/*
				mesh = new Mesh( g, new MeshLambertMaterial( {
					vertexColors: FaceColors,
					morphTargets: true
				} ) );

				mixer = untyped __js__('new AnimationMixer( mesh )');
				var clip = untyped AnimationClip.CreateFromMorphTargetSequence( 'gallop', g.morphTargets, 30 );
				mixer.clipAction( clip ).setDuration( 1 ).play();
				*/

				mesh = new Mesh( g, cast darkMaterial );
				//mesh = new Mesh(g,new MeshBasicMaterial());
				mesh.scale.set(50,50,50);
				scene.add( mesh );
			} );
	}

	public function update( time : Float ) {

		if( mesh == null )
			return;

		//mixer.update( ( time - prevTime ) * 0.001 );
		//prevTime = time;

		mesh.rotation.x += 0.01;
		mesh.rotation.y += 0.02;
		mesh.rotation.z += 0.02;

		renderer.render( scene, camera );
	}
}
