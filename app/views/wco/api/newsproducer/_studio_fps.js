
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

const MODELS_ROOT = '/vendor/models'
const SCENE_STOR = 'studio'
$.each(scenes, (name) => {
  $('<option>', { value: name, text: name }).appendTo($('select.studio'))
})
try {
  const saved = localStorage.getItem( SCENE_STOR )
  if (saved && scenes[saved]) $('select.studio').val(saved)
} catch (error) {
  console.log(error)
}

let scene_url = scenes[$('select.studio').val()] || scenes.collision_world

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
container.style.touchAction = 'none'
container.style.width = width + 'px'
container.style.height = height + 'px'

const renderer = new THREE.WebGLRenderer( { antialias: true } );
renderer.setPixelRatio( window.devicePixelRatio );
renderer.setSize( width, height );
renderer.setAnimationLoop( animate );
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.VSMShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.domElement.style.touchAction = 'none'
container.appendChild( renderer.domElement );

let touch_controls = null

const GRAVITY = 30
let walk_speed = 12
const AIR_SPEED_FACTOR = 0.32
let strafe_factor = 0.22
let strafe_deadzone = 0.35

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

function weapons_on() {
  return $('input[name=weaponCtrl]').is(':checked')
}

function set_weapons( on ) {
  spheres.forEach( sphere => {
    sphere.mesh.visible = on
    if ( !on ) {
      sphere.collider.center.set( 0, -100, 0 )
      sphere.velocity.set( 0, 0, 0 )
      sphere.mesh.position.copy( sphere.collider.center )
    }
  } )
}

let worldOctree = new Octree()
let octree_helper = null
let studio = null

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

  if ( !weapons_on() ) return

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

  if ( !weapons_on() ) return

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
  const speedDelta = deltaTime * ( playerOnFloor ? walk_speed : walk_speed * AIR_SPEED_FACTOR )

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

function rescale(model, config) {
  const box = new THREE.Box3().setFromObject(model)
  const size = box.getSize(new THREE.Vector3())
  const currentHeight = size.y
  const scale = config.height / currentHeight
  model.scale.setScalar(scale)
}

function scene_cfg(s) {
  logg(s, 'scene_cfg')

  if (typeof s === 'string') {
    return { url: s } // , height: 3.3 }
  }
  if (typeof s.name === 'string') {
    return { ...s, url: `${MODELS_ROOT}/scenes/${s.name}/scene.glb` }
  }
  return s
}

function apply_studio_mesh(root) {
  root.traverse(child => {
    if (child.isMesh) {
      child.castShadow = true
      child.receiveShadow = true
      if (child.material && child.material.map) {
        child.material.map.anisotropy = 4
      }
    }
  })
}

function reset_player() {
  playerCollider.start.set(0, 0.35, 0)
  playerCollider.end.set(0, 1, 0)
  playerCollider.radius = 0.35
  playerVelocity.set(0, 0, 0)
  camera.position.copy(playerCollider.end)
  camera.rotation.set(0, 0, 0)
  if (touch_controls) {
    touch_controls.setPosition(0, 1, 0)
    touch_controls.setRotation(0, 0)
  }
}

const loader = new GLTFLoader()

async function load_studio(s) {
  const cfg = scene_cfg(s)
  logg(cfg, 'cfg')

  if (studio && studio.parent) studio.parent.remove(studio)
  if (octree_helper && octree_helper.parent) octree_helper.parent.remove(octree_helper)
  studio = (await loader.loadAsync(cfg.url)).scene
  if (cfg.height) rescale(studio, { height: cfg.height })
  apply_studio_mesh(studio)
  scene.add(studio)
  worldOctree = new Octree()
  worldOctree.fromGraphNode(studio)
  octree_helper = new OctreeHelper(worldOctree)
  octree_helper.visible = false
  scene.add(octree_helper)
}

async function select_studio(name) {
  if (!scenes[name]) return
  localStorage.setItem(SCENE_STOR, name)
  scene_url = scenes[name]
  $('#status').text('Loading...')
  $('#loading').text('Loading...')
  try {
    await load_studio(scene_url)
    reset_player()
    $('#status').text('loaded')
    $('#loading').text('loaded')
  } catch (error) {
    console.log(error)
    $('#status').text(error.toString())
    $('#loading').text(error.toString())
  }
}

$('select.studio').on('change', function() {
  select_studio($(this).val())
})
const initial_studio = $('select.studio').val() || 'collision_world'
if (!$('select.studio').val()) $('select.studio').val(initial_studio)
select_studio(initial_studio)

