package panzerschokolade.three;

import three.Lib;

class Tesseract extends Object3D {

	public var speed : Float;
	public var t = 0.0;

	var vertsFixed = new Array<Vector3>();
	var vertsRotated = new Array<Vector3>();
	var vertexUnions : Array<Array<Int>>;
	var spheres = new Array<Mesh>();
	var cyls = new Array<Mesh>();

	public function new( size : Float,
						 sphereRadius : Float, cylinderRadius : Float,
						 speed = 0.01,
					 	 material : Material ) {

		super();
		this.speed = speed;

		var hsize = size/2;

		vertsFixed[0]  = new Vector3( -hsize, -hsize, -hsize );
		vertsFixed[1]  = new Vector3(  hsize, -hsize, -hsize );
		vertsFixed[2]  = new Vector3(  hsize,  hsize, -hsize );
		vertsFixed[3]  = new Vector3( -hsize,  hsize, -hsize );
		vertsFixed[4]  = new Vector3( -hsize, -hsize,  hsize );
		vertsFixed[5]  = new Vector3(  hsize, -hsize,  hsize );
		vertsFixed[6]  = new Vector3(  hsize,  hsize,  hsize );
		vertsFixed[7]  = new Vector3( -hsize,  hsize,  hsize );
		vertsFixed[8]  = new Vector3( -size,  -size,  -size );
		vertsFixed[9]  = new Vector3(  size,  -size,  -size );
		vertsFixed[10] = new Vector3(  size,   size,  -size );
		vertsFixed[11] = new Vector3( -size,   size,  -size );
		vertsFixed[12] = new Vector3( -size,  -size,   size );
		vertsFixed[13] = new Vector3(  size,  -size,   size );
		vertsFixed[14] = new Vector3(  size,   size,   size );
		vertsFixed[15] = new Vector3( -size,   size,   size );

		vertexUnions = [
			// small cube //
			[0,1],   [1,2],   [2,3],   [3,0],
			[0,4],   [1,5],   [2,6],   [3,7],
			[4,5],   [5,6],   [6,7],   [7,4],
			// diagonals //
			[0,8],   [1,9],   [2,10],  [3,11],
			[4,12],  [5,13],  [6,14],  [7,15],
			// big cube //
			[8,9],   [9,10],  [10,11], [11,8],
			[8,12],  [9,13],  [10,14], [11,15],
			[12,13], [13,14], [14,15], [15,12] ];

		//var material = new MeshPhongMaterial({
		/*
		var material = new MeshLambertMaterial({
			ambient: 0x030303,
			color: 0xdddddd,
			specular: 0xefefef,
			shininess: 100,
			//shading: SmoothShading
		});
		*/

		var geomSph = new SphereGeometry( sphereRadius, 16, 16 );
		for( i in 0...vertsFixed.length ) {
			var sphere = new Mesh( geomSph, material );
			sphere.position.copy( vertsFixed[i] );
			add( sphere );
			spheres[i] = sphere;
		}

		var geomCyl = new CylinderGeometry( cylinderRadius, cylinderRadius, 1, 16, 1, true );
		geomCyl.applyMatrix( new Matrix4().makeTranslation( 0, 0.5, 0 ) );
		for( i in 0...vertexUnions.length ) {
			var cyl = new Mesh( geomCyl, material );
			add( cyl );
			cyls[i] = cyl;
		}
	}

