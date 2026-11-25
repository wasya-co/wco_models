
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


const MODELS_ROOT  = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@v0.4.14/public/vendor/models'
const AVATARS_ROOT = `${MODELS_ROOT}/avatars`
const avatars_config = {
  brunette: { type: 'F', url: `${AVATARS_ROOT}/brunette/model.glb` },
  cara:     { type: 'F', url: `${AVATARS_ROOT}/cara/model.glb` }, // short hair
  eve:      { type: 'F', url: `${AVATARS_ROOT}/eve/model.glb`  }, // poison green

  denis:  { type: 'M', url: `${AVATARS_ROOT}/denis/model.glb`  }, // beard
  gregor: { type: 'M', url: `${AVATARS_ROOT}/gregor/model.glb` }, // gray shirt
}
const AVATAR_STOR = 'avatar'
$('select.avatars').each((_idx, el) => {
  const $avatar = $(el)
  $.each(avatars_config, function(name) {
    $('<option>', { value: name, text: name }).appendTo($avatar)
  })
  try {
    const saved_name = localStorage.getItem(`${AVATAR_STOR}-${$avatar.data('spot_id')}`)
    if (saved_name && avatars_config[saved_name]) $avatar.val(saved_name)
  } catch (error) {
    console.log(error)
  }
})

let studios_config = await fetch(`${MODELS_ROOT}/scenes/index.json`).then(r => r.json())
const STUDIO_STOR = 'studio'
$.each(studios_config, (name) => {
  $('<option>', { value: name, text: name }).appendTo($(`select.${STUDIO_STOR}`))
})
try {
  const saved_name = localStorage.getItem( STUDIO_STOR )
  if (saved_name && studios_config[saved_name]) $(`select.${STUDIO_STOR}`).val(saved_name)
} catch (error) {
  console.log(error)
}

let scene_url = studios_config[$(`select.${STUDIO_STOR}`).val()] || studios_config['collision-world']

let gestures = {
  talking_1: (avatar) => `${MODELS_ROOT}/animation-library/feminine/fbx/expression/${avatar.body}_Talking_Variations_001.fbx`,
  talking_4: (avatar) => `${MODELS_ROOT}/animation-library/feminine/fbx/expression/${avatar.body}_Talking_Variations_004.fbx`,
  walk_1: { speed: 2.0, url: (a) => `${MODELS_ROOT}/animation-library/feminine/fbx/locomotion/${a.body}_Walk_001.fbx` },
  walk_2: { speed: 2.0, url: (a) => `${MODELS_ROOT}/animation-library/feminine/fbx/locomotion/${a.body}_Walk_002.fbx` },

  sitting: (a) => `${MODELS_ROOT}/animations/Sitting.fbx`,
  sit_to_stand: (a) => `${MODELS_ROOT}/animations/Sit To Stand.fbx`,
  stand_to_sit: (a) => `${MODELS_ROOT}/animations/Stand To Sit.fbx`,

  entering_car: (a) => `${MODELS_ROOT}/animations/Entering Car.fbx`,
  slow_run: { speed: 1.1, url: (a) => `${MODELS_ROOT}/animations/Slow Run.fbx`, }
};
$.each(gestures, (name) => {
  $('<option>', { value: name, text: name }).appendTo($('select.gestures'))
})

let spot_positions = {
  'spot_1': [0, 0, 0],
  'spot_2': [1, 0, 0],
  'spot_3': [-1, 0, 0],
}



import * as THREE from 'three'

import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'

import { TalkingHead } from "talkinghead"

const params = new URLSearchParams(window.location.search)
const api_key    = params.get('api_key')
const api_secret = params.get('api_secret')
const wco_origin = params.get('wco_origin')
const newspartial_id = params.get('newspartial_id')

let streamOpts = {
  sampleRate: 8000,
  mood: 'neutral',
  gain: 0.5,
  lipsyncType: "visemes",
  lipsyncLang: "en",
  waitForAudioChunks: false,
  metrics: { enabled: false },
}

const onSubtitles = (which) => {
  logg(which, 'onSubtitles')
}

let width = 854
let height = 480
let slug = '<ccapture>'
let fps = 30

let frame = 0
let lastAnimTime = 0
let capturing = false
let captureFrame = 0
let captureTotal = 0
let totalFrames

