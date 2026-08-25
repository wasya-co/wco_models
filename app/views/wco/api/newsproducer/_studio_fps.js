
/*
**/
const logg = (a, b="", c=null) => {
  if ('undefined' === typeof window) { return }
  c = "string" === typeof c ? c : b.replace(/\W/g, '')
  if (c.length > 0) {
    window[c] = a
  }
  console.log(`+++ ${b}:`, a) // eslint-disable-line no-console
}

let width = 50 // 854
let height = 50 // 480
function is_mobile() {
  return window.matchMedia('(max-width: 768px)').matches || /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent)
}
function size_canvas() {
  if (is_mobile()) {
    width = Math.round(window.innerWidth * 0.8)
    height = Math.round(window.innerHeight * 0.8)
  } else {
    width = 854
    height = 480
  }
}
size_canvas()
let slug = '<ccapture>'
const fps = 30


import * as THREE from 'three';

import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

import { Octree } from 'three/addons/math/Octree.js';
import { OctreeHelper } from 'three/addons/helpers/OctreeHelper.js';

import { Capsule } from 'three/addons/math/Capsule.js';

window.THREE = THREE
const TouchControls = window.TouchControls
const MovementPad = window.MovementPad
const RotationPad = window.RotationPad

const timer = new THREE.Timer();
timer.connect( document );

const scene = new THREE.Scene();
scene.background = new THREE.Color( 0x88ccee );
scene.fog = new THREE.Fog( 0x88ccee, 0, 50 );

const camera = new THREE.PerspectiveCamera( 70, width / height, 0.1, 1000 );
camera.rotation.order = 'YXZ';

const fillLight1 = new THREE.HemisphereLight( 0x8dc1de, 0x00668d, 1.5 );
fillLight1.position.set( 2, 1, 1 );
scene.add( fillLight1 );

const directionalLight = new THREE.DirectionalLight( 0xffffff, 2.5 );
directionalLight.position.set( - 5, 25, - 1 );
directionalLight.castShadow = true;
directionalLight.shadow.camera.near = 0.01;
directionalLight.shadow.camera.far = 500;
directionalLight.shadow.camera.right = 30;
directionalLight.shadow.camera.left = - 30;
directionalLight.shadow.camera.top	= 30;
directionalLight.shadow.camera.bottom = - 30;
directionalLight.shadow.mapSize.width = 1024;
directionalLight.shadow.mapSize.height = 1024;
directionalLight.shadow.radius = 4;
directionalLight.shadow.bias = - 0.00006;
scene.add( directionalLight );

const container = document.getElementById( 'rotatingC' );
container.style.width = width + 'px'
container.style.height = height + 'px'

const renderer = new THREE.WebGLRenderer( { antialias: true } );
renderer.setPixelRatio( window.devicePixelRatio );
renderer.setSize( width, height );
renderer.setAnimationLoop( animate );
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.VSMShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
container.appendChild( renderer.domElement );

let touch_controls = null

const GRAVITY = 30;

const NUM_SPHERES = 100;
const SPHERE_RADIUS = 0.2;

const STEPS_PER_FRAME = 5;

const sphereGeometry = new THREE.IcosahedronGeometry( SPHERE_RADIUS, 5 );
const sphereMaterial = new THREE.MeshLambertMaterial( { color: 0xdede8d } );

const spheres = [];
let sphereIdx = 0;

for ( let i = 0; i < NUM_SPHERES; i ++ ) {

  const sphere = new THREE.Mesh( sphereGeometry, sphereMaterial );
  sphere.castShadow = true;
  sphere.receiveShadow = true;

  scene.add( sphere );

  spheres.push( {
    mesh: sphere,
    collider: new THREE.Sphere( new THREE.Vector3( 0, - 100, 0 ), SPHERE_RADIUS ),
    velocity: new THREE.Vector3()
  } );

}

const worldOctree = new Octree();

const playerCollider = new Capsule( new THREE.Vector3( 0, 0.35, 0 ), new THREE.Vector3( 0, 1, 0 ), 0.35 );

