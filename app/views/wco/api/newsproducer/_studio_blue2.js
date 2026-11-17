
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

document.addEventListener("keydown", e => {
  if (e.code === "Space" && !["INPUT", "TEXTAREA"].includes(e.target.tagName)) {
    e.preventDefault()
  }
})

const MODELS_ROOT = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.7/public/vendor/models'

const SPOTS_STOR = 'spots'
const avatars = {
  brunette: { type: 'F', url: `${MODELS_ROOT}/avatars/brunette/model.glb` },
  cara:     { type: 'F', url: `${MODELS_ROOT}/avatars/cara/model.glb` }, // short hair
  eve:      { type: 'F', url: `${MODELS_ROOT}/avatars/eve/model.glb` }, // poison green

  denis:  { type: 'M', url: `${MODELS_ROOT}/avatars/denis/model.glb`  }, // beard
  gregor: { type: 'M', url: `${MODELS_ROOT}/avatars/gregor/model.glb` }, // gray shirt
}
$('select.spots').each((_idx, el) => {
  const $select = $(el)
  $.each(avatars, function(name, url) {
    $('<option>', { value: name, text: name }).appendTo($select)
  })
  try {
    const saved = localStorage.getItem(`${SPOTS_STOR}-${$select.data('uid')}`)
    if (saved && avatars[saved]) $select.val(saved)
  } catch (error) {
    console.log(error)
  }
})

const SCENE_STOR = 'studio'
const studios = await fetch(`${MODELS_ROOT}/scenes/index.json`).then(r => r.json())
/* const studios = {
  "skybox_1": {
    "name": "skybox_1",
    "height": 30,
    "path": "https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.1/public/vendor/models/scenes/000mb h30 skybox_1"
  },
  "collision-world": {
    "name": "collision-world",
    "height": null,
    "path": "https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.1/public/vendor/models/scenes/000mb collision-world"
  },
  "city-at-night": {
    "name": "city-at-night",
    "height": null,
    "path": "https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.1/public/vendor/models/scenes/003mb city-at-night"
  },
  "newsroom_green": {
    "name": "newsroom_green",
    "height": 3.3,
    "path": "https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.1/public/vendor/models/scenes/001mb h33cm newsroom_green"
  },
  "room-1": {
    "name": "room-1",
    "height": 6,
    "path": "https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.4.1/public/vendor/models/scenes/000mb h6 room-1"
  },
} */
$.each(studios, (name) => {
  $('<option>', { value: name, text: name }).appendTo($('select.studio'))
})
try {
  const saved = localStorage.getItem( SCENE_STOR )
  if (saved && studios[saved]) $('select.studio').val(saved)
} catch (error) {
  console.log(error)
}
let active_studio_name = 'newsroom_green' // 'collision-world'
let active_studio
async function load_studio(_cfg) {
  logg(_cfg, 'load_studio')

  if (active_studio && active_studio.parent) active_studio.parent.remove(active_studio)
  active_studio = (await gltfLoader.loadAsync(`${_cfg.path}/scene.glb`)).scene
  if (_cfg.height) {
    rescale(active_studio, { height: _cfg.height })
  }
  set_shadows(active_studio, false, true)
  scene.add(active_studio)
}



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