let active_camera
let cameras = {
  wide: {
    cam: null,
    tgt: new THREE.Vector3(0.5, 1.2, 0),
  },
  spot_1: {
    cam: null,
    tgt: new THREE.Vector3(0, 1.5, 0),
  },
  spot_2: {
    cam: null,
    tgt: new THREE.Vector3(1, 1.5, 0),
  },
  spot_3: {
    cam: null,
    tgt: new THREE.Vector3(-1, 1.5, 0),
  },
}
let controls, renderer, scene
let active_avatar
let avatars = {
  spot_1: null,
  spot_2: null,
  spot_3: null,
}
let faceTarget = new THREE.Vector3()
let cameraTransition = null
const CAMERA_BLEND_MS = 900
let chunkedInput = null
const lights = {}
var capturer = new CCapture( { format: 'webm', framerate: fps } )
const gltfLoader = new GLTFLoader()
const loading = document.getElementById('loading')
const status  = document.getElementById('status')

/*
**/
function point_camera_at_face(cam_id, _head) {
  const leftEye  = new THREE.Vector3()
  const rightEye = new THREE.Vector3()
  _head.objectLeftEye.getWorldPosition(leftEye)
  _head.objectRightEye.getWorldPosition(rightEye)
  faceTarget.copy(leftEye).add(rightEye).multiplyScalar(0.5)

  const camPos = new THREE.Vector3(0, 0, 2)
  camPos.applyQuaternion(_head.armature.quaternion)
  camPos.add(faceTarget)
  const _camera = cameras[cam_id].cam
  _camera.position.copy(camPos)
  _camera.lookAt(faceTarget)
  cameras[cam_id].tgt.copy(faceTarget)
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
function rescale(model, _config) {
  const box = new THREE.Box3().setFromObject(model)
  const size = box.getSize(new THREE.Vector3())
  const currentHeight = size.y
  const scale = _config.height / currentHeight
  model.scale.setScalar(scale)
}

function set_shadows(root, cast, receive) {
  root.traverse((obj) => {
    if (obj.isMesh) {
      obj.castShadow = cast
      obj.receiveShadow = receive
    }
  })
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
  lights.keyLight.castShadow = true
  lights.keyLight.shadow.mapSize.set( 2048, 2048 )
  lights.keyLight.shadow.camera.near = 0.5
  lights.keyLight.shadow.camera.far = 40
  lights.keyLight.shadow.camera.left = -10
  lights.keyLight.shadow.camera.right = 10
  lights.keyLight.shadow.camera.top = 10
  lights.keyLight.shadow.camera.bottom = -10
  lights.keyLight.shadow.bias = -0.0001
  scene.add( lights.keyLight )

  lights.fillLight = new THREE.DirectionalLight( 0xffffff, 1.2 )
  lights.fillLight.position.set( -5, 4, -2 )
  scene.add( lights.fillLight )

  lights.rimLight = new THREE.DirectionalLight( 0xffffff, 0.8 )
  lights.rimLight.position.set( 0, 6, -8 )
  scene.add( lights.rimLight )

  syncLightsFromControls()
}


function syncLightsFromControls() {
  document.querySelectorAll('input.light-ctrl').forEach((input) => {
    const light = lights[input.name]
    if (light) light.visible = input.checked
  })
}

function sync_shadows() {
  const on = $('#is_shadows').prop('checked')
  if (lights.keyLight) lights.keyLight.castShadow = on
}

function gesture_url(g, avatar) {
  if (typeof g === 'function') return g(avatar)
  const u = g && g.url
  return typeof u === 'function' ? u(avatar) : u
}

function update_walk(this_head, dt) {
  if (!this_head || !this_head.speed || !this_head.mixer || !this_head.armature) return
  const dir = new THREE.Vector3()
  this_head.armature.getWorldDirection(dir)
  dir.y = 0
  if (dir.lengthSq() === 0) return
  dir.normalize()
  this_head.armature.position.addScaledVector(dir, this_head.speed * dt / 1000)
}

function play_animation(props) {
  logg(props, 'play_animation()')
  let this_head = avatars[props.spot_id]
  if (this_head) this_head.playAnimation(geastures[props.animation_name](props))
}

function cut_to(key) {
  const radio = document.querySelector(`input[name=active_camera][value="${key}"]`)
  if (radio) radio.checked = true
  setActiveCamera(key, true)
}

function move_camera(props) {
  const fromKey = String(props.from)
  const toKey = String(props.to)
  const duration = Number(props.duration) > 0 ? Number(props.duration) : CAMERA_BLEND_MS
  const src = cameras[fromKey].cam
  const dest = cameras[toKey].cam
  const startTarget = (cameraTargets[fromKey] || cameraTargets.wide).clone()
  const destTarget = (cameraTargets[toKey] || cameraTargets.wide).clone()

  const radio = document.querySelector(`input[name=camera][value="${toKey}"]`)
  if (radio) radio.checked = true

  Object.entries(cameras).forEach(([key, value]) => {
    value.cam.aspect = width / height
    value.cam.updateProjectionMatrix()
  })

  src.updateMatrixWorld()
  dest.updateMatrixWorld()

  camera.position.copy(src.position)
  camera.quaternion.copy(src.quaternion)
  camera.fov = src.fov
  camera.near = dest.near
  camera.far = dest.far
  camera.updateProjectionMatrix()
  faceTarget.copy(startTarget)
  if (controls) {
    controls.target.copy(startTarget)
    controls.enabled = false
  }

  cameraTransition = {
    startPos: src.position.clone(),
    startQuat: src.quaternion.clone(),
    startFov: src.fov,
    startTarget: startTarget,
    endPos: dest.position.clone(),
    endQuat: dest.quaternion.clone(),
    endFov: dest.fov,
    endTarget: destTarget,
    elapsed: 0,
    duration: duration,
  }
}

window.play_animation = play_animation
window.move_camera = move_camera
window.cut_to = cut_to

let eventsIndex = 0
function tickEvents(elapsedMs) {
  if (!chunkedInput || !chunkedInput.ftimes || !chunkedInput.fns) return
  while (eventsIndex < chunkedInput.ftimes.length && elapsedMs >= chunkedInput.ftimes[eventsIndex]) {
    const fn = chunkedInput.fns[eventsIndex]
    logg(fn, 'fn')
    eventsIndex++
    eval(fn)
  }
}

let studio
async function load_studio(cfg) {
  logg(cfg, 'load_studio()')
  if (studio && studio.parent) studio.parent.remove(studio)
  studio = (await gltfLoader.loadAsync(`${cfg.path}/scene.glb`)).scene
  rescale(studio, { height: cfg.height })
  set_shadows(studio, false, true)
  scene.add(studio)
}

/*
**/
async function init() {
  logg(null, 'init()')

  if (newspartial_id) {
    try {
      const url = 'https://' + wco_origin + '/wco/api/newspartials/' + newspartial_id + '/config.json?api_key=' + api_key + '&api_secret=' + api_secret
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
  if (chunkedInput.studio) {
    $(`select.${STUDIO_STOR}`).val(chunkedInput.studio)
    load_studio(studios_config[chunkedInput.studio])
  }
  if (chunkedInput.spot_1) {
    $('select.avatars[data-spot_id="spot_1"]').val(chunkedInput.spot_1)
  }
  if (chunkedInput.spot_2) {
    $('select.avatars[data-spot_id="spot_2"]').val(chunkedInput.spot_2)
  }
  if (chunkedInput.spot_3) {
    $('select.avatars[data-spot_id="spot_3"]').val(chunkedInput.spot_3)
  }

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x333333) // new THREE.Color(0xd3d3d3)

  /* fov — Camera frustum vertical field of view.
   * aspect — Camera frustum aspect ratio.
   * near — Camera frustum near plane.
   * far — Camera frustum far plane.
  **/
  let camera_1, camera_2, camera_3, camera_wide

  camera_1 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_1.position.set( 0, 1.6, 4 )
  camera_1.lookAt( 0, 1.5, 0 )

  camera_2 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_2.position.set( 2, 1.6, 4 )
  camera_2.lookAt( 1, 1.5, 0 )

  camera_3 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_3.position.set( -2, 1.6, 4 )
  camera_3.lookAt( -1, 1.5, 0 )

  camera_wide = new THREE.PerspectiveCamera( 25, width/height, 0.1, 1000 )
  camera_wide.position.set( -2, 2.2, 8 )
  camera_wide.lookAt( 0.5, 1.2, 0 )

  cameras.wide.cam   = camera_wide
  cameras.spot_1.cam = camera_1
  cameras.spot_2.cam = camera_2
  cameras.spot_3.cam = camera_3

  active_camera = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  active_camera.position.copy( camera_wide.position )
  active_camera.quaternion.copy( camera_wide.quaternion )
  active_camera.fov = camera_wide.fov
  active_camera.updateProjectionMatrix()

  setup_light(scene)

  const grid = new THREE.GridHelper(10, 10, 0x888888, 0xbbbbbb)
  grid.position.y = 0
  scene.add(grid)

  await load_studio(scene_url)
  $(`select.${STUDIO_STOR}`).on('change', async function() {
    const name = $(this).val()
    if (!studios_config[name]) return
    localStorage.setItem(STUDIO_STOR, name)
    scene_url = studios_config[name]
    loading.textContent = 'Loading...'
    try {
      await load_studio(scene_url)
      loading.textContent = 'loaded'
    } catch (error) {
      console.log(error)
      loading.textContent = error.toString()
    }
  })


  let head_1, head_2, head_3
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
  head_3 = new TalkingHead( document.getElementById('avatar_3'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  avatars.spot_1 = head_1
  avatars.spot_2 = head_2
  avatars.spot_3 = head_3


  $('select.avatars').on('change', async function() {
    const spot_id = $(this).data('spot_id')
    const name = $(this).val()
    if (!name) return; // empty spot
    const thisAvatar = avatars[spot_id]
    localStorage.setItem(`${AVATAR_STOR}-${spot_id}`, name)
    if (!thisAvatar) return
    if (thisAvatar.armature && thisAvatar.armature.parent) thisAvatar.armature.parent.remove(thisAvatar.armature)
    const avatar_config = avatars_config[name]
    loading.textContent = 'Loading...'
    try {
      await thisAvatar.showAvatar({
        url: avatar_config.url,
        body: avatar_config.type,
        avatarMood: 'neutral',
        lipsyncLang: 'en'
      }, (ev) => {
        if ( ev.lengthComputable ) {
          let percent = Math.min(100,Math.round(ev.loaded/ev.total * 100 ))
          loading.textContent = `Loading ${percent}%`
        }
      })
      thisAvatar.armature.rotation.set(0, 0, 0)
      set_shadows(thisAvatar.armature, true, false)
      scene.add(thisAvatar.armature)
      put_feet_at_origin(thisAvatar)
      thisAvatar.armature.position.add(new THREE.Vector3(...spot_positions[spot_id]))
      point_camera_at_face(spot_id, thisAvatar)
      await thisAvatar.streamStart(streamOpts, () => {}, () => {}, onSubtitles)
      loading.textContent = 'loaded'
    } catch (error) {
      console.log(error)
      loading.textContent = error.toString()
    }
  })
  $('select.avatars').trigger('change')



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
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  document.getElementById('rotatingC').appendChild( renderer.domElement )

  //

  controls = new OrbitControls( active_camera, renderer.domElement )
  controls.enableDamping = true
  controls.enableRotate = true
  controls.enablePan = true
  controls.enableZoom = true
  controls.minDistance = 0.5
  controls.maxDistance = 100
  controls.target.copy(faceTarget)
  controls.autoRotate = false
  controls.update()

  document.querySelectorAll('input[name=active_spot]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      active_avatar = avatars[input.value]
    })
    if (chunkedInput.active_spot && input.value === chunkedInput.active_spot) {
      input.checked = true
    }
  })
  const active_spot = document.querySelector('input[name=active_spot]:checked')
  if (active_spot) {
    active_avatar = avatars[active_spot.value]
  }

  document.querySelectorAll('input[name=active_camera]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      setActiveCamera(input.value)
    })
    if (chunkedInput.active_camera && input.value === chunkedInput.active_camera) {
      input.checked = true
    }
  })
  const selected = document.querySelector('input[name=active_camera]:checked')
  if (selected.value) setActiveCamera(selected.value, true)

  document.querySelectorAll('input.light-ctrl').forEach((input) => {
    input.addEventListener('change', syncLightsFromControls)
  })
  syncLightsFromControls()
  $('#is_shadows').on('change', sync_shadows)
  sync_shadows()

  //

  window.addEventListener( 'resize', onWindowResize )


  // Keep rendering so OrbitControls drag/damping stay live
  lastAnimTime = performance.now()
  renderer.setAnimationLoop(animate)
}

