import * as THREE from 'three'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'

const width = 854
const height = 480
const scene_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/scenes/000mb%20collision-world/collision-world.glb'
const vehicle_url = 'https://cdn.jsdelivr.net/gh/wasya-co/ishlib3js@0.3.0/public/vendor/models/vehicles/000mb car-mazda-miata/model.glb'
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
camera.position.set(8, 8, 8)
camera.lookAt(0, 0, 0)

const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 1.2)
scene.add(hemi)
const sun = new THREE.DirectionalLight(0xffffff, 1.4)
sun.position.set(10, 20, 8)
scene.add(sun)

const container = document.getElementById('rotatingC')
container.style.width = width + 'px'
container.style.height = height + 'px'

const renderer = new THREE.WebGLRenderer({ antialias: true })
renderer.setPixelRatio(window.devicePixelRatio)
renderer.setSize(width, height)
renderer.setAnimationLoop(animate)
container.appendChild(renderer.domElement)

function frame_studio(root) {
  const box = new THREE.Box3().setFromObject(root)
  const size = box.getSize(new THREE.Vector3())
  const center = box.getCenter(new THREE.Vector3())
  const max_dim = Math.max(size.x, size.y, size.z, 1)
  const half = max_dim * 0.6
  camera.left = -half * aspect
  camera.right = half * aspect
  camera.top = half
  camera.bottom = -half
  camera.updateProjectionMatrix()
  camera.position.set(center.x + max_dim, center.y + max_dim, center.z + max_dim)
  camera.lookAt(center)
}

const loader = new GLTFLoader()

async function load_studio() {
  $('#status').text('Loading...')
  $('#loading').text('Loading...')
  try {
    const gltf = await loader.loadAsync(scene_url)
    const studio = gltf.scene
    studio.traverse(child => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
      }
    })
    scene.add(studio)
    const vehicle_gltf = await loader.loadAsync(encodeURI(vehicle_url))
    const vehicle = vehicle_gltf.scene
    vehicle.traverse(child => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
      }
    })
    scene.add(vehicle)
    frame_studio(studio)
    $('#status').text('loaded')
    $('#loading').text('loaded')
  } catch (error) {
    console.log(error)
    $('#status').text(error.toString())
    $('#loading').text(error.toString())
  }
}

function animate() {
  renderer.render(scene, camera)
}

load_studio()
