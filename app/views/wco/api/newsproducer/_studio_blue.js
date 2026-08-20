
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

let avatar_brunette_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/brunette/model.glb'
let avatar_avaturn_url  = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/avaturn/model.glb'
let avatar_45_url       = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/extra/45.glb'
let avatar_mula_url     = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/avatars/mula/model.glb'


let scene_url  = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/scenes/001mb newsroom_green/scene.glb'

// let wave_url = "https://cdn.jsdelivr.net/gh/met4citizen/TalkingHead@main/animations/walking.fbx"
// let wave_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/animations/F_Crouch_Strafe_Left.fbx'
let wave_url = 'https://wco-drupal-prod.s3.amazonaws.com/public/2026-08/F_Talking_Variations_004.fbx'
// let wave_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.2.0/public/vendor/models/animations/catwalk.fbx'


let avatar_1_url = avatar_brunette_url
let avatar_2_url = avatar_45_url
// let avatar_3_url = avatar_mula_url



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
let lastAnimTime = 0
let capturing = false
let captureFrame = 0
let captureTotal = 0
const api_key    = params.get('api_key')
const api_secret = params.get('api_secret')
const wco_origin = params.get('wco_origin')
const newspartial_id = params.get('newspartial_id')
let totalFrames

let camera, camera_1, camera_2, camera_3
let controls, renderer, scene
let head, head_1, head_2, head_3
let faceTarget = new THREE.Vector3()
const cameraTargets = {
  '1': new THREE.Vector3(0, 1.5, 0),
  '2': new THREE.Vector3(1, 1.5, 0),
  '3': new THREE.Vector3(0.5, 1.2, 0),
}
let cameraTransition = null
const CAMERA_BLEND_MS = 900
let chunkedInput = null
const lights = {}
const LIGHT_CTRL_KEY = 'wco.studio_blue.light-ctrl'
const HEAD_CTRL_KEY = 'wco.studio_blue.head-ctrl'
const CAMERA_CTRL_KEY = 'wco.studio_blue.camera-ctrl'
var capturer = new CCapture( { format: 'webm', framerate: fps } )
const gltfLoader = new GLTFLoader()
const fbxLoader = new FBXLoader()
const loading = document.getElementById('loading')

/*
**/
function point_camera_at_face(_camera, _head, targetKey) {
  const leftEye = new THREE.Vector3()
  const rightEye = new THREE.Vector3()
  _head.objectLeftEye.getWorldPosition(leftEye)
  _head.objectRightEye.getWorldPosition(rightEye)
  faceTarget.copy(leftEye).add(rightEye).multiplyScalar(0.5)

  const camPos = new THREE.Vector3(0, 0, 2)
  camPos.applyQuaternion(_head.armature.quaternion)
  camPos.add(faceTarget)
  _camera.position.copy(camPos)
  _camera.lookAt(faceTarget)
  if (targetKey) cameraTargets[targetKey].copy(faceTarget)
}

/*
**/
function put_feet_at_origin(_head) {
  // Put feet at the origin
  _head.armature.updateMatrixWorld(true)
  const leftToe = new THREE.Vector3()
  const rightToe = new THREE.Vector3()
  _head.objectLeftToeBase.getWorldPosition(leftToe)
  _head.objectRightToeBase.getWorldPosition(rightToe)
  _head.armature.position.set(
    -(leftToe.x + rightToe.x) / 2,
    -Math.min(leftToe.y, rightToe.y),
    -(leftToe.z + rightToe.z) / 2
  )
  _head.armature.updateMatrixWorld(true)
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
  lights.ambientLight = new THREE.AmbientLight( 0xffffff, 0.6 )
  scene.add( lights.ambientLight )

  lights.hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444, 1.2 )
  lights.hemiLight.position.set( 0, 20, 0 )
  scene.add( lights.hemiLight )

  lights.keyLight = new THREE.DirectionalLight( 0xffffff, 2.5 )
  lights.keyLight.position.set( 5, 10, 7 )
  scene.add( lights.keyLight )

  lights.fillLight = new THREE.DirectionalLight( 0xffffff, 1.2 )
  lights.fillLight.position.set( -5, 4, -2 )
  scene.add( lights.fillLight )

  lights.rimLight = new THREE.DirectionalLight( 0xffffff, 0.8 )
  lights.rimLight.position.set( 0, 6, -8 )
  scene.add( lights.rimLight )

  restoreLightControls()
  syncLightsFromControls()
}