const playerVelocity = new THREE.Vector3();
const playerDirection = new THREE.Vector3();

let playerOnFloor = false;
let mouseTime = 0;

const keyStates = {};

const vector1 = new THREE.Vector3();
const vector2 = new THREE.Vector3();
const vector3 = new THREE.Vector3();

document.addEventListener( 'keydown', ( event ) => {

  keyStates[ event.code ] = true;

} );

document.addEventListener( 'keyup', ( event ) => {

  keyStates[ event.code ] = false;

} );

container.addEventListener( 'mousedown', () => {

  if ( current_ctrl_type() !== 'fps' ) return
  document.body.requestPointerLock();

  mouseTime = performance.now();

} );

document.addEventListener( 'mouseup', () => {

  if ( current_ctrl_type() !== 'fps' ) return
  if ( document.pointerLockElement !== null ) throwBall();

} );

document.body.addEventListener( 'mousemove', ( event ) => {

  if ( current_ctrl_type() !== 'fps' ) return
  if ( document.pointerLockElement === document.body ) {

    camera.rotation.y -= event.movementX / 500;
    camera.rotation.x -= event.movementY / 500;

  }

} );

window.addEventListener( 'resize', onWindowResize );

function onWindowResize() {

  size_canvas()
  container.style.width = width + 'px'
  container.style.height = height + 'px'
  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize( width, height )

}

function throwBall() {

  const sphere = spheres[ sphereIdx ];

  camera.getWorldDirection( playerDirection );

  sphere.collider.center.copy( playerCollider.end ).addScaledVector( playerDirection, playerCollider.radius * 1.5 );

  // throw the ball with more force if we hold the button longer, and if we move forward

  const impulse = 15 + 30 * ( 1 - Math.exp( ( mouseTime - performance.now() ) * 0.001 ) );

  sphere.velocity.copy( playerDirection ).multiplyScalar( impulse );
  sphere.velocity.addScaledVector( playerVelocity, 2 );

  sphereIdx = ( sphereIdx + 1 ) % spheres.length;

}

function playerCollisions() {

  const result = worldOctree.capsuleIntersect( playerCollider );

  playerOnFloor = false;

  if ( result ) {

    // determine if the surface we bumped into is something we can stand on

    playerOnFloor = result.normal.y >= 0.15; // allow slopes up to ~81° but ignore sheer vertical walls

    if ( ! playerOnFloor ) {

      playerVelocity.addScaledVector( result.normal, - result.normal.dot( playerVelocity ) );

    }

    if ( result.depth >= 1e-10 ) {

      playerCollider.translate( result.normal.multiplyScalar( result.depth ) );

    }

  }

}

function updatePlayer( deltaTime ) {

  let damping = Math.exp( - 4 * deltaTime ) - 1;

  if ( ! playerOnFloor ) {

    playerVelocity.y -= GRAVITY * deltaTime;

    // small air resistance
    damping *= 0.1;

  }

  playerVelocity.addScaledVector( playerVelocity, damping );

  const deltaPosition = playerVelocity.clone().multiplyScalar( deltaTime );
  playerCollider.translate( deltaPosition );

  playerCollisions();

  camera.position.copy( playerCollider.end );

}

function playerSphereCollision( sphere ) {

  const center = vector1.addVectors( playerCollider.start, playerCollider.end ).multiplyScalar( 0.5 );

  const sphere_center = sphere.collider.center;

  const r = playerCollider.radius + sphere.collider.radius;
  const r2 = r * r;

  // approximation: player = 3 spheres

  for ( const point of [ playerCollider.start, playerCollider.end, center ] ) {

    const d2 = point.distanceToSquared( sphere_center );

    if ( d2 < r2 ) {

      const normal = vector1.subVectors( point, sphere_center ).normalize();
      const v1 = vector2.copy( normal ).multiplyScalar( normal.dot( playerVelocity ) );
      const v2 = vector3.copy( normal ).multiplyScalar( normal.dot( sphere.velocity ) );

      playerVelocity.add( v2 ).sub( v1 );
      sphere.velocity.add( v1 ).sub( v2 );

      const d = ( r - Math.sqrt( d2 ) ) / 2;
      sphere_center.addScaledVector( normal, - d );

    }

  }

}

