
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

let avatar_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/brunette.glb'
// let avatar_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/female_1.glb'
let scene_url  = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/scenes/001mb newsroom_green/scene.glb'

const wave_url = "https://cdn.jsdelivr.net/gh/met4citizen/TalkingHead@main/animations/walking.fbx"
// const wave_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/animations/F_Crouch_Strafe_Left.fbx'


import * as THREE from 'three'

import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'

import { TalkingHead } from "talkinghead"

const params = new URLSearchParams(window.location.search)

let config = {
    sampleRate: 8000,
    mood: 'neutral',
    gain: 0.5,
    lipsyncType: "visemes",
    lipsyncLang: "en",
    waitForAudioChunks: false,
    enableMetrics: false,
  }
let width = 854
let height = 480
let slug = '<ccapture>'
const fps = 24

let frame = 0
const api_key    = params.get('api_key')
const api_secret = params.get('api_secret')
const wco_origin = params.get('wco_origin')
const newspartial_id = params.get('newspartial_id')
let totalFrames

let camera, controls, head, renderer, scene
let faceTarget = new THREE.Vector3()
let chunkedInput = null
var capturer = new CCapture( { format: 'webm', framerate: fps } )
const gltfLoader = new GLTFLoader()
const fbxLoader = new FBXLoader()
const loading = document.getElementById('loading')

/*
**/
function point_camera_at_face(head) {
  // Camera at head level, pointed at the face
  const leftEye = new THREE.Vector3()
  const rightEye = new THREE.Vector3()
  head.objectLeftEye.getWorldPosition(leftEye)
  head.objectRightEye.getWorldPosition(rightEye)
  faceTarget.copy(leftEye).add(rightEye).multiplyScalar(0.5)

  const camPos = new THREE.Vector3(0, 0, 2)
  camPos.applyQuaternion(head.armature.quaternion)
  camPos.add(faceTarget)
  camera.position.copy(camPos)
  camera.lookAt(faceTarget)
}

/*
**/
function put_feet_at_origin(head) {
  // Put feet at the origin
  head.armature.updateMatrixWorld(true)
  const leftToe = new THREE.Vector3()
  const rightToe = new THREE.Vector3()
  head.objectLeftToeBase.getWorldPosition(leftToe)
  head.objectRightToeBase.getWorldPosition(rightToe)
  head.armature.position.set(
    -(leftToe.x + rightToe.x) / 2,
    -Math.min(leftToe.y, rightToe.y),
    -(leftToe.z + rightToe.z) / 2
  )
  head.armature.updateMatrixWorld(true)
}

/*
**/
function rescale(model, config) {
  const box = new THREE.Box3().setFromObject(model)
  const size = box.getSize(new THREE.Vector3())
  const currentHeight = size.y
  const scale = config.height / currentHeight
  model.scale.setScalar(scale)
}

/*
**/
function setup_light(scene) {
  const ambientLight = new THREE.AmbientLight( 0xffffff, 0.6 )
  scene.add( ambientLight )

  const hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444, 1.2 )
  hemiLight.position.set( 0, 20, 0 )
  scene.add( hemiLight )

  const keyLight = new THREE.DirectionalLight( 0xffffff, 2.5 )
  keyLight.position.set( 5, 10, 7 )
  scene.add( keyLight )

  const fillLight = new THREE.DirectionalLight( 0xffffff, 1.2 )
  fillLight.position.set( -5, 4, -2 )
  scene.add( fillLight )

  const rimLight = new THREE.DirectionalLight( 0xffffff, 0.8 )
  rimLight.position.set( 0, 6, -8 )
  scene.add( rimLight )
}