function restoreLightControls() {
  try {
    const saved = JSON.parse(localStorage.getItem(LIGHT_CTRL_KEY) || 'null')
    if (!saved || typeof saved !== 'object') return
    document.querySelectorAll('input.light-ctrl').forEach((input) => {
      if (Object.prototype.hasOwnProperty.call(saved, input.name)) {
        input.checked = !!saved[input.name]
      }
    })
  } catch (error) {
    console.log(error)
  }
}

function persistLightControls() {
  const saved = {}
  document.querySelectorAll('input.light-ctrl').forEach((input) => {
    saved[input.name] = input.checked
  })
  localStorage.setItem(LIGHT_CTRL_KEY, JSON.stringify(saved))
}

function restoreHeadControl() {
  try {
    const saved = localStorage.getItem(HEAD_CTRL_KEY)
    if (!saved) return
    const input = document.querySelector(`input[name=head][value="${saved}"]`)
    if (input) input.checked = true
  } catch (error) {
    console.log(error)
  }
}

function persistHeadControl(id) {
  localStorage.setItem(HEAD_CTRL_KEY, String(id))
}

function restoreCameraControl() {
  try {
    const saved = localStorage.getItem(CAMERA_CTRL_KEY)
    if (!saved) return
    const input = document.querySelector(`input[name=camera][value="${saved}"]`)
    if (input) input.checked = true
  } catch (error) {
    console.log(error)
  }
}

function persistCameraControl(id) {
  localStorage.setItem(CAMERA_CTRL_KEY, String(id))
}

function syncLightsFromControls() {
  document.querySelectorAll('input.light-ctrl').forEach((input) => {
    const light = lights[input.name]
    if (light) light.visible = input.checked
  })
  persistLightControls()
}

const animations_h = {
  talking_variation_4: 'https://wco-drupal-prod.s3.amazonaws.com/public/2026-08/F_Talking_Variations_004.fbx',
}
function play_animation(config) {
  let this_head = heads()[config.avatar_id]
  this_head.playAnimation(animations_h[config.animation_name])
}

// herehere
const events = {
  fdurations: [
    10,
    10,
  ],
  ftimes: [
    1000,
    3500,
  ],
  fns: [
    move_camera({ from: '3', to: '2', duration: 1000 }),
    play_animation({ avatar_id: '1', animation_name: 'talking_variation_4' }),
  ],
}