function spheresCollisions() {

  for ( let i = 0, length = spheres.length; i < length; i ++ ) {

    const s1 = spheres[ i ];

    for ( let j = i + 1; j < length; j ++ ) {

      const s2 = spheres[ j ];

      const d2 = s1.collider.center.distanceToSquared( s2.collider.center );
      const r = s1.collider.radius + s2.collider.radius;
      const r2 = r * r;

      if ( d2 < r2 ) {

        const normal = vector1.subVectors( s1.collider.center, s2.collider.center ).normalize();
        const v1 = vector2.copy( normal ).multiplyScalar( normal.dot( s1.velocity ) );
        const v2 = vector3.copy( normal ).multiplyScalar( normal.dot( s2.velocity ) );

        s1.velocity.add( v2 ).sub( v1 );
        s2.velocity.add( v1 ).sub( v2 );

        const d = ( r - Math.sqrt( d2 ) ) / 2;

        s1.collider.center.addScaledVector( normal, d );
        s2.collider.center.addScaledVector( normal, - d );

      }

    }

  }

}

function updateSpheres( deltaTime ) {

  spheres.forEach( sphere => {

    sphere.collider.center.addScaledVector( sphere.velocity, deltaTime );

    const result = worldOctree.sphereIntersect( sphere.collider );

    if ( result ) {

      sphere.velocity.addScaledVector( result.normal, - result.normal.dot( sphere.velocity ) * 1.5 );
      sphere.collider.center.add( result.normal.multiplyScalar( result.depth ) );

    } else {

      sphere.velocity.y -= GRAVITY * deltaTime;

    }

    const damping = Math.exp( - 1.5 * deltaTime ) - 1;
    sphere.velocity.addScaledVector( sphere.velocity, damping );

    playerSphereCollision( sphere );

  } );

  spheresCollisions();

  for ( const sphere of spheres ) {

    sphere.mesh.position.copy( sphere.collider.center );

  }

}

function getForwardVector() {

  camera.getWorldDirection( playerDirection );
  playerDirection.y = 0;
  playerDirection.normalize();

  return playerDirection;

}

function getSideVector() {

  camera.getWorldDirection( playerDirection );
  playerDirection.y = 0;
  playerDirection.normalize();
  playerDirection.cross( camera.up );

  return playerDirection;

}

function controls( deltaTime ) {

  // gives a bit of air control
  const speedDelta = deltaTime * ( playerOnFloor ? 25 : 8 );

  if ( keyStates[ 'KeyW' ] ) {

    playerVelocity.add( getForwardVector().multiplyScalar( speedDelta ) );

  }

  if ( keyStates[ 'KeyS' ] ) {

    playerVelocity.add( getForwardVector().multiplyScalar( - speedDelta ) );

  }

  if ( keyStates[ 'KeyA' ] ) {

    playerVelocity.add( getSideVector().multiplyScalar( - speedDelta ) );

  }

  if ( keyStates[ 'KeyD' ] ) {

    playerVelocity.add( getSideVector().multiplyScalar( speedDelta ) );

  }

  if ( playerOnFloor ) {

    if ( keyStates[ 'Space' ] ) {

      playerVelocity.y = 15;

    }

  }

}

const loader = new GLTFLoader().setPath( '/vendor/models/scenes/' );

loader.load( '000mb collision-world/collision-world.glb', ( gltf ) => {

  scene.add( gltf.scene );

  worldOctree.fromGraphNode( gltf.scene );

  gltf.scene.traverse( child => {

    if ( child.isMesh ) {

      child.castShadow = true;
      child.receiveShadow = true;

      if ( child.material.map ) {

        child.material.map.anisotropy = 4;

      }

    }

  } );

  const helper = new OctreeHelper( worldOctree );
  helper.visible = false;
  scene.add( helper );

} );

