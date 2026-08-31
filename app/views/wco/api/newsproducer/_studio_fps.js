
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
let specsheet = null

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
import { TransformControls } from 'three/addons/controls/TransformControls.js';

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
let strafe_factor = 0.5
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

const DOOR_W = 0.9
const DOOR_H = 2.1
const DOOR_D = 0.1
const door_color = new THREE.Color( 0x8a6a4a )
const door_aim_color = new THREE.Color( 0xffff00 )
const door_geo = new THREE.BoxGeometry( DOOR_W, DOOR_H, DOOR_D )
const door_label_geo = new THREE.PlaneGeometry( DOOR_W, DOOR_H )
const doors = []
let door_inside = null
let last_created_door = null

function wrap_text( ctx, text, max_width ) {
  const words = String( text || '' ).replace( /_/g, ' ' ).split( /\s+/ ).filter( Boolean )
  const lines = []
  let line = ''
  words.forEach( word => {
    const test = line ? ( line + ' ' + word ) : word
    if ( ctx.measureText( test ).width <= max_width ) {
      line = test
    } else {
      if ( line ) lines.push( line )
      if ( ctx.measureText( word ).width <= max_width ) {
        line = word
      } else {
        let chunk = ''
        for ( let i = 0; i < word.length; i++ ) {
          const next = chunk + word[i]
          if ( ctx.measureText( next ).width <= max_width ) {
            chunk = next
          } else {
            if ( chunk ) lines.push( chunk )
            chunk = word[i]
          }
        }
        line = chunk
      }
    }
  } )
  if ( line ) lines.push( line )
  return lines
}

function door_label_texture( text ) {
  const canvas = document.createElement( 'canvas' )
  canvas.width = 512
  canvas.height = Math.round( 512 * DOOR_H / DOOR_W )
  const ctx = canvas.getContext( '2d' )
  const pad = 36
  const font_size = 72
  ctx.fillStyle = '#ffffff'
  ctx.font = 'bold ' + font_size + 'px sans-serif'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  const lines = wrap_text( ctx, text, canvas.width - pad * 2 )
  const line_h = font_size * 1.15
  const start_y = canvas.height / 2 - ( ( lines.length - 1 ) * line_h ) / 2
  lines.forEach( ( line, i ) => {
    ctx.fillText( line, canvas.width / 2, start_y + i * line_h )
  } )
  const tex = new THREE.CanvasTexture( canvas )
  tex.needsUpdate = true
  return tex
}

function make_door( marker ) {
  const name = marker.label || marker.name
  const pos = marker.position || {}
  const rot = marker.rotation || {}
  const mat = new THREE.MeshLambertMaterial( { color: door_color } )
  const mesh = new THREE.Mesh( door_geo, mat )
  mesh.position.set( pos.x || 0, pos.y || 0, pos.z || 0 )
  mesh.rotation.set(
    THREE.MathUtils.degToRad(rot.x || 0),
    THREE.MathUtils.degToRad(rot.y || 0),
    THREE.MathUtils.degToRad(rot.z || 0)
  )
  mesh.castShadow = true
  mesh.receiveShadow = true
  mesh.userData.scene_name = name
  mesh.userData.door_mat = mat

  const label_mat = new THREE.MeshBasicMaterial( {
    map: door_label_texture( name ),
    transparent: true,
    side: THREE.DoubleSide,
    depthWrite: false
  } )
  const front = new THREE.Mesh( door_label_geo, label_mat )
  front.position.set( 0, 0, DOOR_D / 2 + 0.006 )
  mesh.add( front )
  const back = new THREE.Mesh( door_label_geo, label_mat )
  back.position.set( 0, 0, -( DOOR_D / 2 + 0.006 ) )
  back.rotation.y = Math.PI
  mesh.add( back )

  scene.add( mesh )
  doors.push( mesh )
  return mesh
}

function clear_doors() {
  if ( door_helper ) {
    door_helper.detach()
    if ( door_helper_root ) door_helper_root.visible = false
  }
  doors.forEach( d => {
    if ( d.parent ) d.parent.remove( d )
  } )
  doors.length = 0
  door_inside = null
  last_created_door = null
}

function place_doors_from_specsheet() {
  clear_doors()
  const markers = specsheet && specsheet.markers
  if ( !markers || !markers.length ) return
  markers.forEach( make_door )
  if ( door_helper_on() ) set_door_helper( true )
}

let door_helper = null
let door_helper_root = null

function door_helper_on() {
  return $('input[name=doorHelper]').is(':checked') || $('input[name=doorRotate]').is(':checked')
}

function door_helper_mode() {
  if ($('input[name=doorRotate]').is(':checked')) return 'rotate'
  if ($('input[name=doorHelper]').is(':checked')) return 'translate'
  return null
}

function log_door_position() {
  const obj = door_helper && door_helper.object
  if ( !obj ) return
  logg( {
    x: obj.position.x,
    y: obj.position.y,
    z: obj.position.z,
    name: obj.userData.scene_name
  }, 'door position' )
}

function log_door_rotation() {
  const obj = door_helper && door_helper.object
  if ( !obj ) return
  logg( {
    x: THREE.MathUtils.radToDeg(obj.rotation.x),
    y: THREE.MathUtils.radToDeg(obj.rotation.y),
    z: THREE.MathUtils.radToDeg(obj.rotation.z),
    name: obj.userData.scene_name
  }, 'door rotation' )
}

function log_door_transform() {
  if ( door_helper_mode() === 'rotate' ) log_door_rotation()
  else log_door_position()
}

function ensure_door_helper() {
  if (door_helper) return
  door_helper = new TransformControls(camera, renderer.domElement)
  door_helper.addEventListener('objectChange', log_door_transform)
  door_helper_root = door_helper.getHelper ? door_helper.getHelper() : door_helper
  scene.add(door_helper_root)
}

