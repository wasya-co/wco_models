import * as THREE from 'three'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import * as CANNON from 'cannon-es'

const width = 854
const height = 480
const scene_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/scenes/000mb%20collision-world/collision-world.glb'
const scene_config = {
  height: 80,
}

const vehicle_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/vehicles/000mb car-mazda-miata/model.glb'
// const vehicle_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/vehicles/001mb truck-drifter-lowpoly/model.glb'
const vehicle_config = {
  height: 1.235,
  length: 3.970,
  width: 1.675,
}

const scene = new THREE.Scene()
scene.background = new THREE.Color(0x88ccee)

const aspect = width / height
const view_size = 8
const camera = new THREE.OrthographicCamera(
  -view_size * aspect,
  view_size * aspect,
  view_size,
  -view_size,
  0.1,
  1000
)
const camera_offset = new THREE.Vector3(5, 3, 5)
const follow_target = new THREE.Vector3()
camera.position.copy(camera_offset)
camera.lookAt(0, 0, 0)

const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 1.2)
scene.add(hemi)
const sun = new THREE.DirectionalLight(0xffffff, 1.4)
sun.position.set(10, 20, 8)
sun.castShadow = true
sun.shadow.mapSize.set(2048, 2048)
sun.shadow.camera.near = 0.5
sun.shadow.camera.far = 80
sun.shadow.camera.left = -30
sun.shadow.camera.right = 30
sun.shadow.camera.top = 30
sun.shadow.camera.bottom = -30
sun.shadow.bias = -0.0001
scene.add(sun)
const spot = new THREE.SpotLight(0xffffff, 8)
spot.position.set(3, 6, 3)
spot.angle = Math.PI / 5
spot.penumbra = 0.35
spot.decay = 2
spot.distance = 40
spot.castShadow = true
spot.shadow.mapSize.set(1024, 1024)
spot.shadow.camera.near = 0.5
spot.shadow.camera.far = 40
spot.shadow.bias = -0.0001
spot.target.position.set(0, 0, 0)
scene.add(spot)
scene.add(spot.target)

const container = document.getElementById('rotatingC')
container.style.width = width + 'px'
container.style.height = height + 'px'

const renderer = new THREE.WebGLRenderer({ antialias: true })
renderer.setPixelRatio(window.devicePixelRatio)
renderer.setSize(width, height)
renderer.shadowMap.enabled = true
renderer.shadowMap.type = THREE.PCFSoftShadowMap
renderer.setAnimationLoop(animate)
container.appendChild(renderer.domElement)

const GRAVITY = 20
const TOP_SPEED = 8
const ENGINE_FORCE = 700
const MAX_STEER = 0.45
const clock = new THREE.Clock()
const keys = {}
const world_forward = new CANNON.Vec3()
const local_forward = new CANNON.Vec3(0, 0, 1)
const tmp_vec = new THREE.Vector3()

const world = new CANNON.World({
  gravity: new CANNON.Vec3(0, -GRAVITY, 0),
})
world.broadphase = new CANNON.SAPBroadphase(world)
world.allowSleep = false
world.defaultContactMaterial.friction = 0.4
world.defaultContactMaterial.restitution = 0.05

const ground_material = new CANNON.Material('ground')
const chassis_material = new CANNON.Material('chassis')
world.addContactMaterial(new CANNON.ContactMaterial(ground_material, chassis_material, {
  friction: 0.6,
  restitution: 0.05,
}))

let studio = null
let vehicle = null
let vehicle_root = null
let chassis_body = null
let ray_vehicle = null

document.addEventListener('keydown', event => {
  keys[event.code] = true
})
document.addEventListener('keyup', event => {
  keys[event.code] = false
})

function follow_vehicle() {
  if (!vehicle_root) return
  follow_target.copy(vehicle_root.position)
  camera.position.copy(follow_target).add(camera_offset)
  camera.lookAt(follow_target)
}

function geometry_to_trimesh(geometry, matrix) {
  const pos = geometry.attributes.position
  const vertices = []
  for (let i = 0; i < pos.count; i++) {
    tmp_vec.fromBufferAttribute(pos, i)
    tmp_vec.applyMatrix4(matrix)
    vertices.push(tmp_vec.x, tmp_vec.y, tmp_vec.z)
  }
  const indices = []
  if (geometry.index) {
    for (let i = 0; i < geometry.index.count; i++) {
      indices.push(geometry.index.getX(i))
    }
  } else {
    for (let i = 0; i < pos.count; i++) {
      indices.push(i)
    }
  }
  return new CANNON.Trimesh(vertices, indices)
}

function add_studio_collision(root) {
  root.updateMatrixWorld(true)
  const ground_body = new CANNON.Body({ mass: 0, material: ground_material })
  root.traverse(child => {
    if (!child.isMesh || !child.geometry || !child.geometry.attributes.position) return
    ground_body.addShape(geometry_to_trimesh(child.geometry, child.matrixWorld))
  })
  world.addBody(ground_body)
}

function add_ray_wheel(options, x, y, z) {
  options.chassisConnectionPointLocal.set(x, y, z)
  ray_vehicle.addWheel(options)
}