function teleportPlayerIfOob() {

  if ( camera.position.y <= - 25 ) {

    playerCollider.start.set( 0, 0.35, 0 );
    playerCollider.end.set( 0, 1, 0 );
    playerCollider.radius = 0.35;
    camera.position.copy( playerCollider.end );
    camera.rotation.set( 0, 0, 0 );

  }

}


function animate() {

  timer.update();

  const deltaTime = Math.min( 0.05, timer.getDelta() ) / STEPS_PER_FRAME;

  // we look for collisions in substeps to mitigate the risk of
  // an object traversing another too quickly for detection.

  for ( let i = 0; i < STEPS_PER_FRAME; i ++ ) {

    if ( current_ctrl_type() !== 'touch' ) {
      controls( deltaTime );
      updatePlayer( deltaTime );
      teleportPlayerIfOob();
    }

    updateSpheres( deltaTime );

  }

  if ( current_ctrl_type() === 'touch' && touch_controls ) touch_controls.update()

  renderer.render( scene, camera );

}

$('#fullScreen').on('click', () => {
  document.body.requestFullscreen()
})

const CTRL_TYPE_STOR = 'ctrl-type'

function current_ctrl_type() {
  return $('input[name=ctrl-type]:checked').val() || 'fps'
}

function enable_touch_controls() {
  if ( document.pointerLockElement ) document.exitPointerLock()
  if ( !touch_controls ) {
    const pos = camera.position.clone()
    const rx = camera.rotation.x
    const ry = camera.rotation.y
    camera.position.set( 0, 0, 0 )
    camera.rotation.set( 0, 0, 0 )
    touch_controls = new TouchControls( $( container ), camera, {
      speedFactor: 0.5,
      delta: 1,
      rotationFactor: 0.002,
      maxPitch: 55,
      hitTest: true,
      hitTestDistance: 1
    } )
    touch_controls.setPosition( pos.x, pos.y, pos.z )
    touch_controls.setRotation( rx, ry )
    touch_controls.addToScene( scene )
    return
  }
  touch_controls.enabled = true
  const holder = touch_controls.fpsBody.getObjectByName( 'cameraHolder' )
  if ( !camera.parent && holder ) holder.add( camera )
  if ( !touch_controls.fpsBody.parent ) scene.add( touch_controls.fpsBody )
  $( '.movement-pad, .rotation-pad' ).show()
}

function disable_touch_controls() {
  if ( !touch_controls ) return
  touch_controls.enabled = false
  $( '.movement-pad, .rotation-pad' ).hide()
  const worldPos = new THREE.Vector3()
  camera.getWorldPosition( worldPos )
  const holder = touch_controls.fpsBody.getObjectByName( 'cameraHolder' )
  const rx = holder ? holder.rotation.x : camera.rotation.x
  const ry = touch_controls.fpsBody.rotation.y
  if ( camera.parent ) camera.parent.remove( camera )
  if ( touch_controls.fpsBody.parent ) scene.remove( touch_controls.fpsBody )
  camera.position.copy( worldPos )
  camera.rotation.set( rx, ry, 0 )
  playerCollider.end.copy( worldPos )
  playerCollider.start.set( worldPos.x, worldPos.y - 0.65, worldPos.z )
}

function set_ctrl_type( type ) {
  if ( type === 'touch' ) enable_touch_controls()
  else disable_touch_controls()
}

try {
  const saved = localStorage.getItem(CTRL_TYPE_STOR)
  if (saved) $(`input[name=ctrl-type][value="${saved}"]`).prop('checked', true)
} catch (error) {
  console.log(error)
}
$('input[name=ctrl-type]').on('change', function() {
  if (!this.checked) return
  localStorage.setItem(CTRL_TYPE_STOR, this.value)
  set_ctrl_type(this.value)
})
set_ctrl_type(current_ctrl_type())