function teleportPlayerIfOob() {

  if ( camera.position.y <= - 25 ) {

    playerCollider.start.set( 0, 0.35, 0 );
    playerCollider.end.set( 0, 1, 0 );
    playerCollider.radius = 0.35;
    camera.position.copy( playerCollider.end );
    camera.rotation.set( 0, 0, 0 );
    if ( touch_controls ) {
      touch_controls.setPosition( 0, 1, 0 )
      touch_controls.setRotation( 0, 0 )
    }

  }

}

function touch_pad_controls( deltaTime ) {

  const speedDelta = deltaTime * ( playerOnFloor ? walk_speed : walk_speed * AIR_SPEED_FACTOR )
  const fwd = touch_controls.stick_y
  let side = touch_controls.stick_x
  if ( Math.abs( side ) < strafe_deadzone ) side = 0
  side *= strafe_factor

  if ( fwd ) {
    playerVelocity.add( getForwardVector().multiplyScalar( speedDelta * fwd ) )
  }

  if ( side ) {
    playerVelocity.add( getSideVector().multiplyScalar( speedDelta * side ) )
  }

}


function animate() {

  timer.update();

  const deltaTime = Math.min( 0.05, timer.getDelta() ) / STEPS_PER_FRAME;

  // we look for collisions in substeps to mitigate the risk of
  // an object traversing another too quickly for detection.

  for ( let i = 0; i < STEPS_PER_FRAME; i ++ ) {

    if ( current_ctrl_type() === 'touch' && touch_controls ) {
      touch_pad_controls( deltaTime )
    } else {
      controls( deltaTime )
    }

    updatePlayer( deltaTime )
    teleportPlayerIfOob()
    updateSpheres( deltaTime )

  }

  if ( current_ctrl_type() === 'touch' && touch_controls ) {
    touch_controls.setPosition( camera.position.x, camera.position.y, camera.position.z )
    apply_touch_pose()
  }

  renderer.render( scene, camera );

}

$('#fullScreen').on('click', () => {
  document.body.requestFullscreen()
})

const CTRL_TYPE_STOR = 'ctrl-type'

function current_ctrl_type() {
  return $('input[name=ctrl-type]:checked').val() || 'fps'
}

function apply_touch_pose() {
  const holder = touch_controls.fpsBody.getObjectByName( 'cameraHolder' )
  camera.rotation.set( holder.rotation.x, touch_controls.fpsBody.rotation.y, 0 )
}

function enable_touch_controls() {
  if ( document.pointerLockElement ) document.exitPointerLock()

  const pos = new THREE.Vector3()
  camera.getWorldPosition( pos )
  if ( pos.y < 0.2 ) pos.copy( playerCollider.end )
  const rx = camera.rotation.x
  const ry = camera.rotation.y

  if ( !touch_controls ) {
    camera.position.set( 0, 0, 0 )
    camera.rotation.set( 0, 0, 0 )
    touch_controls = new TouchControls( $( container ), camera, {
      speedFactor: 0.08,
      delta: 1,
      rotationFactor: 0.002,
      maxPitch: 55,
      hitTest: false,
      hitTestDistance: 1
    } )
    if ( camera.parent ) camera.parent.remove( camera )
    touch_controls.addToScene( scene )
  }

  touch_controls.enabled = true
  touch_controls.setPosition( pos.x, pos.y, pos.z )
  touch_controls.setRotation( rx, ry )
  camera.position.copy( pos )
  playerCollider.end.copy( pos )
  playerCollider.start.set( pos.x, pos.y - 0.65, pos.z )
  apply_touch_pose()
  $( '.movement-pad' ).show()
  $( '.rotation-pad' ).removeClass('is-active').css('display', '')
}

function disable_touch_controls() {
  if ( !touch_controls ) return
  touch_controls.enabled = false
  $( '.movement-pad' ).hide()
  $( '.rotation-pad' ).removeClass('is-active').css('display', '')
  playerCollider.end.copy( camera.position )
  playerCollider.start.set( camera.position.x, camera.position.y - 0.65, camera.position.z )
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

const WEAPON_CTRL_STOR = 'weaponCtrl'
try {
  const saved = localStorage.getItem(WEAPON_CTRL_STOR)
  if (saved !== null) $('input[name=weaponCtrl]').prop('checked', saved === 'on')
} catch (error) {
  console.log(error)
}
$('input[name=weaponCtrl]').on('change', function() {
  localStorage.setItem(WEAPON_CTRL_STOR, this.checked ? 'on' : 'off')
  set_weapons(this.checked)
})
set_weapons(weapons_on())