function set_door_helper(on) {
  if (on) {
    if (document.pointerLockElement) document.exitPointerLock()
    ensure_door_helper()
    const target = last_created_door || doors[doors.length - 1]
    if (!target) {
      door_helper.detach()
      door_helper.enabled = false
      if (door_helper_root) door_helper_root.visible = false
      return
    }
    door_helper.enabled = true
    door_helper.setMode(door_helper_mode() || 'translate')
    door_helper.attach(target)
    if (door_helper_root) door_helper_root.visible = true
    log_door_transform()
  } else if (door_helper) {
    door_helper.detach()
    door_helper.enabled = false
    if (door_helper_root) door_helper_root.visible = false
  }
}

$('input[name=doorHelper]').on('change', function() {
  if (this.checked) $('input[name=doorRotate]').prop('checked', false)
  set_door_helper(door_helper_on())
})

$('input[name=doorRotate]').on('change', function() {
  if (this.checked) $('input[name=doorHelper]').prop('checked', false)
  set_door_helper(door_helper_on())
})

$('#createDoor').on('click', function() {
  last_created_door = make_door({ name: '', position: { x: 0, y: 0, z: 0 } })
  if (door_helper_on()) {
    if (document.pointerLockElement) document.exitPointerLock()
    ensure_door_helper()
    door_helper.enabled = true
    door_helper.setMode(door_helper_mode() || 'translate')
    door_helper.attach(last_created_door)
    if (door_helper_root) door_helper_root.visible = true
    log_door_transform()
  }
})

const aim_ray = new THREE.Raycaster()
const aim_dir = new THREE.Vector3()
const door_box = new THREE.Box3()
const player_box = new THREE.Box3()
let studio_loading = false

function player_in_door( mesh ) {
  mesh.updateMatrixWorld(true)
  door_box.setFromObject(mesh)
  door_box.expandByScalar(0.3)
  player_box.makeEmpty()
  player_box.expandByPoint(playerCollider.start)
  player_box.expandByPoint(playerCollider.end)
  player_box.expandByScalar(playerCollider.radius)
  return player_box.intersectsBox(door_box)
}

function check_door_portal() {
  const hit = doors.find( d => player_in_door( d ) )
  if ( hit && hit !== door_inside && !studio_loading ) {
    const dest = hit.userData.scene_name
    if ( dest && scenes[dest] && $('select.studio').val() !== dest ) {
      $('select.studio').val( dest )
      select_studio( dest )
    }
  }
  door_inside = hit || null
}

function door_from_hit( obj ) {
  while ( obj ) {
    if ( doors.indexOf( obj ) !== -1 ) return obj
    obj = obj.parent
  }
  return null
}

function update_door_aim() {
  camera.getWorldDirection( aim_dir )
  aim_ray.set( camera.position, aim_dir )
  const hits = aim_ray.intersectObjects( doors, true )
  const aimed = hits.length ? door_from_hit( hits[0].object ) : null
  doors.forEach( d => {
    const mat = d.userData.door_mat
    if ( d === aimed ) {
      mat.color.copy( door_aim_color )
      mat.emissive.setHex( 0x333300 )
    } else {
      mat.color.copy( door_color )
      mat.emissive.setHex( 0x000000 )
    }
  } )
}

document.addEventListener( 'keydown', ( event ) => {

  keyStates[ event.code ] = true;

} );

document.addEventListener( 'keyup', ( event ) => {

  keyStates[ event.code ] = false;

} );

container.addEventListener( 'mousedown', () => {

  if ( current_ctrl_type() !== 'fps' ) return
  if ( door_helper_on() ) return
  document.body.requestPointerLock();

  mouseTime = performance.now();

} );

document.addEventListener( 'mouseup', () => {

  if ( current_ctrl_type() !== 'fps' ) return
  if ( door_helper_on() ) return
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
  door_inside = doors.find( d => player_in_door( d ) ) || null
}

const loader = new GLTFLoader()

function specsheet_url(glb_url) {
  return glb_url.replace(/[^/]+$/, 'specsheet.json')
}

async function load_specsheet(glb_url) {
  specsheet = null
  try {
    const res = await fetch(specsheet_url(glb_url))
    if (!res.ok) return
    specsheet = await res.json()
    logg(specsheet, 'specsheet')
  } catch (error) {
    console.log(error)
  }
}

async function load_studio(s) {
  const cfg = scene_cfg(s)
  if (studio && studio.parent) studio.parent.remove(studio)
  if (octree_helper && octree_helper.parent) octree_helper.parent.remove(octree_helper)
  const gltf = await loader.loadAsync(cfg.url)
  await load_specsheet(cfg.url)
  studio = gltf.scene
  if (cfg.height) rescale(studio, { height: cfg.height })
  apply_studio_mesh(studio)
  const pos = specsheet && specsheet.position
  if (pos) studio.position.set(pos.x || 0, pos.y || 0, pos.z || 0)
  scene.add(studio)
  worldOctree = new Octree()
  worldOctree.fromGraphNode(studio)
  octree_helper = new OctreeHelper(worldOctree)
  octree_helper.visible = false
  scene.add(octree_helper)
  place_doors_from_specsheet()
}

async function select_studio(name) {
  if (!scenes[name] || studio_loading) return
  studio_loading = true
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
  studio_loading = false
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
    check_door_portal()
    teleportPlayerIfOob()
    updateSpheres( deltaTime )

  }

  if ( current_ctrl_type() === 'touch' && touch_controls ) {
    touch_controls.setPosition( camera.position.x, camera.position.y, camera.position.z )
    apply_touch_pose()
  }

  update_door_aim()
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
set_weapons(weapons_on())