/*
**/
async function init() {
  if (newspartial_id) {
    try {
      const url = wco_origin + '/wco/api/newspartials/' + newspartial_id + '/config.json?api_key=' + api_key + '&api_secret=' + api_secret
      chunkedInput = await fetch(url).then(r => r.json())
      logg(chunkedInput, 'chunkedInput')

      const last = chunkedInput.wtimes.length-1
      const duration_ms = chunkedInput.wtimes[last] + chunkedInput.wdurations[last]
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
  camera_1 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_1.position.set( 0, 1.6, 4 )
  camera_1.lookAt( 0, 1.5, 0 )

  camera_2 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_2.position.set( 2, 1.6, 4 )
  camera_2.lookAt( 1, 1.5, 0 )

  camera_3 = new THREE.PerspectiveCamera( 25, width/height, 0.1, 1000 )
  camera_3.position.set( -2, 2.2, 8 )
  camera_3.lookAt( 0.5, 1.2, 0 )

  camera = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera.position.copy( camera_1.position )
  camera.quaternion.copy( camera_1.quaternion )
  camera.fov = camera_1.fov
  camera.updateProjectionMatrix()

  setup_light(scene)

  const grid = new THREE.GridHelper(10, 10, 0x888888, 0xbbbbbb)
  grid.position.y = 0
  scene.add(grid)


  const studio = (await gltfLoader.loadAsync(scene_url)).scene
  rescale(studio, { height: 3.3 })
  scene.add(studio)


  // head = new TalkingHead( document.getElementById('avatar'), {
  //   avatarOnly: true,
  //   avatarOnlyScene: scene,
  //   avatarOnlyCamera: camera,
  //   lipsyncModules: ["en"],
  //   dracoEnabled: true,
  // })
  head_1 = new TalkingHead( document.getElementById('avatar_1'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  head_2 = new TalkingHead( document.getElementById('avatar_2'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  // head_3 = new TalkingHead( document.getElementById('avatar_3'), {
  //   avatarOnly: true,
  //   avatarOnlyScene: scene,
  //   avatarOnlyCamera: camera,
  //   lipsyncModules: ["en"],
  //   dracoEnabled: true,
  // })


  try {
    loading.textContent = "Loading..."
    await head_1.showAvatar( {
      url: avatar_1_url,
      body: 'F',
      avatarMood: 'neutral',
      lipsyncLang: 'en'
    }, (ev) => {
      if ( ev.lengthComputable ) {
        let val = Math.min(100,Math.round(ev.loaded/ev.total * 100 ))
        loading.textContent = "Loading " + val + "%"
      }
    })
    await head_2.showAvatar( {
      url: avatar_2_url,
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

    head_1.armature.position.set(0, 0, 0)
    head_1.armature.rotation.set(0, 0, 0)
    scene.add(head_1.armature)
    put_feet_at_origin(head_1)
    point_camera_at_face(camera_1, head_1, '1')

    head_2.armature.position.set(1, 0, 0)
    head_2.armature.rotation.set(0, 0, 0)
    scene.add(head_2.armature)
    put_feet_at_origin(head_2)
    point_camera_at_face(camera_2, head_2, '2')

    const onMetrics = (which) => {
      logg(which, 'onMetrics')
    }

    const onSubtitles = (which) => {
      // logg(which)
    }

    const streamOpts = {
      gain: config.gain,
      lipsyncLang: config.lipsyncLang,
      lipsyncType: config.lipsyncType,
      metrics: config.enableMetrics ? { enabled: true, intervalHz: config.metricsInterval } : { enabled: false },
      mood: config.mood,
      sampleRate: config.sampleRate,
      waitForAudioChunks: config.waitForAudioChunks,
    }
    await head_1.streamStart(streamOpts, () => {}, () => {}, onSubtitles, onMetrics)
    await head_2.streamStart(streamOpts, () => {}, () => {}, onSubtitles, onMetrics)

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

  restoreHeadControl()
  document.querySelectorAll('input[name=head]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      setActiveHead(input.value)
    })
  })
  const selectedHead = document.querySelector('input[name=head]:checked')
  setActiveHead(selectedHead ? selectedHead.value : '1')

  restoreCameraControl()
  document.querySelectorAll('input[name=camera]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      setActiveCamera(input.value)
    })
  })
  const selected = document.querySelector('input[name=camera]:checked')
  setActiveCamera(selected ? selected.value : '1', true)

  document.querySelectorAll('input.light-ctrl').forEach((input) => {
    input.addEventListener('change', syncLightsFromControls)
  })
  syncLightsFromControls()

  //

  window.addEventListener( 'resize', onWindowResize )


  // Keep rendering so OrbitControls drag/damping stay live
  lastAnimTime = performance.now()
  renderer.setAnimationLoop(animate)
}

let semafore = false
document.addEventListener('DOMContentLoaded', async function(e) {
  if (!semafore) {
    semafore = true
    await init()
  }
})

function cameras() {
  return { '1': camera_1, '2': camera_2, '3': camera_3 }
}

function heads() {
  return { '1': head_1, '2': head_2, '3': head_3 }
}

function setActiveHead(id) {
  const key = String(id)
  head = heads()[key] || head_1
  persistHeadControl(key)
}

function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2
}

function setActiveCamera(id, instant = false) {
  const key = String(id)
  persistCameraControl(key)
  const dest = cameras()[key] || camera_1
  const destTarget = (cameraTargets[key] || cameraTargets['1']).clone()
  ;[camera_1, camera_2, camera_3, camera].forEach((cam) => {
    if (cam) {
      cam.aspect = width / height
      cam.updateProjectionMatrix()
    }
  })

  dest.updateMatrixWorld()

  const endPos = dest.position.clone()
  const endQuat = dest.quaternion.clone()

  if (instant || !controls) {
    camera.position.copy(endPos)
    camera.quaternion.copy(endQuat)
    camera.fov = dest.fov
    camera.near = dest.near
    camera.far = dest.far
    camera.updateProjectionMatrix()
    faceTarget.copy(destTarget)
    if (controls) {
      controls.target.copy(destTarget)
      controls.update()
    }
    cameraTransition = null
    return
  }

  cameraTransition = {
    startPos: camera.position.clone(),
    startQuat: camera.quaternion.clone(),
    startFov: camera.fov,
    startTarget: controls.target.clone(),
    endPos: endPos,
    endQuat: endQuat,
    endFov: dest.fov,
    endTarget: destTarget,
    t0: performance.now(),
    duration: CAMERA_BLEND_MS,
  }
  controls.enabled = false
}

function updateCameraTransition() {
  if (!cameraTransition) return
  const u = Math.min(1, (performance.now() - cameraTransition.t0) / cameraTransition.duration)
  const e = easeInOutCubic(u)
  const tr = cameraTransition
  camera.position.lerpVectors(tr.startPos, tr.endPos, e)
  camera.quaternion.slerpQuaternions(tr.startQuat, tr.endQuat, e)
  camera.fov = tr.startFov + (tr.endFov - tr.startFov) * e
  camera.updateProjectionMatrix()
  controls.target.lerpVectors(tr.startTarget, tr.endTarget, e)
  faceTarget.copy(controls.target)
  if (u >= 1) {
    cameraTransition = null
    controls.enabled = true
    controls.update()
  }
}

function onWindowResize() {
  ;[camera_1, camera_2, camera_3].forEach((cam) => {
    if (cam) {
      cam.aspect = width / height
      cam.updateProjectionMatrix()
    }
  })
  renderer.setSize( width, height )
  render()
}

function render() {
  renderer.render( scene, camera )
}

function animate() {
  let dt
  if (capturing) {
    dt = 1000 / fps
  } else {
    const now = performance.now()
    dt = lastAnimTime ? (now - lastAnimTime) : (1000 / fps)
    lastAnimTime = now
    if (dt > 100) dt = 100
  }

  if (head_1) head_1.animate(dt)
  if (head_2) head_2.animate(dt)
  if (head_3) head_3.animate(dt)
  if (!capturing) updateCameraTransition()
  if (!cameraTransition && !capturing) controls.update()
  renderer.render( scene, camera )

  if (capturing) {
    capturer.capture( renderer.domElement )
    captureFrame++
    if (captureFrame >= captureTotal) {
      finishCapture()
    }
  }
}

async function startSpeakCapture() {
  if (capturing) return
  if (!head) return
  if (!chunkedInput) {
    console.log('no chunkedInput')
    return
  }

  const last = chunkedInput.wtimes.length - 1
  const duration_ms = chunkedInput.wtimes[last] + chunkedInput.wdurations[last]
  captureTotal = Math.max(1, Math.ceil(duration_ms / 1000 * fps))
  captureFrame = 0
  capturing = true
  cameraTransition = null
  if (controls) controls.enabled = false

  capturer = new CCapture( { format: 'webm', framerate: fps } )
  capturer.start()
  logg('capturer.start')
  document.getElementById('status').textContent = 'capturing'
  head.streamAudio(chunkedInput)
}

function finishCapture() {
  capturing = false
  capturer.stop()
  logg('capturer.stop')
  lastAnimTime = performance.now()
  if (controls) controls.enabled = true

  capturer.save((blob) => {
    logg(blob, 'blob')
    renderer.domElement.toBlob((thumb) => {
      logg(thumb, 'thumb')
      const form = new FormData()
      form.append('video', blob, 'lips.webm')
      form.append('name', slug)
      form.append('thumb', thumb)
      if (newspartial_id) form.append('newspartial_id', newspartial_id)

      const url = wco_origin
        ? (wco_origin + '/wco/api/videos/?api_key=' + api_key + '&api_secret=' + api_secret)
        : '/wco/api/videos/'
      fetch(url, {
        method: 'POST',
        body: form,
      }).then(() => {
        document.getElementById('status').textContent = 'finished'
      }).catch((error) => {
        console.log(error)
        document.getElementById('status').textContent = 'save failed'
      })
    })
  })
}


// Speak when clicked
document.getElementById('speak').addEventListener('click', async function () {
  try {
    await startSpeakCapture()
  } catch (error) {
    console.log(error)
    capturing = false
    lastAnimTime = performance.now()
    if (controls) controls.enabled = true
  }
})

document.getElementById('wave').addEventListener('click', async function () {
  try {
    if (!head) return
    head.playAnimation(wave_url)
  } catch (error) {
    console.log(error)
  }
})

console.log('+++ loaded wco_models :: newsproducer :: studio_blue.js')