/*
let semafore = false
document.addEventListener('DOMContentLoaded', async function(e) {
  if (!semafore) {
    semafore = true
    await init()
  }
})
*/
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init)
} else {
  init()
}


function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2
}

function setActiveCamera(key, instant = false) {
  const dest = cameras[key].cam
  const destTarget = cameras[key].tgt.clone()

  Object.entries(cameras).forEach(([key, value]) => {
    value.cam.aspect = width / height
    value.cam.updateProjectionMatrix()
  })
  dest.updateMatrixWorld()

  const endPos  = dest.position.clone()
  const endQuat = dest.quaternion.clone()

  if (instant || !controls) {
    active_camera.position.copy(endPos)
    active_camera.quaternion.copy(endQuat)
    active_camera.fov  = dest.fov
    active_camera.near = dest.near
    active_camera.far  = dest.far
    active_camera.updateProjectionMatrix()
    faceTarget.copy(destTarget)
    if (controls) {
      controls.target.copy(destTarget)
      controls.update()
    }
    cameraTransition = null
    return
  }

  cameraTransition = {
    startPos: active_camera.position.clone(),
    startQuat: active_camera.quaternion.clone(),
    startFov: active_camera.fov,
    startTarget: controls.target.clone(),
    endPos: endPos,
    endQuat: endQuat,
    endFov: dest.fov,
    endTarget: destTarget,
    elapsed: 0,
    duration: CAMERA_BLEND_MS,
  }
  controls.enabled = false
}