	public function update( time : Float ) {

		vertsRotated[0]  = catmullrom( vertsFixed[1],  vertsFixed[0],  vertsFixed[8],  vertsFixed[9],  t );
		vertsRotated[1]  = catmullrom( vertsFixed[9],  vertsFixed[1],  vertsFixed[0],  vertsFixed[8],  t );
		vertsRotated[9]  = catmullrom( vertsFixed[8],  vertsFixed[9],  vertsFixed[1],  vertsFixed[0],  t );
		vertsRotated[8]  = catmullrom( vertsFixed[0],  vertsFixed[8],  vertsFixed[9],  vertsFixed[1],  t );
		vertsRotated[3]  = new Vector3( vertsRotated[0].x, -vertsRotated[0].y,  vertsRotated[0].z );
		vertsRotated[2]  = new Vector3( vertsRotated[1].x, -vertsRotated[1].y,  vertsRotated[1].z );
		vertsRotated[10] = new Vector3( vertsRotated[9].x, -vertsRotated[9].y,  vertsRotated[9].z );
		vertsRotated[11] = new Vector3( vertsRotated[8].x, -vertsRotated[8].y,  vertsRotated[8].z );
		vertsRotated[4]  = new Vector3( vertsRotated[0].x,  vertsRotated[0].y, -vertsRotated[0].z );
		vertsRotated[5]  = new Vector3( vertsRotated[1].x,  vertsRotated[1].y, -vertsRotated[1].z );
		vertsRotated[13] = new Vector3( vertsRotated[9].x,  vertsRotated[9].y, -vertsRotated[9].z );
		vertsRotated[12] = new Vector3( vertsRotated[8].x,  vertsRotated[8].y, -vertsRotated[8].z );
		vertsRotated[7]  = new Vector3( vertsRotated[0].x, -vertsRotated[0].y, -vertsRotated[0].z );
		vertsRotated[6]  = new Vector3( vertsRotated[1].x, -vertsRotated[1].y, -vertsRotated[1].z );
		vertsRotated[14] = new Vector3( vertsRotated[9].x, -vertsRotated[9].y, -vertsRotated[9].z );
		vertsRotated[15] = new Vector3( vertsRotated[8].x, -vertsRotated[8].y, -vertsRotated[8].z );

		for( i in 0...vertexUnions.length ) {
			transformCylinderToP1P2( cyls[i], vertsRotated[vertexUnions[i][0]], vertsRotated[vertexUnions[i][1]] );
		}

		for( i in 0...vertsRotated.length ) {
			spheres[i].position.copy( vertsRotated[i] );
		}

		t += speed; //*delta
		if( t > 1.0 ) t = 0;
	}

	/*
	function createKnotMesh() : Mesh {
	}

	function createSideMesh() : Mesh {
	}
	*/

	static inline function catmullrom( p1 : Vector3, p2 : Vector3, p3 : Vector3, p4 : Vector3, i : Float ) : Vector3 {
		return new Vector3(
			catmullrom_unit( p1.x, p2.x, p3.x, p4.x, i ),
			catmullrom_unit( p1.y, p2.y, p3.y, p4.y, i ),
			catmullrom_unit( p1.z, p2.z, p3.z, p4.z, i )
		);
	}

	static function catmullrom_unit( a : Float, b : Float, c : Float, d : Float, i : Float ) : Float {
		return a * ((-i + 2) * i - 1) * i * 0.5 +
			   b * (((3 * i - 5) * i) * i + 2) * 0.5 +
			   c * ((-3 * i + 4) * i + 1) * i * 0.5 +
			   d * ((i - 1) * i * i) * 0.5;
	}

	static function transformCylinderToP1P2( cyl : Mesh, p1 : Vector3, p2 : Vector3 ) {

		cyl.updateMatrix();
		cyl.matrixAutoUpdate = false;
		cyl.matrix.makeTranslation( p1.x, p1.y, p1.z );

		var vector = new Vector3( 0, 0, 0 );
		vector.copy( p2 );
		vector.sub( p1 );

		var length = vector.length();

		// Take cross product of vector and up vector to get axis of rotation
		var yAxis = new Vector3( 0, 1, 0 );

		// Needed later for dot product, just do it now
		// A little lazy, should really copy it to a local Vector3
		vector.normalize();

		var rotationAxis = new Vector3();
		rotationAxis.crossVectors( vector, yAxis );
		if( rotationAxis.length() < 0.000001 ) {
			// Special case: if rotationAxis is just about zero, set to X axis,
			// so that the angle can be given as 0 or PI. This works ONLY
			// because we know one of the two axes is +Y.
			rotationAxis.set( 1, 0, 0 );
		}
		rotationAxis.normalize();

		// Take dot product of vector and up vector to get cosine of angle of rotation
		var theta = -Math.acos( vector.dot( yAxis ) );
		var rotMatrix = new Matrix4();
		rotMatrix.makeRotationAxis( rotationAxis, theta );

		cyl.matrix.multiply( rotMatrix );
		cyl.matrix.scale( new Vector3( 1, length, 1 ) );
	}
}
