
import * as THREE from 'three'

import Stats from 'three/addons/libs/stats.module.js'

import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'

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

loader.load( scene_url, ( gltf ) => {

  scene.add( gltf.scene )

  gltf.scene.traverse( child => {

    if ( child.isMesh ) {

      child.castShadow = true
      child.receiveShadow = true

      if ( child.material.map ) {

        child.material.map.anisotropy = 4

      }

    }

  } )

  const box = new THREE.Box3().setFromObject( gltf.scene )
  const center = box.getCenter( new THREE.Vector3() )
  camera.position.set( center.x, center.y + 6, center.z + 8 )
  camera.lookAt( center )

} )

function animate() {

  renderer.render( scene, camera )
  stats.update()

}