let u_positions = {
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

let config = {
  sampleRate: 8000,
  mood: 'neutral',
  gain: 0.5,
  lipsyncType: "visemes",
  lipsyncLang: "en",
  waitForAudioChunks: false,
  enableMetrics: false,
};

const onMetrics = (which) => {
  logg(which, 'onMetrics')
}

const onSubtitles = (which) => {
  logg(which, 'onSubtitles')
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


let width = 854
let height = 480
let slug = '<ccapture>'
const fps = 30

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

let camera, camera_wide, camera_1, camera_2, camera_3
let controls, renderer, scene
let head, head_1, head_2, head_3
let faceTarget = new THREE.Vector3()
const cameraTargets = {
  wide: new THREE.Vector3(0.5, 1.2, 0),
  av_1: new THREE.Vector3(0, 1.5, 0),
  av_2: new THREE.Vector3(1, 1.5, 0),
  av_3: new THREE.Vector3(-1, 1.5, 0),
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
const status = document.getElementById('status')

/*
**/
function point_camera_at_face(cam_id, _head) {
  const leftEye = new THREE.Vector3()
  const rightEye = new THREE.Vector3()
  _head.objectLeftEye.getWorldPosition(leftEye)
  _head.objectRightEye.getWorldPosition(rightEye)
  faceTarget.copy(leftEye).add(rightEye).multiplyScalar(0.5)

  const camPos = new THREE.Vector3(0, 0, 2)
  camPos.applyQuaternion(_head.armature.quaternion)
  camPos.add(faceTarget)
  const _camera = cameras_fn(cam_id)
  _camera.position.copy(camPos)
  _camera.lookAt(faceTarget)
  cameraTargets[cam_id].copy(faceTarget)
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

function cut_to(key) {
  const radio = document.querySelector(`input[name=camera][value="${key}"]`)
  if (radio) radio.checked = true
  setActiveCamera(key, true)
}

function move_camera(config) {
  const fromKey = String(config.from)
  const toKey = String(config.to)
  const duration = Number(config.duration) > 0 ? Number(config.duration) : CAMERA_BLEND_MS
  const src = cameras_fn(fromKey)
  const dest = cameras_fn(toKey)
  const startTarget = (cameraTargets[fromKey] || cameraTargets.wide).clone()
  const destTarget = (cameraTargets[toKey] || cameraTargets.wide).clone()

  persistCameraControl(toKey)
  const radio = document.querySelector(`input[name=camera][value="${toKey}"]`)
  if (radio) radio.checked = true

  ;[camera_wide, camera_1, camera_2, camera_3, camera].forEach((cam) => {
    if (cam) {
      cam.aspect = width / height
      cam.updateProjectionMatrix()
    }
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

/* these are available exec_js functions? */
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

function play_animation(config) {
  logg(config, 'my play_animation()')
  let this_head = heads_fn()[config.avatar_id]
  if (this_head) this_head.playAnimation(geastures[config.animation_name](config))
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
  scene.background = new THREE.Color(0x333333) // new THREE.Color(0xd3d3d3)

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

  camera_3 = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera_3.position.set( -2, 1.6, 4 )
  camera_3.lookAt( -1, 1.5, 0 )

  camera_wide = new THREE.PerspectiveCamera( 25, width/height, 0.1, 1000 )
  camera_wide.position.set( -2, 2.2, 8 )
  camera_wide.lookAt( 0.5, 1.2, 0 )

  camera = new THREE.PerspectiveCamera( 10, width/height, 0.1, 1000 )
  camera.position.copy( camera_wide.position )
  camera.quaternion.copy( camera_wide.quaternion )
  camera.fov = camera_wide.fov
  camera.updateProjectionMatrix()

  setup_light(scene)

  const grid = new THREE.GridHelper(10, 10, 0x888888, 0xbbbbbb)
  grid.position.y = 0
  scene.add(grid)



  await load_studio( studios[active_studio_name] )
  $('select.studio').on('change', async function() {
    const name = $(this).val()
    if (!studios[name]) return
    localStorage.setItem(SCENE_STOR, name)
    loading.textContent = 'Loading...'
    try {
      await load_studio(studios[name])
      loading.textContent = 'loaded'
    } catch (error) {
      console.log(error)
      loading.textContent = error.toString()
    }
  })

  avatar_1 = new TalkingHead( document.getElementById('avatar_1'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  avatar_2 = new TalkingHead( document.getElementById('avatar_2'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })
  avatar_3 = new TalkingHead( document.getElementById('avatar_3'), {
    avatarOnly: true,
    avatarOnlyScene: scene,
    avatarOnlyCamera: camera_1,
    lipsyncModules: ["en"],
    dracoEnabled: true,
  })




  $('select.spots').on('change', async function() {
    const uid = String($(this).data('uid'))
    const thisHead = heads_fn(uid)
    const val = $(this).val()
    localStorage.setItem(`${SPOTS_STOR}-${uid}`, val || '')
    if (!thisHead) return
    if (thisHead.armature && thisHead.armature.parent) thisHead.armature.parent.remove(thisHead.armature)
    const avatar = avatars[val]
    if (!avatar || !avatar.url) return
    loading.textContent = 'Loading...'
    try {
      if (thisHead.armature && thisHead.armature.parent) thisHead.armature.parent.remove(thisHead.armature)
      await thisHead.showAvatar({
        url: avatar.url,
        body: avatar.type,
        avatarMood: 'neutral',
        lipsyncLang: 'en'
      }, (ev) => {
        if ( ev.lengthComputable ) {
          let val = Math.min(100,Math.round(ev.loaded/ev.total * 100 ))
          loading.textContent = "Loading " + val + "%"
        }
      })
      thisHead.armature.rotation.set(0, 0, 0)
      set_shadows(thisHead.armature, true, false)
      scene.add(thisHead.armature)
      put_feet_at_origin(thisHead)
      thisHead.armature.position.add(new THREE.Vector3(...u_positions[uid]))
      point_camera_at_face(`av_${uid}`, thisHead)
      await thisHead.streamStart(streamOpts, () => {}, () => {}, onSubtitles, onMetrics)
      loading.textContent = 'loaded'
    } catch (error) {
      console.log(error)
      loading.textContent = error.toString()
    }
  })
  $('select.avatar').trigger('change')



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
  document.querySelectorAll('input[name=avatar]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      setActiveAvatar(input.value)
    })
  })
  const selectedHead = document.querySelector('input[name=head]:checked')
  setActiveAvatar(selectedHead ? selectedHead.value : 'avatar_1')

  restoreCameraControl()
  document.querySelectorAll('input[name=camera]').forEach((input) => {
    input.addEventListener('change', () => {
      if (!input.checked) return
      setActiveCamera(input.value)
    })
  })
  const selected = document.querySelector('input[name=camera]:checked')
  setActiveCamera(selected ? selected.value : 'wide', true)

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


function cameras_fn(which) {
  switch (which) {
    case 'cam_wide':
      return camera_wide
    case 'cam_1':
      return camera_1
    case 'cam_2':
      return camera_2
    case 'cam_3':
      return camera_3
    default:
      logg('fpq - cameras_fn default - this should never happen')
      return camera_wide
  }
}

let active_avatar, avatar_1, avatar_2, avatar_3
function avatars_fn(which) {
  switch (which) {
    case 'avatar_1':
      return avatar_1
      break;
    case 'avatar_2':
      return avatar_2
      break;
    case 'avatar_3':
      return avatar_3
      break;
    default:
      logg(`fpp - avatars_fn default - '${which}' - this should never happen`)
      return avatar_1
  }
}

function setActiveAvatar(id) {
  active_avatar = avatars_fn(id)
  persistHeadControl(id)
}

function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2
}

function setActiveCamera(id, instant = false) {
  const key = String(id)
  persistCameraControl(key)
  const dest = cameras_fn(key)
  const destTarget = (cameraTargets[key] || cameraTargets.wide).clone()
  ;[camera_wide, camera_1, camera_2, camera_3, camera].forEach((cam) => {
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
  camera.position.lerpVectors(tr.startPos, tr.endPos, e)
  camera.quaternion.slerpQuaternions(tr.startQuat, tr.endQuat, e)
  camera.fov = tr.startFov + (tr.endFov - tr.startFov) * e
  camera.updateProjectionMatrix()
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
  ;[camera_wide, camera_1, camera_2, camera_3].forEach((cam) => {
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

  if (capturing) tickEvents(captureFrame * dt)

  if (head_1) head_1.animate(dt)
  if (head_2) head_2.animate(dt)
  if (head_3) head_3.animate(dt)
  update_walk(head_1, dt)
  update_walk(head_2, dt)
  update_walk(head_3, dt)
  updateCameraTransition(dt)
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
  if (!chunkedInput) return

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
    if (!head) return
    const name = $('select.gestures').val()
    const g = gestures[name]
    const _anim = gesture_url(g, head.avatar)
    head.speed = (g && typeof g === 'object' && g.speed) ? g.speed : 0
    head.playAnimation( _anim )
  } catch (error) {
    console.log(error)
  }
})

console.log('+++ loaded wco_models :: newsproducer :: studio_blue.js')