function updateCameraTransition(dt) {
  if (!cameraTransition) return
  cameraTransition.elapsed += dt
  const u = Math.min(1, cameraTransition.elapsed / cameraTransition.duration)
  const e = easeInOutCubic(u)
  const tr = cameraTransition
  active_camera.position.lerpVectors(tr.startPos, tr.endPos, e)
  active_camera.quaternion.slerpQuaternions(tr.startQuat, tr.endQuat, e)
  active_camera.fov = tr.startFov + (tr.endFov - tr.startFov) * e
  active_camera.updateProjectionMatrix()
  if (controls) {
    controls.target.lerpVectors(tr.startTarget, tr.endTarget, e)
    faceTarget.copy(controls.target)
  } else {
    faceTarget.lerpVectors(tr.startTarget, tr.endTarget, e)
  }
  if (u >= 1) {
    cameraTransition = null
    if (!capturing && controls) {
      controls.enabled = true
      controls.update()
    }
  }
}

function onWindowResize() {
  Object.entries(cameras).forEach(([key, value]) => {
    value.cam.aspect = width / height
    value.cam.updateProjectionMatrix()
  })
  renderer.setSize( width, height )
  render()
}

function render() {
  renderer.render( scene, active_camera )
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

  if (capturing) tickEvents(captureFrame * dt)

  Object.entries(avatars).forEach(([name, _avatar]) => {
    _avatar.animate(dt)
    update_walk(_avatar, dt)
  })
  updateCameraTransition(dt)
  if (!cameraTransition && !capturing) controls.update()
  renderer.render( scene, active_camera )

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
  if (!active_avatar) return
  if (!chunkedInput) return
  logg(null, 'startSpeakCapture()')

  const last = chunkedInput.wtimes.length - 1
  const duration_ms = chunkedInput.wtimes[last] + chunkedInput.wdurations[last]
  captureTotal = Math.max(1, Math.ceil(duration_ms / 1000 * fps))
  captureFrame = 0
  eventsIndex = 0
  capturing = true
  cameraTransition = null
  if (controls) controls.enabled = false

  capturer = new CCapture( { format: 'webm', framerate: fps } )
  capturer.start()
  logg('capturer.start')
  status.textContent = 'capturing'
  active_avatar.streamAudio(chunkedInput)
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

      const url = 'https://' + wco_origin + '/wco/api/videos/?api_key=' + api_key + '&api_secret=' + api_secret

      fetch(url, {
        method: 'POST',
        body: form,
      }).then(() => {
        status.textContent = 'finished'
      }).catch((error) => {
        console.log(error)
        status.textContent = 'save failed'
      })
    })
  })
}


// Speak when clicked
$('#speak').on('click', async () => {
  try {
    await startSpeakCapture()
  } catch (error) {
    console.log(error)
    capturing = false
    lastAnimTime = performance.now()
    if (controls) controls.enabled = true
  }
})

$('#jesture').on('click', async () => {
  try {
    if (!active_avatar) return
    const name = $('select.gestures').val()
    const g = gestures[name]
    const _anim = gesture_url(g, active_avatar.avatar)
    active_avatar.speed = (g && typeof g === 'object' && g.speed) ? g.speed : 0
    active_avatar.playAnimation( _anim )
  } catch (error) {
    console.log(error)
  }
})

console.log('+++ loaded wco_models :: newsproducer :: studio_blue2.js')