/*
**/
async function init() {
  if (newspartial_id) {
    try {
      const url = wco_origin + '/wco/api/newspartials/' + newspartial_id + '/config.json?api_key=' + api_key + '&api_secret=' + api_secret
      chunkedInput = await fetch(url).then(r => r.json())
      // API may return a JSON string payload
      // if (typeof chunkedInput === 'string') {
      //   chunkedInput = JSON.parse(chunkedInput)
      // }
      logg(chunkedInput, 'chunkedInput')
      const last = chunkedInput.wtimes.length-1
      const duration_ms = chunkedInput.wtimes[last] + chunkedInput.wdurations[last]
      logg(duration_ms, 'duration_ms')
      totalFrames = duration_ms/1000*fps
      width = chunkedInput.w_px
      height = chunkedInput.h_px
      slug = chunkedInput.slug
    } catch (error) {
      console.log(error)
      chunkedInput = null
      totalFrames = undefined
    }
  }

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xd3d3d3)

  /* fov — Camera frustum vertical field of view.
   * aspect — Camera frustum aspect ratio.
   * near — Camera frustum near plane.
   * far — Camera frustum far plane.
  **/
  camera = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera.position.set( 0, 2, 8 )
  camera.lookAt( 0, 0, 0 )

  setup_light(scene)

  const grid = new THREE.GridHelper(10, 10, 0x888888, 0xbbbbbb)
  grid.position.y = 0
  scene.add(grid)


  const studio = (await gltfLoader.loadAsync(scene_url)).scene
  rescale(studio, { height: 3.3 })
  scene.add(studio)


  head = new TalkingHead( document.getElementById('avatar'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  // logg(head, 'head')


  try {
    loading.textContent = "Loading..."
    await head.showAvatar( {
      url: avatar_url,
      body: 'F',
      avatarMood: 'neutral',
      lipsyncLang: 'en'
    }, (ev) => {
      if ( ev.lengthComputable ) {
        let val = Math.min(100,Math.round(ev.loaded/ev.total * 100 ))
        loading.textContent = "Loading " + val + "%"
      }
    })
    loading.style.display = 'none'

    head.armature.position.set(0, 0, 0)
    head.armature.rotation.set(0, 0, 0)
    scene.add(head.armature)

    put_feet_at_origin(head)

    point_camera_at_face(head)

    await head.streamStart({
      sampleRate: config.sampleRate,
      mood: config.mood,
      gain: config.gain,
      lipsyncType: config.lipsyncType,
      lipsyncLang: config.lipsyncLang,
      waitForAudioChunks: config.waitForAudioChunks,
      metrics: config.enableMetrics ? { enabled: true, intervalHz: config.metricsInterval } : { enabled: false }
    })

  } catch (error) {
    console.log(error)
    loading.textContent = error.toString()
  }


  //

  renderer = new THREE.WebGLRenderer( {
    alpha: false,
    antialias: true,
  } )
  renderer.setClearColor(0xd3d3d3, 1)
  renderer.setPixelRatio( 1 ); // window.devicePixelRatio )
  renderer.setSize( width, height )
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1
  renderer.outputColorSpace = THREE.SRGBColorSpace
  document.getElementById('rotatingC').appendChild( renderer.domElement )

  //

  controls = new OrbitControls( camera, renderer.domElement )
  controls.enableDamping = true
  controls.enableRotate = true
  controls.enablePan = true
  controls.enableZoom = true
  controls.minDistance = 0.5
  controls.maxDistance = 100
  controls.target.copy(faceTarget)
  controls.autoRotate = false
  controls.update()

  //

  window.addEventListener( 'resize', onWindowResize )


  // Keep rendering so OrbitControls drag/damping stay live
  renderer.setAnimationLoop(animate)

  // Start capture/audio only after the renderer exists
  if (newspartial_id && chunkedInput) {
    capturer.start()
    logg('capturer.start')
    head.streamAudio(chunkedInput)
  }
}

let semafore = false
document.addEventListener('DOMContentLoaded', async function(e) {
  if (!semafore) {
    semafore = true
    await init()
  }
})

function onWindowResize() {
  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize( width, height )
  render()
}

function render() {
  renderer.render( scene, camera )
}

function animate() {
  const t = frame / fps
  if (head) head.animate(1000/fps)
  controls.update()
  renderer.render( scene, camera )

  if (totalFrames) {
    capturer.capture( renderer.domElement )
    frame++
    if (frame >= totalFrames) {
      totalFrames = false
      renderer.setAnimationLoop(null)
      capturer.stop()
      logg('capturer.stop')

      if (false && newspartial_id) {
        capturer.save((blob) => {
          logg(blob, 'blob')
          renderer.domElement.toBlob((thumb) => {
            logg(thumb, 'thumb')
            const form = new FormData()
            form.append('video', blob, 'lips.webm')
            form.append('name', slug)
            form.append('thumb', thumb)
            form.append('newspartial_id', newspartial_id)

            fetch(wco_origin + '/wco/api/videos/?api_key=' + api_key + '&api_secret=' + api_secret, {
              method: 'POST',
              headers: {
                // 'Content-Type': 'video/webm',
              },
              body: form,
            }).then(() => {
              document.getElementById('status').textContent = 'finished'
              document.body.style.backgroundColor = 'gray'
            })
          })
        })
      }

      // Resume interactive orbit after capture
      renderer.setAnimationLoop(animate)
    }
  }
}


// Speak when clicked
document.getElementById('speak').addEventListener('click', function () {
  try {

  } catch (error) {
    console.log(error)
  }
})

document.getElementById('wave').addEventListener('click', async function () {
  try {
    // await ensureMixamoClip(head, wave_url)
    head.playAnimation(wave_url)
  } catch (error) {
    console.log(error)
  }
})

console.log('+++ loaded wco_models :: newsproducer :: studio_blue.js')