function setup_vehicle_physics(center) {
  const chassis_half = new CANNON.Vec3(
    vehicle_config.width * 0.38,
    vehicle_config.height * 0.18,
    vehicle_config.length * 0.38
  )
  chassis_body = new CANNON.Body({
    mass: 400,
    material: chassis_material,
    angularDamping: 0.35,
    linearDamping: 0.08,
  })
  chassis_body.addShape(new CANNON.Box(chassis_half), new CANNON.Vec3(0, 0.12, 0))
  chassis_body.position.set(center.x, center.y + 1.4, center.z)
  world.addBody(chassis_body)

  ray_vehicle = new CANNON.RaycastVehicle({
    chassisBody: chassis_body,
    indexRightAxis: 0,
    indexUpAxis: 1,
    indexForwardAxis: 2,
  })

  const wheel_y = -vehicle_config.height * 0.18
  const half_w = vehicle_config.width * 0.42
  const half_l = vehicle_config.length * 0.32
  const wheel_options = {
    radius: vehicle_config.height * 0.22,
    directionLocal: new CANNON.Vec3(0, -1, 0),
    suspensionStiffness: 45,
    suspensionRestLength: 0.28,
    frictionSlip: 1.8,
    dampingRelaxation: 2.3,
    dampingCompression: 4.4,
    maxSuspensionForce: 100000,
    rollInfluence: 0.08,
    axleLocal: new CANNON.Vec3(-1, 0, 0),
    chassisConnectionPointLocal: new CANNON.Vec3(0, 0, 0),
    maxSuspensionTravel: 0.25,
    customSlidingRotationalSpeed: -30,
    useCustomSlidingRotationalSpeed: true,
  }

  add_ray_wheel(wheel_options, half_w, wheel_y, half_l)
  add_ray_wheel(wheel_options, -half_w, wheel_y, half_l)
  add_ray_wheel(wheel_options, half_w, wheel_y, -half_l)
  add_ray_wheel(wheel_options, -half_w, wheel_y, -half_l)
  ray_vehicle.addToWorld(world)
}

function current_speed() {
  if (!chassis_body) return 0
  chassis_body.vectorToWorldFrame(local_forward, world_forward)
  return chassis_body.velocity.dot(world_forward)
}

function update_drive() {
  if (!ray_vehicle) return
  let steer = 0
  if (keys.KeyA) steer = MAX_STEER
  if (keys.KeyD) steer = -MAX_STEER
  ray_vehicle.setSteeringValue(steer, 0)
  ray_vehicle.setSteeringValue(steer, 1)
  const force = current_speed() < TOP_SPEED ? ENGINE_FORCE : 0
  ray_vehicle.applyEngineForce(force, 2)
  ray_vehicle.applyEngineForce(force, 3)
}

function sync_vehicle() {
  if (!vehicle_root || !chassis_body) return
  vehicle_root.position.copy(chassis_body.position)
  vehicle_root.quaternion.copy(chassis_body.quaternion)
}

function reset_vehicle() {
  if (!chassis_body) return
  chassis_body.position.set(0, 3, 0)
  chassis_body.velocity.set(0, 0, 0)
  chassis_body.angularVelocity.set(0, 0, 0)
  chassis_body.quaternion.set(0, 0, 0, 1)
}

const loader = new GLTFLoader()

async function load_studio() {
  $('#status').text('Loading...')
  $('#loading').text('Loading...')
  try {
    const gltf = await loader.loadAsync(scene_url)
    studio = gltf.scene
    studio.traverse(child => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
      }
    })
    scene.add(studio)
    studio.updateMatrixWorld(true)
    const studio_size = new THREE.Box3().setFromObject(studio).getSize(new THREE.Vector3())
    const scene_height_scale = scene_config.height / Math.max(studio_size.y, 0.0001)
    studio.scale.multiplyScalar(scene_height_scale)
    studio.updateMatrixWorld(true)
    const scaled_studio_size = new THREE.Box3().setFromObject(studio).getSize(new THREE.Vector3())
    console.log('scene dimensions', {
      x: scaled_studio_size.x,
      y: scaled_studio_size.y,
      z: scaled_studio_size.z
    })
    add_studio_collision(studio)
    const vehicle_gltf = await loader.loadAsync(encodeURI(vehicle_url))
    vehicle = vehicle_gltf.scene
    vehicle.traverse(child => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
      }
    })
    scene.add(vehicle)
    vehicle.updateMatrixWorld(true)
    const vehicle_size = new THREE.Box3().setFromObject(vehicle).getSize(new THREE.Vector3())
    const height_scale = vehicle_config.height / Math.max(vehicle_size.y, 0.0001)
    vehicle.scale.multiplyScalar(height_scale)
    vehicle.updateMatrixWorld(true)
    const scaled_box = new THREE.Box3().setFromObject(vehicle)
    const scaled_center = scaled_box.getCenter(new THREE.Vector3())
    const scaled_vehicle_size = scaled_box.getSize(new THREE.Vector3())
    console.log('vehicle dimensions', {
      x: scaled_vehicle_size.x,
      y: scaled_vehicle_size.y,
      z: scaled_vehicle_size.z
    })
    vehicle_root = new THREE.Group()
    vehicle_root.position.copy(scaled_center)
    scene.add(vehicle_root)
    const vehicle_visual = new THREE.Group()
    vehicle_root.add(vehicle_visual)
    vehicle_visual.attach(vehicle)
    vehicle_visual.rotation.y = Math.PI
    setup_vehicle_physics(scaled_center)
    follow_vehicle()
    $('#status').text('loaded')
    $('#loading').text('loaded')
  } catch (error) {
    console.log(error)
    $('#status').text(error.toString())
    $('#loading').text(error.toString())
  }
}

function animate() {
  const delta_time = Math.min(0.05, clock.getDelta())
  update_drive()
  world.step(1 / 60, delta_time, 4)
  sync_vehicle()
  if (chassis_body && chassis_body.position.y <= -25) {
    reset_vehicle()
  }
  follow_vehicle()
  renderer.render(scene, camera)
}

load_studio()
