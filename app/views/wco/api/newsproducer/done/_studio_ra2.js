
import * as THREE from 'three'

import Stats from 'three/addons/libs/stats.module.js'

import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'

const scene = new THREE.Scene()
scene.background = new THREE.Color( 0x88ccee )
scene.fog = new THREE.Fog( 0x88ccee, 0, 50 )

const frustumSize = 10
const camera = new THREE.OrthographicCamera(
  frustumSize * window.innerWidth / window.innerHeight / - 2,
  frustumSize * window.innerWidth / window.innerHeight / 2,
  frustumSize / 2,
  frustumSize / - 2,
  -100,
  1000
)
camera.position.set( 0, 6, 8 )
camera.lookAt( 0, 0, 0 )

const fillLight1 = new THREE.HemisphereLight( 0x8dc1de, 0x00668d, 1.5 )
fillLight1.position.set( 2, 1, 1 )
scene.add( fillLight1 )

const directionalLight = new THREE.DirectionalLight( 0xffffff, 2.5 )
directionalLight.position.set( - 5, 25, - 1 )
directionalLight.castShadow = true
directionalLight.shadow.camera.near = 0.01
directionalLight.shadow.camera.far = 500
directionalLight.shadow.camera.right = 30
directionalLight.shadow.camera.left = - 30
directionalLight.shadow.camera.top = 30
directionalLight.shadow.camera.bottom = - 30
directionalLight.shadow.mapSize.width = 1024
directionalLight.shadow.mapSize.height = 1024
directionalLight.shadow.radius = 4
directionalLight.shadow.bias = - 0.00006
scene.add( directionalLight )

const container = document.getElementById( 'rotatingC' )

const renderer = new THREE.WebGLRenderer( { antialias: true } )
renderer.setPixelRatio( window.devicePixelRatio )
renderer.setSize( window.innerWidth, window.innerHeight )
renderer.setAnimationLoop( animate )
renderer.shadowMap.enabled = true
renderer.shadowMap.type = THREE.VSMShadowMap
renderer.toneMapping = THREE.ACESFilmicToneMapping
container.appendChild( renderer.domElement )

const controls = new OrbitControls( camera, renderer.domElement )
controls.enableDamping = true
controls.target.set( 0, 0, 0 )
controls.update()

const stats = new Stats()
stats.domElement.style.position = 'absolute'
stats.domElement.style.top = '0px'
container.appendChild( stats.domElement )

window.addEventListener( 'resize', onWindowResize )

function onWindowResize() {

  const aspect = window.innerWidth / window.innerHeight
  camera.left = frustumSize * aspect / - 2
  camera.right = frustumSize * aspect / 2
  camera.top = frustumSize / 2
  camera.bottom = frustumSize / - 2
  camera.updateProjectionMatrix()

  renderer.setSize( window.innerWidth, window.innerHeight )

}

const loader = new GLTFLoader()
const scene_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/scenes/000mb%20collision-world/collision-world.glb'
const object_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/City_Pack/Big%20Building.glb'

function enableShadows( model ) {

  model.traverse( child => {

    if ( child.isMesh ) {

      child.castShadow = true
      child.receiveShadow = true

      if ( child.material && child.material.map ) {

        child.material.map.anisotropy = 4

      }

    }

  } )

}

function placeOnPoint( model, point ) {

  model.position.copy( point )
  model.updateMatrixWorld( true )
  const box = new THREE.Box3().setFromObject( model )
  model.position.y += point.y - box.min.y

}

function makeGhost( model ) {

  const ghost = model.clone( true )
  ghost.traverse( child => {

    if ( ! child.isMesh ) return

    const source = Array.isArray( child.material ) ? child.material : [ child.material ]
    const ghost_mats = source.map( mat => {

      const copy = mat.clone()
      copy.transparent = true
      copy.opacity = 0.4
      copy.depthWrite = false
      copy.needsUpdate = true
      return copy

    } )
    child.material = Array.isArray( child.material ) ? ghost_mats : ghost_mats[ 0 ]
    child.castShadow = false
    child.receiveShadow = false
    child.raycast = function () {}

  } )
  ghost.rotation.y = Math.PI / 4
  return ghost

}

const raycaster = new THREE.Raycaster()
const pointer = new THREE.Vector2()
const groundPlane = new THREE.Plane( new THREE.Vector3( 0, 1, 0 ), 0 )
const hitPoint = new THREE.Vector3()

let worldRoot = null
let objectTemplate = null
let objectGhost = null
let pointerDown = null

function getPointerHit( event ) {

  const rect = renderer.domElement.getBoundingClientRect()
  pointer.x = ( ( event.clientX - rect.left ) / rect.width ) * 2 - 1
  pointer.y = - ( ( event.clientY - rect.top ) / rect.height ) * 2 + 1
  raycaster.setFromCamera( pointer, camera )

  const targets = []
  if ( worldRoot ) targets.push( worldRoot )
  const hits = targets.length ? raycaster.intersectObjects( targets, true ) : []
  if ( hits.length ) return hits[ 0 ].point

  if ( raycaster.ray.intersectPlane( groundPlane, hitPoint ) ) return hitPoint
  return null

}

function moveGhost( event ) {

  if ( ! objectGhost ) return

  const point = getPointerHit( event )
  if ( ! point ) {

    objectGhost.visible = false
    return

  }

  objectGhost.visible = true
  placeOnPoint( objectGhost, point )

}

function placeObject( event ) {

  if ( ! objectTemplate ) return

  const point = getPointerHit( event )
  if ( ! point ) return

  const placed = objectTemplate.clone( true )
  enableShadows( placed )
  placed.rotation.y = Math.PI / 4
  placeOnPoint( placed, point )
  scene.add( placed )

}

loader.load( scene_url, ( gltf ) => {

  worldRoot = gltf.scene
  scene.add( worldRoot )
  worldRoot.rotation.y = Math.PI / 4
  enableShadows( worldRoot )

  worldRoot.updateMatrixWorld( true )
  const box = new THREE.Box3().setFromObject( worldRoot )
  const center = box.getCenter( new THREE.Vector3() )
  camera.position.set( center.x, center.y + 6, center.z + 8 )
  camera.lookAt( center )
  controls.target.copy( center )
  controls.update()

} )

loader.load( object_url, ( gltf ) => {

  objectTemplate = gltf.scene
  objectGhost = makeGhost( objectTemplate )
  objectGhost.visible = false
  scene.add( objectGhost )

} )

renderer.domElement.addEventListener( 'pointermove', moveGhost )

renderer.domElement.addEventListener( 'pointerdown', event => {

  pointerDown = { x: event.clientX, y: event.clientY }

} )

renderer.domElement.addEventListener( 'pointerup', event => {

  if ( ! pointerDown ) return

  const dx = event.clientX - pointerDown.x
  const dy = event.clientY - pointerDown.y
  pointerDown = null
  if ( dx * dx + dy * dy > 25 ) return

  placeObject( event )

} )

function animate() {

  controls.update()
  renderer.render( scene, camera )
  stats.update()

}
